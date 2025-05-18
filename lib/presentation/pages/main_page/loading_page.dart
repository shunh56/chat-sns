import 'package:app/core/utils/flavor.dart';
import 'package:flutter/material.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!Flavor.isAppStoreEnv)
              Flavor.isDevEnv
                  ? const Padding(
                      padding: EdgeInsets.only(bottom: 24),
                      child: Text(
                        "DEVMODE",
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : const Padding(
                      padding: EdgeInsets.only(bottom: 24),
                      child: Text(
                        "PRODMODE",
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            SizedBox(
              height: 72,
              width: 72,
              child: Image.asset(
                'assets/images/icons/icon_circle_bg_white.png',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
