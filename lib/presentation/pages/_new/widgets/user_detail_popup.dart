import 'package:app/presentation/pages/_new/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/user_model.dart';

class UserDetailPopup extends StatelessWidget {
  final UserModel user;

  const UserDetailPopup({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 130,
      left: -50,
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.9),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              user.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              user.bio,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: user.interests.map((interest) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    interest,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton('👋', '挨拶'),
                _buildActionButton('❤️', 'いいね'),
                _buildActionButton('💬', 'メッセージ'),
              ],
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 300.ms)
          .slideY(begin: 0.3, end: 0, duration: 300.ms),
    );
  }

  Widget _buildActionButton(String emoji, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryPink.withOpacity(0.8),
              AppColors.primaryBlue.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 10),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
