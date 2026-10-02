const http = require('http');
const { WebSocketServer } = require('ws');
const db = require('./db.js');

const PORT = process.env.PORT || 4000;

// Active WebSocket connections: username (lowercase) -> WebSocket
const clients = new Map();
// Active Ready States in Lobby: username (lowercase) -> boolean
const lobbyReadyMap = new Map();

function sendToUser(username, messageObj) {
  if (!username) return false;
  const ws = clients.get(username.toLowerCase());
  if (ws && ws.readyState === ws.OPEN) {
    ws.send(JSON.stringify(messageObj));
    return true;
  }
  return false;
}

// Helper to parse JSON body
function parseRequestBody(req) {
  return new Promise((resolve, reject) => {
    let body = '';
    req.on('data', chunk => { body += chunk; });
    req.on('end', () => {
      try {
        resolve(body ? JSON.parse(body) : {});
      } catch (e) {
        reject(new Error('Geçersiz JSON verisi'));
      }
    });
    req.on('error', reject);
  });
}

// HTTP Server for Health check, REST Auth API & CORS
const server = http.createServer(async (req, res) => {
  // CORS Headers for Flutter Web & Tailscale
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }

  const url = new URL(req.url, `http://${req.headers.host}`);

  // Health check
  if (url.pathname === '/health' || url.pathname === '/') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({
      status: 'ok',
      service: 'LoversCat SQL Backend',
      database: 'SQLite',
      onlineUsers: clients.size,
      time: new Date().toISOString()
    }));
    return;
  }

  // POST /api/register
  if (url.pathname === '/api/register' && req.method === 'POST') {
    try {
      const data = await parseRequestBody(req);
      const user = await db.registerUser({
        username: data.username,
        password: data.password,
        petType: data.petType,
        petName: data.petName
      });
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ success: true, user }));
    } catch (err) {
      res.writeHead(400, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ success: false, error: err.message }));
    }
    return;
  }

  // POST /api/login
  if (url.pathname === '/api/login' && req.method === 'POST') {
    try {
      const data = await parseRequestBody(req);
      const user = await db.loginUser({
        username: data.username,
        password: data.password
      });
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ success: true, user }));
    } catch (err) {
      res.writeHead(401, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ success: false, error: err.message }));
    }
    return;
  }

  // GET /api/users
  if (url.pathname === '/api/users') {
    const list = await db.listUsers();
    const formatted = list.map(u => ({
      ...u,
      isOnline: clients.has(u.username.toLowerCase())
    }));
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify(formatted));
    return;
  }

  // POST /api/user/avatar
  if (url.pathname === '/api/user/avatar' && req.method === 'POST') {
    try {
      const data = await parseRequestBody(req);
      const username = (data.username || '').trim().toLowerCase().replace(/^@+/, '');
      const customAvatarBase64 = data.customAvatarBase64 || null;
      if (!username) {
        res.writeHead(400, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ success: false, error: 'Kullanıcı adı gereklidir.' }));
        return;
      }

      const updatedUser = await db.updateCustomAvatar(username, customAvatarBase64);

      // Notify partner via WebSocket
      if (updatedUser && updatedUser.partnerUsername) {
        sendToUser(updatedUser.partnerUsername, {
          type: 'partner_avatar_updated',
          partner: updatedUser
        });
      }

      // Notify self
      sendToUser(username, {
        type: 'user_avatar_updated',
        user: updatedUser
      });

      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ success: true, user: updatedUser }));
    } catch (err) {
      console.error('[HTTP] Error in /api/user/avatar:', err.message);
      res.writeHead(400, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ success: false, error: err.message }));
    }
    return;
  }

  // GET /api/user/:username
  if (url.pathname.startsWith('/api/user/')) {
    const targetUsername = url.pathname.replace('/api/user/', '').toLowerCase();
    const user = await db.getUserByUsername(targetUsername);
    if (!user) {
      res.writeHead(404, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: 'Kullanıcı bulunamadı.' }));
      return;
    }
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({
      ...user,
      isOnline: clients.has(targetUsername)
    }));
    return;
  }

  // POST /api/friend-request (Guaranteed SQL insertion + WS push)
  if (url.pathname === '/api/friend-request' && req.method === 'POST') {
    try {
      const data = await parseRequestBody(req);
      const fromUsername = (data.fromUsername || '').trim().toLowerCase().replace(/^@+/, '');
      const toUsername = (data.toUsername || '').trim().toLowerCase().replace(/^@+/, '');

      if (!fromUsername || !toUsername) {
        res.writeHead(400, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ success: false, error: 'Gönderen ve alıcı kullanıcı adı gereklidir.' }));
        return;
      }

      const reqItem = await db.createFriendRequest(fromUsername, toUsername);
      console.log(`[HTTP] Friend request created: @${fromUsername} -> @${toUsername}`);

      // Notify target immediately via WebSocket if online
      sendToUser(toUsername, {
        type: 'friend_request_received',
        request: reqItem
      });

      // Notify sender
      sendToUser(fromUsername, {
        type: 'request_sent',
        request: reqItem,
        message: `@${toUsername} kullanıcısına arkadaşlık isteği gönderildi!`
      });

      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ success: true, request: reqItem }));
    } catch (err) {
      console.error('[HTTP] Error in /api/friend-request:', err.message);
      res.writeHead(400, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ success: false, error: err.message }));
    }
    return;
  }

  // GET /api/friend-requests/:username
  if (url.pathname.startsWith('/api/friend-requests/') && req.method === 'GET') {
    try {
      const username = decodeURIComponent(url.pathname.replace('/api/friend-requests/', '')).trim().toLowerCase().replace(/^@+/, '');
      const incoming = await db.getIncomingRequests(username);
      const sent = await db.getSentRequests(username);
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({
        success: true,
        incomingRequests: incoming,
        sentRequests: sent
      }));
    } catch (err) {
      console.error('[HTTP] Error in /api/friend-requests:', err.message);
      res.writeHead(500, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ success: false, error: err.message }));
    }
    return;
  }

  // POST /api/friend-request/respond
  if (url.pathname === '/api/friend-request/respond' && req.method === 'POST') {
    try {
      const data = await parseRequestBody(req);
      const { requestId, accept, username } = data;
      const request = await db.getRequestById(requestId);
      if (!request) {
        res.writeHead(404, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ success: false, error: 'İstek bulunamadı.' }));
        return;
      }

      if (accept) {
        await db.respondRequest(requestId, 'accepted');
        await db.pairUsers(request.from_username, request.to_username);

        const u1 = await db.getUserByUsername(request.from_username);
        const u2 = await db.getUserByUsername(request.to_username);

        sendToUser(request.from_username, {
          type: 'pair_success',
          user: u1,
          partner: {
            ...u2,
            isOnline: clients.has(request.to_username.toLowerCase())
          },
          message: `@${request.to_username} arkadaşlık isteğini kabul etti! 💖`
        });

        sendToUser(request.to_username, {
          type: 'pair_success',
          user: u2,
          partner: {
            ...u1,
            isOnline: clients.has(request.from_username.toLowerCase())
          },
          message: `@${request.from_username} ile eşleştiniz! 💖`
        });

        const activeUser = (username || '').toLowerCase() === u1.username ? u1 : u2;
        const activePartner = (username || '').toLowerCase() === u1.username ? u2 : u1;

        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({
          success: true,
          user: activeUser,
          partner: {
            ...activePartner,
            isOnline: clients.has(activePartner.username)
          }
        }));
      } else {
        await db.respondRequest(requestId, 'rejected');
        sendToUser(request.from_username, {
          type: 'request_rejected',
          requestId
        });
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ success: true, requestId }));
      }
    } catch (err) {
      console.error('[HTTP] Error in /api/friend-request/respond:', err.message);
      res.writeHead(400, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ success: false, error: err.message }));
    }
    return;
  }

  // POST /api/unpair
  if (url.pathname === '/api/unpair' && req.method === 'POST') {
    try {
      const data = await parseRequestBody(req);
      const username = (data.username || '').trim().toLowerCase();
      const user = await db.getUserByUsername(username);
      if (user && user.partnerUsername) {
        const partnerUsername = user.partnerUsername;
        await db.unpairUsers(username, partnerUsername);

        sendToUser(partnerUsername, {
          type: 'unpair_success',
          message: `@${username} eşleşmeyi sonlandırdı.`
        });
      }
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ success: true }));
    } catch (err) {
      console.error('[HTTP] Error in /api/unpair:', err.message);
      res.writeHead(400, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ success: false, error: err.message }));
    }
    return;
  }

  // GET /api/questions/:username
  if (url.pathname.startsWith('/api/questions/') && req.method === 'GET') {
    try {
      const username = decodeURIComponent(url.pathname.replace('/api/questions/', ''));
      const list = await db.getCustomQuestions(username);
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ success: true, questions: list }));
    } catch (err) {
      res.writeHead(400, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ success: false, error: err.message }));
    }
    return;
  }

  // POST /api/questions
  if (url.pathname === '/api/questions' && req.method === 'POST') {
    try {
      const data = await parseRequestBody(req);
      const question = await db.createCustomQuestion({
        username: data.username,
        text: data.text,
        type: data.type || 'multipleChoice',
        options: data.options || []
      });
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ success: true, question }));
    } catch (err) {
      res.writeHead(400, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ success: false, error: err.message }));
    }
    return;
  }

  // DELETE /api/questions/:id
  if (url.pathname.startsWith('/api/questions/') && req.method === 'DELETE') {
    try {
      const qId = url.pathname.replace('/api/questions/', '');
      const username = url.searchParams.get('username');
      await db.deleteCustomQuestion(qId, username);
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ success: true, id: qId }));
    } catch (err) {
      res.writeHead(400, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ success: false, error: err.message }));
    }
    return;
  }

  // GET /api/quiz-test/:username
  if (url.pathname.startsWith('/api/quiz-test/') && req.method === 'GET') {
    try {
      const username = decodeURIComponent(url.pathname.replace('/api/quiz-test/', ''));
      const test = await db.getQuizTest(username);
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ success: true, questions: test }));
    } catch (err) {
      res.writeHead(400, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ success: false, error: err.message }));
    }
    return;
  }

  res.writeHead(404, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({ error: 'Endpoint bulunamadı' }));
});


