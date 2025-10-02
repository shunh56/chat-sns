/*import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/user_icon.dart';
import 'package:app/presentation/pages/community_screen/model/community.dart';
import 'package:app/presentation/providers/provider/users/all_users_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gap/gap.dart';

// 編集中のコミュニティ状態を管理するプロバイダー
final editingCommunityProvider =
    StateNotifierProvider<EditingCommunityNotifier, Community?>((ref) {
  return EditingCommunityNotifier(null);
});

class EditingCommunityNotifier extends StateNotifier<Community?> {
  EditingCommunityNotifier(Community? community) : super(null);

  init(Community community) {
    state = community;
  }

  void updateName(String name) {
    state = state?.copyWith(
      name: name,
      updatedAt: Timestamp.now(),
    );
  }

  void updateDescription(String description) {
    state = state?.copyWith(
      description: description,
      updatedAt: Timestamp.now(),
    );
  }

  void updateRules(List<String> rules) {
    state = state?.copyWith(
      rules: rules,
      updatedAt: Timestamp.now(),
    );
  }

  void addModerator(String userId) {
    if (!state!.moderators.contains(userId)) {
      state = state?.copyWith(
        moderators: [...state!.moderators, userId],
        updatedAt: Timestamp.now(),
      );
    }
  }

  void removeModerator(String userId) {
    state = state?.copyWith(
      moderators: state!.moderators.where((id) => id != userId).toList(),
      updatedAt: Timestamp.now(),
    );
  }
}

class CommunityManagementScreen extends ConsumerStatefulWidget {
  const CommunityManagementScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CommunityManagementScreenState();
}

class _CommunityManagementScreenState
    extends ConsumerState<CommunityManagementScreen> {
  bool _hasChanges = false;

  @override
  Widget build(BuildContext context) {
    final themeSize = ref.watch(themeSizeProvider(context));
    return Scaffold(
      appBar: AppBar(
        title: const Text('コミュニティ管理'),
        actions: [
          if (_hasChanges)
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: ThemeColor.stroke),
              onPressed: _saveChanges,
              child: const Text('変更を保存'),
            ),
        ],
      ),
      body: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            TabBar(
              isScrollable: true,
              padding: EdgeInsets.symmetric(
                  horizontal: themeSize.horizontalPadding - 4),
              indicator: BoxDecoration(
                color: ThemeColor.button,
                borderRadius: BorderRadius.circular(100),
              ),
              tabAlignment: TabAlignment.start,
              indicatorPadding: const EdgeInsets.only(
                left: 4,
                right: 4,
                top: 5,
                bottom: 7,
              ),
              labelPadding: const EdgeInsets.symmetric(horizontal: 24),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: ThemeColor.background,
              unselectedLabelColor: Colors.white.withOpacity(0.3),
              dividerColor: ThemeColor.background,
              splashFactory: NoSplash.splashFactory,
              overlayColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
                  // Use the default focused overlay color
                  return states.contains(WidgetState.focused)
                      ? null
                      : Colors.transparent;
                },
              ),
              tabs: const [
                Tab(text: '基本情報'),
                Tab(text: 'ルール'),
                Tab(text: 'モデレーター'),
                Tab(text: '統計'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _BasicInfoTab(
                      onChanged: () => setState(() => _hasChanges = true)),
                  _RulesTab(
                      onChanged: () => setState(() => _hasChanges = true)),
                  _ModeratorsTab(
                      onChanged: () => setState(() => _hasChanges = true)),
                  const _StatisticsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    //ref.read(communityUsecaseProvider)
  }
}

class _BasicInfoTab extends ConsumerWidget {
  const _BasicInfoTab({required this.onChanged});
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final community = ref.watch(editingCommunityProvider);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _EditableTextField(
          label: 'コミュニティ名',
          initialValue: community!.name,
          onChanged: (value) {
            ref.read(editingCommunityProvider.notifier).updateName(value);
            onChanged();
          },
        ),
        const SizedBox(height: 16),
        _EditableTextField(
          label: '説明',
          initialValue: community.description,
          maxLines: 5,
          onChanged: (value) {
            ref
                .read(editingCommunityProvider.notifier)
                .updateDescription(value);
            onChanged();
          },
        ),
      ],
    );
  }
}

class _RulesTab extends ConsumerWidget {
  const _RulesTab({required this.onChanged});
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final community = ref.watch(editingCommunityProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...community!.rules.asMap().entries.map(
              (entry) => Card(
                color: ThemeColor.stroke,
                child: ListTile(
                  title: Text('ルール ${entry.key + 1}'),
                  subtitle: Text(entry.value),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () =>
                        _editRule(context, ref, entry.key, entry.value),
                  ),
                ),
              ),
            ),
        const SizedBox(height: 16),
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: ThemeColor.stroke),
          onPressed: () => _addRule(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('ルールを追加'),
        ),
      ],
    );
  }

  Future<void> _editRule(BuildContext context, WidgetRef ref, int index,
      String currentRule) async {
    // ルール編集ダイアログを表示
  }

  Future<void> _addRule(BuildContext context, WidgetRef ref) async {
    // 新規ルール追加ダイアログを表示
  }
}

class _ModeratorsTab extends ConsumerWidget {
  const _ModeratorsTab({required this.onChanged});
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final community = ref.watch(editingCommunityProvider);

    return FutureBuilder(
        future: ref
            .read(allUsersNotifierProvider.notifier)
            .getUserAccounts(community!.moderators),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox();
          final users = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ...users.map(
                (user) => Card(
                  color: ThemeColor.stroke,
                  child: ListTile(
                    title: Row(
                      children: [
                        UserIcon(
                          user: user,
                          width: 48,
                        ),
                        const Gap(12),
                        Text(user.name),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        ref
                            .read(editingCommunityProvider.notifier)
                            .removeModerator(user.userId);
                        onChanged();
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                style:
                    FilledButton.styleFrom(backgroundColor: ThemeColor.stroke),
                onPressed: () => _addModerator(context, ref),
                icon: const Icon(Icons.add),
                label: const Text('モデレーターを追加'),
              ),
            ],
          );
        });
  }

  Future<void> _addModerator(BuildContext context, WidgetRef ref) async {
    // モデレーター追加画面を表示
  }
}

class _StatisticsTab extends ConsumerWidget {
  const _StatisticsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final community = ref.watch(editingCommunityProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _StatCard(
          title: 'メンバー統計',
          items: [
            _StatItem('総メンバー数', community!.memberCount),
            _StatItem('日間アクティブユーザー', community.dailyActiveUsers),
            _StatItem('週間アクティブユーザー', community.weeklyActiveUsers),
            _StatItem('月間アクティブユーザー', community.monthlyActiveUsers),
            if (community.dailyNewMembers != null)
              _StatItem('日間新規メンバー', community.dailyNewMembers!),
          ],
        ),
        const SizedBox(height: 16),
        _StatCard(
          title: 'アクティビティ統計',
          items: [
            _StatItem('総投稿数', community.totalPosts),
            _StatItem('日間投稿数', community.dailyPosts),
            _StatItem('トピックの数', community.topicsCount),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.items});
  final String title;
  final List<_StatItem> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: ThemeColor.stroke,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.label),
                      Text(
                        item.value.toString(),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _StatItem {
  const _StatItem(this.label, this.value);
  final String label;
  final int value;
}

class _EditableTextField extends StatelessWidget {
  const _EditableTextField({
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.maxLines = 1,
  });

  final String label;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          maxLines: maxLines,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
 */
