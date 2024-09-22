import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/pages/profile_page/profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final selectedtagsStateProvider = StateProvider<List<String>>((ref) => []);

class EditTagsScreen extends HookConsumerWidget {
  const EditTagsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSize = ref.watch(themeSizeProvider(context));
    final currentStatus = ref.watch(currentStatusStateProvider);
    final currentStatusNotifier =
        ref.watch(currentStatusStateProvider.notifier);
    final searchText = useState('');
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "タグを編集",
        ),
        actions: [
          GestureDetector(
            onTap: () {
              if (ref.watch(selectedtagsStateProvider).length < 3) {
                showMessage("タグは３つ以上選択してください");
                return;
              }
              currentStatusNotifier.state = currentStatus.copyWith(
                  tags: ref.watch(selectedtagsStateProvider));

              Navigator.pop(context);
            },
            child: const Text(
              "変更する",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Gap(themeSize.horizontalPadding),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(24),
              const Text(
                "選択中のタグ",
                style: TextStyle(
                  fontSize: 14,
                  color: ThemeColor.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(8),
              Wrap(
                children: ref
                    .watch(selectedtagsStateProvider)
                    .map(
                      (tag) => GestureDetector(
                        onTap: () {
                          final list = ref
                              .watch(selectedtagsStateProvider)
                              .where((item) => item != tag)
                              .toList();

                          ref.read(selectedtagsStateProvider.notifier).state =
                              list;
                        },
                        child: Container(
                          margin: const EdgeInsets.only(
                            right: 8,
                            bottom: 8,
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Colors.black.withOpacity(0.3)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                tag,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Icon(
                                Icons.close,
                                color: ThemeColor.icon,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const Gap(24),
              TextFormField(
                initialValue: '',
                keyboardType: TextInputType.multiline,
                maxLength: 20,
                style: const TextStyle(
                  fontSize: 16,
                  color: ThemeColor.text,
                ),
                onChanged: (value) {
                  if (value.isEmpty) {
                    searchText.value = value;
                  }
                },
                onFieldSubmitted: (value) {
                  searchText.value = value;
                },
                decoration: InputDecoration(
                  hintText: "2000's",
                  filled: true,
                  isDense: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintStyle: const TextStyle(
                    fontSize: 16,
                    color: ThemeColor.beige,
                    fontWeight: FontWeight.w400,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),
                ),
              ),
              searchText.value.isNotEmpty
                  ? FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection("tags")
                          .where(
                            "name",
                            isGreaterThanOrEqualTo: searchText.value,
                            isLessThan: searchText.value
                                    .substring(0, searchText.value.length - 1) +
                                String.fromCharCode(searchText.value.codeUnitAt(
                                        searchText.value.length - 1) +
                                    1),
                          )
                          .get(),
                      builder: (context, snapshot) {
                        final text = searchText.value;
                        if (!snapshot.hasData) {
                          return const SizedBox();
                        }
                        final query = snapshot.data!;
                        //もしもない場合
                        if (query.docs.isEmpty) {
                          final item = generateTagData(text, generate: true);
                          if (ref
                              .watch(selectedtagsStateProvider)
                              .contains(text)) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 8),
                                  child: Text(
                                    "検索結果",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: ThemeColor.text,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const Gap(12),
                                _buildTag(ref, item["name"], id: item["id"]),
                              ],
                            );
                          } else {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 8),
                                  child: Text(
                                    "検索結果",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: ThemeColor.text,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const Gap(12),
                                _buildTag(ref, searchText.value),
                              ],
                            );
                          }
                        } else {
                          //ある場合
                          final list =
                              query.docs.map((doc) => doc.data()).toList();

                          if (!list
                              .map((item) => item["name"])
                              .contains(text)) {
                            list.add(generateTagData(searchText.value));
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Text(
                                  "検索結果",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: ThemeColor.text,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Gap(12),
                              Wrap(
                                children: list.map((item) {
                                  final String id = item["id"];
                                  final String tag = item["name"];

                                  if (ref
                                      .watch(selectedtagsStateProvider)
                                      .contains(tag)) {
                                    return _buildSelectedTag(tag);
                                  } else {
                                    return _buildTag(ref, tag, id: id);
                                  }
                                }).toList(),
                              ),
                            ],
                          );
                        }
                      },
                    )
                  : FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection("tags")
                          .orderBy('selectedCount', descending: true)
                          .limit(30)
                          .get(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox();
                        }
                        final query = snapshot.data!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: Text(
                                "人気のタグ",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: ThemeColor.text,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Gap(12),
                            Wrap(
                              children: query.docs.map((doc) {
                                final String id = doc.id;
                                final String tag = doc.data()["name"];
                                if (ref
                                    .watch(selectedtagsStateProvider)
                                    .contains(tag)) {
                                  return _buildSelectedTag(tag);
                                } else {
                                  return _buildTag(ref, tag, id: id);
                                }
                              }).toList(),
                            ),
                          ],
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> generateTagData(String tag, {bool generate = false}) {
    final String id = FirebaseFirestore.instance.collection("tags").doc().id;
    final json = {
      "id": id,
      "name": tag,
      "searchCount": 1,
      "selectedCount": 0,
      "createdAt": Timestamp.now(),
    };
    if (generate) {
      addTagToFirestore(json);
    }
    return json;
  }

  addTagToFirestore(Map<String, dynamic> json) async {
    final q = await FirebaseFirestore.instance
        .collection("tags")
        .where("name", isEqualTo: json["name"])
        .get();
    if (q.docs.isEmpty) {
      FirebaseFirestore.instance.collection("tags").doc(json["id"]).set(json);
    }
  }

  incrementSelectCount(String id) async {
    FirebaseFirestore.instance.collection("tags").doc(id).update({
      "selectedCount": FieldValue.increment(1),
      "updatedAt": Timestamp.now(),
    });
  }

  Widget _buildSelectedTag(String tag) {
    return Container(
      margin: const EdgeInsets.only(
        right: 8,
        bottom: 8,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Colors.black.withOpacity(0.3)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Icon(
            Icons.check,
            color: ThemeColor.icon,
          ),
        ],
      ),
    );
  }

  Widget _buildTag(WidgetRef ref, String tag, {String? id}) {
    return GestureDetector(
      onTap: () {
        if (ref.read(selectedtagsStateProvider).length >= 5) {
          showMessage("タグは最大で5つまで選択できます。");
          return;
        }
        if (id != null) {
          incrementSelectCount(id);
        }
        ref.read(selectedtagsStateProvider.notifier).state = [
          ...ref.watch(selectedtagsStateProvider),
          tag
        ];
      },
      child: Container(
        margin: const EdgeInsets.only(
          right: 8,
          bottom: 8,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: Colors.black.withOpacity(0.3)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tag,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Icon(
              Icons.add,
              color: ThemeColor.icon,
            ),
          ],
        ),
      ),
    );
  }
}
