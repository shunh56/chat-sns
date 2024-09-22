import 'package:app/domain/value/user/gender.dart';
import 'package:app/presentation/providers/notifier/image/image_processor.dart';
import 'package:app/presentation/providers/provider/users/my_user_account_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

final nameProvider = StateProvider<String>((ref) => '');
final imageProvider = StateProvider<File?>((ref) => null);
final genderProvider = StateProvider<Gender>((ref) => Gender.male);
final currentStepProvider = StateProvider<int>((ref) => -1);

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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeMessage(ref),
                const SizedBox(height: 32),
                if (currentStep >= 0) _buildNameInput(ref),
                if (currentStep >= 1) _buildImageUpload(ref),
                if (currentStep >= 2) _buildGenderSelection(ref),
                if (currentStep >= 3) _buildCreateAccountButton(context, ref),
              ],
            ),
          ),
        ),
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

  Widget _buildNameInput(WidgetRef ref) {
    return AnimatedOpacity(
      opacity: ref.watch(currentStepProvider) >= 1 ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('名前を入力してください'),
          TextFormField(
            onChanged: (value) {
              ref.read(nameProvider.notifier).state = value;
              if (value.isNotEmpty) {
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
    return AnimatedOpacity(
      opacity: ref.watch(currentStepProvider) >= 2 ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('プロフィール画像をアップロードしてください'),
          ElevatedButton(
            onPressed: () async {
              final pickedFile =
                  await ref.read(imageProcessorNotifierProvider).getIconImage();
              if (pickedFile != null) {
                ref.read(imageProvider.notifier).state = File(pickedFile.path);
                ref.read(currentStepProvider.notifier).state = 3;
              }
            },
            child: const Text('画像を選択'),
          ),
          ElevatedButton(
            onPressed: () async {
              ref.read(currentStepProvider.notifier).state = 3;
            },
            child: const Text('SKIP'),
          ),
          if (ref.watch(imageProvider) != null)
            Image.file(ref.watch(imageProvider)!, height: 100, width: 100),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildGenderSelection(WidgetRef ref) {
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
  }

  Widget _buildCreateAccountButton(BuildContext context, WidgetRef ref) {
    return AnimatedOpacity(
      opacity: ref.watch(currentStepProvider) >= 4 ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: ElevatedButton(
        onPressed: () async {
          final name = ref.read(nameProvider);
          final image = ref.read(imageProvider);
          final gender = ref.read(genderProvider);

          if (name.isNotEmpty) {
            try {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                await ref
                    .read(myAccountNotifierProvider.notifier)
                    .createUser(name, image, gender);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('アカウントが作成されました')),
                );
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('エラーが発生しました: $e')),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('すべての項目を入力してください')),
            );
          }
        },
        child: const Text('アカウントを作成'),
      ),
    );
  }
}
