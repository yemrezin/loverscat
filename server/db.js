const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const crypto = require('crypto');

const DB_PATH = path.join(__dirname, 'loverscat.sqlite');
const db = new sqlite3.Database(DB_PATH);

// Helper to run query as Promise
function run(sql, params = []) {
  return new Promise((resolve, reject) => {
    db.run(sql, params, function (err) {
      if (err) reject(err);
      else resolve(this);
    });
  });
}

// Helper to get single row as Promise
function get(sql, params = []) {
  return new Promise((resolve, reject) => {
    db.get(sql, params, (err, row) => {
      if (err) reject(err);
      else resolve(row);
    });
  });
}

// Helper to get all rows as Promise
function all(sql, params = []) {
  return new Promise((resolve, reject) => {
    db.all(sql, params, (err, rows) => {
      if (err) reject(err);
      else resolve(rows);
    });
  });
}

// Username cleaner to handle leading @, casing, and spaces
function cleanUname(name) {
  return (name || '').trim().toLowerCase().replace(/^@+/, '');
}

// Initialize tables
async function initDB() {
  await run(`
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT UNIQUE NOT NULL COLLATE NOCASE,
      password_hash TEXT NOT NULL,
      pet_type TEXT NOT NULL DEFAULT 'cat',
      pet_name TEXT NOT NULL DEFAULT 'Mırmır',
      partner_username TEXT COLLATE NOCASE,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  `);

  await run(`
    CREATE TABLE IF NOT EXISTS friend_requests (
      id TEXT PRIMARY KEY,
      from_username TEXT NOT NULL COLLATE NOCASE,
      to_username TEXT NOT NULL COLLATE NOCASE,
      status TEXT NOT NULL DEFAULT 'pending',
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  `);

  await run(`
    CREATE TABLE IF NOT EXISTS custom_questions (
      id TEXT PRIMARY KEY,
      username TEXT NOT NULL COLLATE NOCASE,
      text TEXT NOT NULL,
      options_json TEXT NOT NULL,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  `);

  // Auto-migrate old db.json users if any
  try {
    const fs = require('fs');
    const dbJsonPath = path.join(__dirname, 'db.json');
    if (fs.existsSync(dbJsonPath)) {
      const raw = JSON.parse(fs.readFileSync(dbJsonPath, 'utf8'));
      const oldUsers = raw.users || {};
      for (const [key, val] of Object.entries(oldUsers)) {
        const u = cleanUname(val.username || key);
        if (u) {
          const exists = await get('SELECT id FROM users WHERE username = ?', [u]);
          if (!exists) {
            const pHash = hashPassword('password123');
            await run(
              'INSERT INTO users (username, password_hash, pet_type, pet_name) VALUES (?, ?, ?, ?)',
              [u, pHash, val.petType || 'cat', val.petName || 'Mırmır']
            );
            console.log(`[SQLite Migration] Imported @${u} from db.json`);
          }
        }
      }
    }
  } catch (err) {
    console.warn('[SQLite Migration] Note:', err.message);
  }

  // Ensure default demo users exist with user1 / user2 password as 'user'
  for (const demo of [
    { u: 'user1', pet: 'fox', name: 'Ateş', pass: 'user' },
    { u: 'user2', pet: 'cat', name: 'Mırmır', pass: 'user' },
    { u: 'ahmet', pet: 'cat', name: 'Mirmir', pass: 'password123' }
  ]) {
    const exists = await get('SELECT id FROM users WHERE username = ?', [demo.u]);
    const pHash = hashPassword(demo.pass);
    if (!exists) {
      await run(
        'INSERT INTO users (username, password_hash, pet_type, pet_name) VALUES (?, ?, ?, ?)',
        [demo.u, pHash, demo.pet, demo.name]
      );
      console.log(`[SQLite Seed] Created default user @${demo.u}`);
    } else if (demo.u === 'user1' || demo.u === 'user2') {
      await run(
        'UPDATE users SET password_hash = ? WHERE username = ?',
        [pHash, demo.u]
      );
      console.log(`[SQLite Seed] Updated password for @${demo.u} to '${demo.pass}'`);
    }
  }

    // Ensure custom_avatar column exists
    try {
      await run('ALTER TABLE users ADD COLUMN custom_avatar TEXT');
    } catch (_) {}

    // Ensure type column exists in custom_questions
    try {
      await run("ALTER TABLE custom_questions ADD COLUMN type TEXT DEFAULT 'multipleChoice'");
    } catch (_) {}

    console.log('[SQLite] Database and tables initialized at:', DB_PATH);
  }

  // Password hashing
  function hashPassword(password) {
    const salt = crypto.randomBytes(16).toString('hex');
    const hash = crypto.pbkdf2Sync(password, salt, 1000, 64, 'sha512').toString('hex');
    return `${salt}:${hash}`;
  }

  function verifyPassword(password, storedHash) {
    if (!storedHash) return false;
    const parts = storedHash.split(':');
    if (parts.length !== 2) return false;
    const [salt, originalHash] = parts;
    const hash = crypto.pbkdf2Sync(password, salt, 1000, 64, 'sha512').toString('hex');
    return hash === originalHash;
  }

  // Format user row for client
  function formatUser(row) {
    if (!row) return null;
    return {
      username: row.username,
      displayName: row.username, // Username is the only display name now
      petType: row.pet_type || 'cat',
      petName: row.pet_name || 'Mırmır',
      partnerUsername: row.partner_username || null,
      customAvatarBase64: row.custom_avatar || null,
      createdAt: row.created_at
    };
  }