// WebSocket Server
const wss = new WebSocketServer({ server });

wss.on('connection', (ws) => {
  let boundUsername = null;

  ws.on('message', async (messageStr) => {
    try {
      const msg = JSON.parse(messageStr);
      const { type } = msg;

      // 1. Authenticate WebSocket Connection
      if (type === 'auth') {
        const username = (msg.username || '').toLowerCase().trim();
        if (!username) return;

        const user = await db.getUserByUsername(username);
        if (!user) {
          ws.send(JSON.stringify({ type: 'error', message: 'Kullanıcı veritabanında bulunamadı.' }));
          return;
        }

        boundUsername = username;
        clients.set(username, ws);
        console.log(`[Online] Socket authenticated for @${username}`);

        // Fetch partner if exists
        let partner = null;
        if (user.partnerUsername) {
          const p = await db.getUserByUsername(user.partnerUsername);
          if (p) {
            partner = {
              ...p,
              isOnline: clients.has(p.username.toLowerCase())
            };
          }
        }

        // Fetch pending requests
        const incoming = await db.getIncomingRequests(username);
        const sent = await db.getSentRequests(username);

        ws.send(JSON.stringify({
          type: 'auth_success',
          user: {
            ...user,
            isOnline: true
          },
          partner,
          incomingRequests: incoming,
          sentRequests: sent
        }));

        // Notify partner that user is online
        if (user.partnerUsername) {
          sendToUser(user.partnerUsername, {
            type: 'partner_status',
            partnerUsername: user.username,
            isOnline: true
          });
        }
        return;
      }

      // 2. Update Profile (Username or Pet)
      if (type === 'update_profile') {
        if (!boundUsername) return;

        let currentUser = await db.getUserByUsername(boundUsername);
        if (!currentUser) return;

        // If updating username
        if (msg.newUsername && msg.newUsername.toLowerCase() !== boundUsername) {
          try {
            currentUser = await db.updateUsername(boundUsername, msg.newUsername);
            clients.delete(boundUsername);
            boundUsername = currentUser.username;
            clients.set(boundUsername, ws);
          } catch (err) {
            ws.send(JSON.stringify({ type: 'error', message: err.message }));
            return;
          }
        }

        // If updating pet
        if (msg.petType) {
          currentUser = await db.updatePet(boundUsername, msg.petType, msg.petName || currentUser.petName);
        }

        ws.send(JSON.stringify({
          type: 'profile_updated',
          user: currentUser
        }));

        // Notify partner
        if (currentUser.partnerUsername) {
          sendToUser(currentUser.partnerUsername, {
            type: 'partner_updated',
            partner: currentUser
          });
        }
        return;
      }

      // 2b. Update Avatar via WebSocket
      if (type === 'update_avatar') {
        if (!boundUsername) return;
        const customAvatarBase64 = msg.customAvatarBase64 || null;
        const updatedUser = await db.updateCustomAvatar(boundUsername, customAvatarBase64);
        ws.send(JSON.stringify({
          type: 'user_avatar_updated',
          user: updatedUser
        }));
        if (updatedUser && updatedUser.partnerUsername) {
          sendToUser(updatedUser.partnerUsername, {
            type: 'partner_avatar_updated',
            partner: updatedUser
          });
        }
        return;
      }

      // 3. Send Friend Request
      if (type === 'send_friend_request') {
        const fromUsername = boundUsername || (msg.fromUsername || '').trim().toLowerCase();
        if (!fromUsername) {
          console.warn('[WS] send_friend_request rejected: no fromUsername');
          ws.send(JSON.stringify({ type: 'error', message: 'Kullanıcı oturumu bulunamadı.' }));
          return;
        }
        const targetUsername = (msg.toUsername || '').trim().toLowerCase();
        console.log(`[WS] Handling friend request: @${fromUsername} -> @${targetUsername}`);

        try {
          const reqItem = await db.createFriendRequest(fromUsername, targetUsername);
          ws.send(JSON.stringify({
            type: 'request_sent',
            request: reqItem,
            message: `@${targetUsername} kullanıcısına arkadaşlık isteği gönderildi!`
          }));

          // Notify target if online
          const targetNotified = sendToUser(targetUsername, {
            type: 'friend_request_received',
            request: reqItem
          });
          console.log(`[WS] Friend request pushed to @${targetUsername}: ${targetNotified ? 'ONLINE' : 'OFFLINE'}`);
        } catch (err) {
          console.error(`[WS] Error sending friend request:`, err.message);
          ws.send(JSON.stringify({
            type: 'error',
            message: err.message
          }));
        }
        return;
      }

      // 4. Respond to Friend Request (Accept / Reject)
      if (type === 'respond_friend_request') {
        const currentUname = boundUsername || (msg.username || '').trim().toLowerCase();
        const { requestId, accept } = msg;

        const request = await db.getRequestById(requestId);
        if (!request) {
          ws.send(JSON.stringify({ type: 'error', message: 'İstek bulunamadı.' }));
          return;
        }

        if (accept) {
          await db.respondRequest(requestId, 'accepted');
          await db.pairUsers(request.from_username, request.to_username);

          const u1 = await db.getUserByUsername(request.from_username);
          const u2 = await db.getUserByUsername(request.to_username);

          // Notify accepting user
          ws.send(JSON.stringify({
            type: 'pair_success',
            user: currentUname === u1.username ? u1 : u2,
            partner: {
              ...(currentUname === u1.username ? u2 : u1),
              isOnline: clients.has(currentUname === u1.username ? u2.username : u1.username)
            },
            message: `@${currentUname === u1.username ? u2.username : u1.username} ile eşleştiniz! 💖`
          }));

          // Notify other user
          const otherUname = currentUname === u1.username ? u2.username : u1.username;
          sendToUser(otherUname, {
            type: 'pair_success',
            user: currentUname === u1.username ? u2 : u1,
            partner: {
              ...(currentUname === u1.username ? u1 : u2),
              isOnline: true
            },
            message: `@${currentUname} arkadaşlık isteğini kabul etti! 💖`
          });
        } else {
          await db.respondRequest(requestId, 'rejected');
          ws.send(JSON.stringify({
            type: 'request_rejected',
            requestId
          }));
          sendToUser(request.from_username, {
            type: 'request_rejected',
            requestId
          });
        }
        return;
      }

      // 5. Unpair Partner
      if (type === 'unpair_partner') {
        const currentUname = boundUsername || (msg.username || '').trim().toLowerCase();
        if (!currentUname) return;
        const user = await db.getUserByUsername(currentUname);
        if (user && user.partnerUsername) {
          const partnerUsername = user.partnerUsername;
          await db.unpairUsers(currentUname, partnerUsername);

          ws.send(JSON.stringify({
            type: 'unpair_success',
            message: 'Eşleşme sonlandırıldı.'
          }));

          sendToUser(partnerUsername, {
            type: 'unpair_success',
            message: `@${currentUname} eşleşmeyi sonlandırdı.`
          });
        }
        return;
      }

      // 6. Game Action (Multiplayer Moves / Quiz Sync & Ready Lobby)
      if (type === 'game_action') {
        if (!boundUsername) return;
        const user = await db.getUserByUsername(boundUsername);
        if (user && user.partnerUsername) {
          const partnerUname = user.partnerUsername.toLowerCase();

          // Handle player readiness in lobby
          if (msg.actionType === 'player_ready') {
            const isReady = !!(msg.actionData && msg.actionData.ready);
            lobbyReadyMap.set(boundUsername.toLowerCase(), isReady);
            console.log(`[Lobby] @${boundUsername} ready: ${isReady}`);

            // Send confirmation back to sender
            ws.send(JSON.stringify({
              type: 'remote_game_action',
              fromUsername: boundUsername,
              actionType: 'my_ready_status',
              actionData: { username: boundUsername, isReady }
            }));

            // Notify partner of my ready state
            sendToUser(partnerUname, {
              type: 'remote_game_action',
              fromUsername: boundUsername,
              actionType: 'partner_ready_status',
              actionData: { username: boundUsername, isReady }
            });

            // Check if BOTH players are now ready
            const partnerIsReady = !!lobbyReadyMap.get(partnerUname);
            if (isReady && partnerIsReady) {
              console.log(`[Lobby] Both @${boundUsername} and @${partnerUname} are READY! Starting synchronized 10-question game!`);
              lobbyReadyMap.delete(boundUsername.toLowerCase());
              lobbyReadyMap.delete(partnerUname);

              const testQuestions = await db.getQuizTest(boundUsername);

              const startPayload = {
                type: 'remote_game_action',
                fromUsername: 'system',
                actionType: 'start_synced_game',
                actionData: {
                  questions: testQuestions,
                  message: 'Her iki oyuncu da hazır! 10 soruluk yarışma başlıyor! 🎉'
                }
              };

              ws.send(JSON.stringify(startPayload));
              sendToUser(partnerUname, startPayload);
              return;
            }
            return;
          }

          if (msg.actionType === 'player_unready') {
            lobbyReadyMap.set(boundUsername.toLowerCase(), false);
            ws.send(JSON.stringify({
              type: 'remote_game_action',
              fromUsername: boundUsername,
              actionType: 'my_ready_status',
              actionData: { username: boundUsername, isReady: false }
            }));
            sendToUser(partnerUname, {
              type: 'remote_game_action',
              fromUsername: boundUsername,
              actionType: 'partner_ready_status',
              actionData: { username: boundUsername, isReady: false }
            });
            return;
          }

          // Relay all other game actions (quiz_round_input, quiz_seal, quiz_guess, quiz_next)
          const sent = sendToUser(partnerUname, {
            type: 'remote_game_action',
            fromUsername: boundUsername,
            actionType: msg.actionType,
            actionData: msg.actionData
          });
          if (!sent) {
            ws.send(JSON.stringify({
              type: 'info',
              message: 'Partneriniz şu an çevrimdışı, hamle iletilemedi.'
            }));
          }
        }
        return;
      }

    } catch (err) {
      console.error('[WS] Error processing message:', err);
      ws.send(JSON.stringify({ type: 'error', message: 'İşlem sırasında hata oluştu.' }));
    }
  });

  ws.on('close', async () => {
    if (boundUsername) {
      clients.delete(boundUsername);
      lobbyReadyMap.delete(boundUsername.toLowerCase());
      console.log(`[Online] Socket disconnected: @${boundUsername}`);

      const user = await db.getUserByUsername(boundUsername);
      if (user && user.partnerUsername) {
        sendToUser(user.partnerUsername, {
          type: 'partner_status',
          partnerUsername: boundUsername,
          isOnline: false
        });
      }
    }
  });
});

// Start Server
async function start() {
  await db.initDB();
  server.listen(PORT, '0.0.0.0', () => {
    console.log('===============================================');
    console.log('🐾 LoversCat SQL Online Server is running!');
    console.log(`🚀 Port: ${PORT}`);
    console.log(`🌐 Local:     http://localhost:${PORT}`);
    console.log(`🌐 Tailscale: Accessible via http://<YOUR_TAILSCALE_IP>:${PORT}`);
    console.log(`⚡ WebSocket: ws://localhost:${PORT}`);
    console.log('💾 Database:  SQLite (loverscat.sqlite)');
    console.log('===============================================');
  });
}

start();
