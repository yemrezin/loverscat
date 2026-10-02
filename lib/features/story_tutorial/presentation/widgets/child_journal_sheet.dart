import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../map/presentation/controllers/map_providers.dart';
import '../../../minigames/domain/models/child_memory_item.dart';

/// Modal bottom sheet showcasing the child's 10 nostalgic memory items
/// recovered as the couple advances through the 10 islands.
class ChildJournalSheet extends ConsumerWidget {
  const ChildJournalSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ChildJournalSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapState = ref.watch(mapGameProvider);
    final currentIsland = mapState.currentIsland;
    const items = ChildMemoryItem.default10IslandItems;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.backgroundWarm,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          const Row(
            children: [
              Text('🎒', style: TextStyle(fontSize: 24)),
              SizedBox(width: 8),
              Text(
                'Çocuğunuzun Hatıra Defteri',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Adalarda düşürdüğü izleri toplayın ($currentIsland/10 Ada Gezildi)',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),

          // Item List
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = items[index];
                final isReached = item.islandNumber <= currentIsland;

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isReached
                          ? AppColors.player1Badge.withOpacity(0.4)
                          : AppColors.borderSubtle,
                      width: isReached ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isReached
                              ? AppColors.pastelYellow.withOpacity(0.6)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          isReached ? item.itemIcon : '🔒',
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${item.islandNumber}. Ada: ${item.islandName}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isReached ? AppColors.player1Badge : AppColors.textSecondary,
                                  ),
                                ),
                                if (isReached)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.successGreen.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'Bulundu ✨',
                                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.successGreen),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isReached ? item.itemName : 'Gizemli Hatıra Eşyası',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isReached ? AppColors.textPrimary : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isReached ? item.emotionalDescription : 'Bu adaya ulaştığınızda çocuğunuzun izi ortaya çıkacak.',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