// User methods
async function registerUser({ username, password, petType = 'cat', petName = 'Mırmır' }) {
  const cleanUsername = cleanUname(username);
  if (!cleanUsername || cleanUsername.length < 3) {
    throw new Error('Kullanıcı adı en az 3 karakter olmalıdır.');
  }
  if (!password || password.length < 4) {
    throw new Error('Şifre en az 4 karakter olmalıdır.');
  }

  // Check if username already exists
  const existing = await get('SELECT id FROM users WHERE username = ?', [cleanUsername]);
  if (existing) {
    throw new Error(`@${cleanUsername} kullanıcı adı zaten alınmış!`);
  }

  const pHash = hashPassword(password);
  await run(
    'INSERT INTO users (username, password_hash, pet_type, pet_name) VALUES (?, ?, ?, ?)',
    [cleanUsername, pHash, petType, petName]
  );

  return await getUserByUsername(cleanUsername);
}

async function loginUser({ username, password }) {
  const cleanUsername = cleanUname(username);
  if (!cleanUsername || !password) {
    throw new Error('Kullanıcı adı ve şifre gereklidir.');
  }

  const row = await get('SELECT * FROM users WHERE username = ?', [cleanUsername]);
  if (!row) {
    throw new Error('Kullanıcı adı veya şifre hatalı!');
  }

  const isValid = verifyPassword(password, row.password_hash);
  if (!isValid) {
    throw new Error('Kullanıcı adı veya şifre hatalı!');
  }

  return formatUser(row);
}

async function getUserByUsername(username) {
  const clean = cleanUname(username);
  const row = await get('SELECT * FROM users WHERE username = ?', [clean]);
  return formatUser(row);
}

async function updatePet(username, petType, petName) {
  const clean = cleanUname(username);
  await run(
    'UPDATE users SET pet_type = ?, pet_name = ?, updated_at = CURRENT_TIMESTAMP WHERE username = ?',
    [petType, petName, clean]
  );
  return await getUserByUsername(clean);
}

async function updateCustomAvatar(username, base64) {
  const clean = cleanUname(username);
  await run(
    'UPDATE users SET custom_avatar = ?, updated_at = CURRENT_TIMESTAMP WHERE username = ?',
    [base64 || null, clean]
  );
  return await getUserByUsername(clean);
}

async function updateUsername(oldUsername, newUsername) {
  const cleanOld = cleanUname(oldUsername);
  const cleanNew = cleanUname(newUsername);

  if (!cleanNew || cleanNew.length < 3) {
    throw new Error('Yeni kullanıcı adı en az 3 karakter olmalıdır.');
  }

  if (cleanOld === cleanNew) {
    return await getUserByUsername(cleanOld);
  }

  const existing = await get('SELECT id FROM users WHERE username = ?', [cleanNew]);
  if (existing) {
    throw new Error(`@${cleanNew} kullanıcı adı zaten alınmış!`);
  }

  await run('UPDATE users SET username = ?, updated_at = CURRENT_TIMESTAMP WHERE username = ?', [cleanNew, cleanOld]);
  await run('UPDATE users SET partner_username = ? WHERE partner_username = ?', [cleanNew, cleanOld]);
  await run('UPDATE friend_requests SET from_username = ? WHERE from_username = ?', [cleanNew, cleanOld]);
  await run('UPDATE friend_requests SET to_username = ? WHERE to_username = ?', [cleanNew, cleanOld]);

  return await getUserByUsername(cleanNew);
}

