import 'package:app/core/utils/theme.dart';
import 'package:app/presentation/components/core/shader.dart';
import 'package:app/presentation/components/core/snackbar.dart';
import 'package:app/presentation/providers/notifier/image/image_processor.dart';
import 'package:app/presentation/providers/provider/users/my_user_account_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

import 'package:gap/gap.dart';

final usernameProvider = StateProvider<String>((ref) => '');
final nameProvider = StateProvider<String>((ref) => '');
final imageProvider = StateProvider<File?>((ref) => null);
//final genderProvider = StateProvider<Gender>((ref) => Gender.male);
final currentStepProvider = StateProvider<int>((ref) => -1);

final creatingProcessProvider = StateProvider.autoDispose((ref) => false);

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStep = ref.watch(currentStepProvider);
    init() async {
      if (ref.watch(currentStepProvider) == -1) {
        await Future.delayed(const Duration(milliseconds: 30));
        ref.watch(currentStepProvider.notifier).state = 0;
      }
    }

    init();
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeMessage(ref),
                    const SizedBox(height: 32),
                    if (currentStep >= 0) _buildUsernameInput(ref),
                    if (currentStep >= 1) _buildNameInput(ref),
                    if (currentStep >= 2) _buildImageUpload(ref),
                    //if (currentStep >= 2) _buildGenderSelection(ref),
                    if (currentStep >= 3)
                      _buildCreateAccountButton(context, ref),
                  ],
                ),
              ),
            ),
          ),
          AnimatedOpacity(
            opacity: ref.watch(creatingProcessProvider) ? 1 : 0,
            duration: const Duration(milliseconds: 400),
            child: Visibility(
              visible: ref.watch(creatingProcessProvider),
              child: ShaderWidget(
                child: Container(
                  width: MediaQuery.sizeOf(context).width,
                  height: MediaQuery.sizeOf(context).height,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "アカウント作成中",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Gap(12),
                      CircularProgressIndicator(
                        strokeWidth: 1.2,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeMessage(WidgetRef ref) {
    return AnimatedOpacity(
      opacity: ref.watch(currentStepProvider) >= 0 ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      onEnd: () {
        if (ref.read(currentStepProvider) == 0) {
          ref.read(currentStepProvider.notifier).state = 1;
        }
      },
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ようこそ○○へ',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            'アカウントを作成して、新しい世界を探索しましょう。',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildUsernameInput(WidgetRef ref) {
    return AnimatedOpacity(
      opacity: ref.watch(currentStepProvider) >= 1 ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ユーザー名を入力してください'),
          TextFormField(
            autofocus: true,
            onChanged: (value) {
              ref.read(usernameProvider.notifier).state = value;
              if (value.isNotEmpty) {
                ref.read(currentStepProvider.notifier).state = 2;
              } else {
                ref.read(currentStepProvider.notifier).state = 1;
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNameInput(WidgetRef ref) {
    return AnimatedOpacity(
      opacity: ref.watch(currentStepProvider) >= 2 ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('名前を入力してください'),
          TextFormField(
            autofocus: true,
            onChanged: (value) {
              ref.read(nameProvider.notifier).state = value;
              if (value.isNotEmpty) {
                ref.read(currentStepProvider.notifier).state = 3;
              } else {
                ref.read(currentStepProvider.notifier).state = 2;
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildImageUpload(WidgetRef ref) {
    final image = ref.watch(imageProvider);
    return AnimatedOpacity(
      opacity: ref.watch(currentStepProvider) >= 3 ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('プロフィール画像をアップロードしてください'),
          const Gap(16),
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Center(
                child: (image != null)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(100 * 2 / 9),
                        child: Image.file(
                          image,
                          height: 100,
                          width: 100,
                        ),
                      )
                    : GestureDetector(
                        onTap: () async {
                          HapticFeedback.lightImpact();
                          final pickedFile = await ref
                              .read(imageProcessorNotifierProvider)
                              .getIconImage();
                          if (pickedFile != null) {
                            ref.read(imageProvider.notifier).state =
                                File(pickedFile.path);
                            ref.read(currentStepProvider.notifier).state = 4;
                          }
                        },
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: ThemeColor.accent,
                            borderRadius: BorderRadius.circular(100 * 2 / 9),
                            border: Border.all(
                              color: ThemeColor.stroke,
                              width: 0.4,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.image_rounded,
                              size: 48,
                              color: ThemeColor.subText,
                            ),
                          ),
                        ),
                      ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: (image == null)
                    ? GestureDetector(
                        onTap: () async {
                          HapticFeedback.lightImpact();
                          ref.read(currentStepProvider.notifier).state = 4;
                        },
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          decoration: BoxDecoration(
                            color: ThemeColor.accent,
                            borderRadius: BorderRadius.circular(80 * 2 / 9),
                            border: Border.all(
                              color: ThemeColor.stroke,
                              width: 0.4,
                            ),
                          ),
                          child: const Text('スキップ'),
                        ),
                      )
                    : GestureDetector(
                        onTap: () async {
                          HapticFeedback.lightImpact();
                          ref.read(imageProvider.notifier).state = null;
                        },
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          decoration: BoxDecoration(
                            color: ThemeColor.accent,
                            borderRadius: BorderRadius.circular(80 * 2 / 9),
                            border: Border.all(
                              color: ThemeColor.stroke,
                              width: 0.4,
                            ),
                          ),
                          child: const Text('取り消し'),
                        ),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /* Widget _buildGenderSelection(WidgetRef ref) {
    return AnimatedOpacity(
      opacity: ref.watch(currentStepProvider) >= 3 ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('性別を選択してください'),
          DropdownButton<Gender>(
            value: ref.watch(genderProvider),
            onChanged: (Gender? newValue) {
              if (newValue != null) {
                ref.read(genderProvider.notifier).state = newValue;
                ref.read(currentStepProvider.notifier).state = 4;
              }
            },
            items: <String>["男性", "女性", "回答しない"]
                .map<DropdownMenuItem<Gender>>((String value) {
              return DropdownMenuItem<Gender>(
                value: GenderConverter.converJPToGender(value),
                child: Text(value),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  } */

  Widget _buildCreateAccountButton(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: AnimatedOpacity(
        opacity: ref.watch(currentStepProvider) >= 4 ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 500),
        child: Center(
          child: GestureDetector(
            onTap: () async {
              final username = ref.read(usernameProvider);
              final name = ref.read(nameProvider);
              final image = ref.read(imageProvider);
              if (username.isNotEmpty && name.isNotEmpty) {
                try {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await ref
                        .read(myAccountNotifierProvider.notifier)
                        .createUser(username, name, image);
                   
                    ref.read(creatingProcessProvider.notifier).state = false;
                    showMessage('アカウントが作成されました');
                  }
                } catch (e) {
                  ref.read(creatingProcessProvider.notifier).state = false;
                  showErrorSnackbar(error: e);
                }
              } else {
                showMessage('すべての項目を入力してください');
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: ThemeColor.accent,
                borderRadius: BorderRadius.circular(80 * 2 / 9),
                border: Border.all(
                  color: ThemeColor.stroke,
                  width: 0.4,
                ),
              ),
              child: const Text('アカウントを作成'),
            ),
          ),
        ),
      ),
    );
  }
}