async function pairUsers(u1, u2) {
  const clean1 = cleanUname(u1);
  const clean2 = cleanUname(u2);

  await run('UPDATE users SET partner_username = ? WHERE username = ?', [clean2, clean1]);
  await run('UPDATE users SET partner_username = ? WHERE username = ?', [clean1, clean2]);
}

async function unpairUsers(u1, u2) {
  const clean1 = cleanUname(u1);
  const clean2 = cleanUname(u2);

  await run('UPDATE users SET partner_username = NULL WHERE username IN (?, ?)', [clean1, clean2]);
}

async function listUsers() {
  const rows = await all('SELECT username, pet_type, pet_name, partner_username, created_at FROM users');
  return rows.map(formatUser);
}

// Friend Request methods
async function createFriendRequest(fromUser, toUser) {
  const cleanFrom = cleanUname(fromUser);
  const cleanTo = cleanUname(toUser);

  if (cleanFrom === cleanTo) {
    throw new Error('Kendinize arkadaşlık isteği gönderemezsiniz!');
  }

  const target = await getUserByUsername(cleanTo);
  if (!target) {
    throw new Error(`@${cleanTo} kullanıcı adına sahip bir oyuncu bulunamadı.`);
  }

  const sender = await getUserByUsername(cleanFrom);
  if (sender && sender.partnerUsername === cleanTo) {
    throw new Error(`Zaten @${cleanTo} ile eşleşmiş durumdasınız!`);
  }

  // Check if pending request already exists
  const existing = await get(
    'SELECT * FROM friend_requests WHERE from_username = ? AND to_username = ? AND status = "pending"',
    [cleanFrom, cleanTo]
  );
  if (existing) {
    throw new Error('Bu kullanıcıya zaten bekleyen bir istek gönderdiniz.');
  }

  const id = `req_${Date.now()}_${Math.floor(Math.random() * 1000)}`;
  await run(
    'INSERT INTO friend_requests (id, from_username, to_username, status) VALUES (?, ?, ?, "pending")',
    [id, cleanFrom, cleanTo]
  );

  return {
    id,
    fromUsername: cleanFrom,
    fromDisplayName: cleanFrom,
    fromPetType: sender ? sender.petType : 'cat',
    fromPetName: sender ? sender.petName : 'Mırmır',
    toUsername: cleanTo,
    status: 'pending',
    createdAt: new Date().toISOString()
  };
}

async function getIncomingRequests(username) {
  const clean = cleanUname(username);
  const rows = await all(`
    SELECT r.id, r.from_username, r.to_username, r.status, r.created_at,
           u.pet_type as from_pet_type, u.pet_name as from_pet_name
    FROM friend_requests r
    LEFT JOIN users u ON r.from_username = u.username
    WHERE r.to_username = ? AND r.status = 'pending'
    ORDER BY r.created_at DESC
  `, [clean]);

  return rows.map(r => ({
    id: r.id,
    fromUsername: r.from_username,
    fromDisplayName: r.from_username,
    fromPetType: r.from_pet_type || 'cat',
    fromPetName: r.from_pet_name || 'Mırmır',
    toUsername: r.to_username,
    status: r.status,
    createdAt: r.created_at
  }));
}

async function getSentRequests(username) {
  const clean = cleanUname(username);
  const rows = await all(
    'SELECT * FROM friend_requests WHERE from_username = ? AND status = "pending" ORDER BY created_at DESC',
    [clean]
  );
  return rows.map(r => ({
    id: r.id,
    fromUsername: r.from_username,
    fromDisplayName: r.from_username,
    fromPetType: 'cat',
    fromPetName: 'Mırmır',
    toUsername: r.to_username,
    status: r.status,
    createdAt: r.created_at
  }));
}

async function getRequestById(id) {
  return await get('SELECT * FROM friend_requests WHERE id = ?', [id]);
}

async function updatePassword(username, newPassword) {
  const clean = cleanUname(username);
  const pHash = hashPassword(newPassword);
  await run(
    'UPDATE users SET password_hash = ?, updated_at = CURRENT_TIMESTAMP WHERE username = ?',
    [pHash, clean]
  );
  return await getUserByUsername(clean);
}

async function respondRequest(id, status) {
  await run('UPDATE friend_requests SET status = ? WHERE id = ?', [status, id]);
}

// --- Custom Questions & 10-Question Test Generator ---

const defaultQuizQuestions = [
  {
    id: 'default_1',
    text: 'Pazar sabahı uyandığında sevgilinin ilk yapmak isteyeceği şey nedir?',
    type: 'multipleChoice',
    options: [
      'Sıcacık bir kahve yapıp battaniyeye sarılmak ☕',
      'Öğlene kadar yatakta dönüp uyumaya devam etmek 😴',
      'Mükellef bir kahvaltı hazırlamak 🍳',
      'Hemen üstünü giyinip dışarı yürüyüşe çıkmak 👟'
    ],
    isCustom: false
  },
  {
    id: 'default_2',
    text: 'Sevgilin sinirlendiğinde onu en hızlı ne sakinleştirir?',
    type: 'multipleChoice',
    options: [
      'Sevdiği tatlıyı/yemeği önüne koymak 🍰',
      'Sessizce sarılıp saçını okşamak 🫂',
      'Biraz kendi haline bırakıp alan tanımak 🧘',
      'Komik kedi videoları açıp güldürmeye çalışmak 🐱'
    ],
    isCustom: false
  },
  {
    id: 'default_3',
    text: 'Birlikte tatile çıksanız onun hayalindeki tatil hangisi olurdu?',
    type: 'multipleChoice',
    options: [
      'Deniz kenarında sakin bir butik otel ve gün batımı 🌅',
      'Doğanın içinde ahşap dağ evi ve şömine başı 🪵',
      'Avrupa sokaklarında günde 20.000 adım keşif turu ✈️',
      'Her şey dahil otelde şezlongdan kalkmama keyfi 🍹'
    ],
    isCustom: false
  },
  {
    id: 'default_4',
    text: 'Akşam birlikte izleyecek bir şey ararken onun ilk tercihi ne olur?',
    type: 'multipleChoice',
    options: [
      'Sürükleyici bir suç/gizem dizisi 🕵️‍♂️',
      'Romantik komedi veya iç ısıtan film 🍿',
      'Nostaljik Harry Potter veya Yüzüklerin Efendisi maratonu 🧙‍♂️',
      'Gülmekten karnımızı ağrıtacak bir sit-com 📺'
    ],
    isCustom: false
  },
  {
    id: 'default_5',
    text: 'Issız bir adaya düşsek onun en çok özleyeceği şey ne olurdu?',
    type: 'multipleChoice',
    options: [
      'Kesintisiz hızlı internet ve telefonu 📱',
      'Sıcak duş ve yumuşacık yatağı 🛏️',
      'Kahve ve tatlı krizleri 🍫',
      'Kendi kendine kaldığı sessiz anlar 🌙'
    ],
    isCustom: false
  },
  {
    id: 'default_6',
    text: 'Beklenmedik bir hediye alacak olsa hangisi onu mutluluktan havalara uçurur?',
    type: 'multipleChoice',
    options: [
      'Uzun zamandır istediği bir giysi veya ayakkabı 👗',
      'Birlikte gideceğiniz konser veya tiyatro bileti 🎟️',
      'El yazısıyla yazılmış samimi ve romantik bir mektup 💌',
      'En sevdiği restoranda baş başa bir akşam yemeği 🍝'
    ],
    isCustom: false
  },
  {
    id: 'default_7',
    text: 'Yağmurlu bir günde evde vakit geçirirken hangisini seçer?',
    type: 'multipleChoice',
    options: [
      'Sıcak çikolata eşliğinde kitap okumak 📚',
      'Birlikte mutfağa girip kurabiye veya kek pişirmek 🍪',
      'Kutu oyunları veya konsolda oyun oynamak 🎮',
      'Yağmur sesini dinleyerek battaniye altında kestirmek 🌧️'
    ],
    isCustom: false
  },
  {
    id: 'default_8',
    text: 'Bir süper gücü olsaydı hangisini kesinlikle isterdi?',
    type: 'multipleChoice',
    options: [
      'Zamanı geri alabilmek veya durdurabilmek ⏳',
      'İstediği an istediği yere ışınlanmak 🛸',
      'Zihinleri okuyabilmek 🧠',
      'Görünmez olabilmek 👻'
    ],
    isCustom: false
  },
  {
    id: 'default_9',
    text: 'Onun en büyük gizli zevki (guilty pleasure) hangisidir?',
    type: 'multipleChoice',
    options: [
      'Gece yarısı gizlice buzdolabını yağmalamak 🥪',
      'Sosyal medyada eski tanıdıkları stalklamak 🔍',
      'Aşırı dramatik reality şovlar izlemek 📺',
      'Ayna karşısında kendi kendine konser vermek 🎤'
    ],
    isCustom: false
  },
  {
    id: 'default_10',
    text: 'Birlikte geçirdiğimiz zamanın en güzel ve değerli anı sence hangisi?',
    type: 'multipleChoice',
    options: [
      'İlk buluştuğumuz o heyecanlı ilk an 💫',
      'Saatlerce hiçbir şey yapmadan sadece sarılıp sohbet ettiğimiz anlar 🛋️',
      'Birlikte gülme krizine girdiğimiz çılgın anlar 😂',
      'Birbirimizin elini tutup zorlukları aştığımız anlar 🤝'
    ],
    isCustom: false
  }
];

async function createCustomQuestion({ username, text, type = 'multipleChoice', options = [] }) {
  const clean = cleanUname(username);
  if (!clean) throw new Error('Kullanıcı adı gereklidir.');
  if (!text || !text.trim()) throw new Error('Soru metni boş olamaz.');

  const qType = type === 'openEnded' ? 'openEnded' : 'multipleChoice';
  let cleanOptions = [];

  if (qType === 'multipleChoice') {
    if (!options || !Array.isArray(options) || options.length < 2) {
      throw new Error('Çoktan seçmeli sorular için en az 2 şık (seçenek) girmelisiniz.');
    }
    cleanOptions = options.map(o => String(o).trim()).filter(o => o.length > 0);
    if (cleanOptions.length < 2) {
      throw new Error('Geçerli seçenek sayısı yetersiz.');
    }
  }

  // Enforce MAX 5 questions rule per user
  const countRow = await get('SELECT COUNT(*) as cnt FROM custom_questions WHERE username = ?', [clean]);
  if (countRow && countRow.cnt >= 5) {
    throw new Error('Her kullanıcı en fazla 5 soru ekleyebilir!');
  }

  const id = `custom_${Date.now()}_${Math.floor(Math.random() * 1000)}`;

  await run(
    'INSERT INTO custom_questions (id, username, text, type, options_json) VALUES (?, ?, ?, ?, ?)',
    [id, clean, text.trim(), qType, JSON.stringify(cleanOptions)]
  );

  return {
    id,
    text: text.trim(),
    type: qType,
    options: cleanOptions,
    isCustom: true,
    author: clean
  };
}

async function getCustomQuestions(username) {
  const clean = cleanUname(username);
  const rows = await all(
    'SELECT * FROM custom_questions WHERE username = ? ORDER BY created_at ASC',
    [clean]
  );
  return rows.map(r => ({
    id: r.id,
    text: r.text,
    type: r.type || ((!r.options_json || r.options_json === '[]') ? 'openEnded' : 'multipleChoice'),
    options: JSON.parse(r.options_json || '[]'),
    isCustom: true,
    author: r.username
  }));
}

async function deleteCustomQuestion(id, username) {
  const clean = cleanUname(username);
  await run('DELETE FROM custom_questions WHERE id = ? AND username = ?', [id, clean]);
}

/**
 * Generates exactly 10 questions for the couple:
 * - Up to 5 from User
 * - Up to 5 from Partner (if paired)
 * - Remainder filled by defaultQuizQuestions
 */
async function getQuizTest(username) {
  const clean = cleanUname(username);
  const user = await getUserByUsername(clean);

  const userQuestions = (await getCustomQuestions(clean)).slice(0, 5);
  let partnerQuestions = [];

  if (user && user.partnerUsername) {
    partnerQuestions = (await getCustomQuestions(user.partnerUsername)).slice(0, 5);
  }

  const combinedCustom = [...userQuestions, ...partnerQuestions];
  const totalCustom = combinedCustom.length;

  const result = [...combinedCustom];

  // Fill deficit up to 10 from default questions
  const needed = 10 - totalCustom;
  if (needed > 0) {
    for (let i = 0; i < defaultQuizQuestions.length && result.length < 10; i++) {
      const defQ = defaultQuizQuestions[i];
      if (!result.some(q => q.id === defQ.id)) {
        result.push(defQ);
      }
    }
  }

  return result.slice(0, 10);
}

module.exports = {
  initDB,
  registerUser,
  loginUser,
  getUserByUsername,
  updatePet,
  updateCustomAvatar,
  updateUsername,
  updatePassword,
  pairUsers,
  unpairUsers,
  listUsers,
  createFriendRequest,
  getIncomingRequests,
  getSentRequests,
  getRequestById,
  respondRequest,
  defaultQuizQuestions,
  createCustomQuestion,
  getCustomQuestions,
  deleteCustomQuestion,
  getQuizTest
};

