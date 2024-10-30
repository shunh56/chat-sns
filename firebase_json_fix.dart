final sample = {
  "projects": {"dev": "chat-sns-project-dev", "prod": "chat-sns-project"},
  "targets": {
    "chat-sns-project-dev": {
      "firestore": {
        "rules": "firestore.rules",
        "indexes": "firestore.indexes.json"
      },
      "functions": [
        {
          "source": "functions",
          "codebase": "default",
          "ignore": [
            "node_modules",
            ".git",
            "firebase-debug.log",
            "firebase-debug.*.log"
          ]
        }
      ],
      "hosting": {
        "public": "public",
        "ignore": ["firebase.json", "**/.*", "**/node_modules/**"]
      },
      "storage": {"rules": "storage.rules"},
      "flutter": {
        "platforms": {
          "android": {
            "default": {
              "projectId": "chat-sns-project-dev",
              "appId": "1:889410445548:android:53d67e153fae0a460185c9",
              "fileOutput": "android/app/google-services.dev.json"
            }
          },
          "ios": {
            "default": {
              "projectId": "chat-sns-project-dev",
              "appId": "1:889410445548:ios:58820ac80a95a1120185c9",
              "uploadDebugSymbols": true,
              "fileOutput": "ios/Runner/GoogleService-Info-Dev.plist"
            }
          },
          "dart": {
            "lib/firebase_options_dev.dart": {
              "projectId": "chat-sns-project-dev",
              "configurations": {
                "android": "1:889410445548:android:53d67e153fae0a460185c9",
                "ios": "1:889410445548:ios:58820ac80a95a1120185c9"
              }
            }
          }
        }
      }
    },
    "chat-sns-project": {
      "firestore": {
        "rules": "firestore.rules",
        "indexes": "firestore.indexes.json"
      },
      "functions": [
        {
          "source": "functions",
          "codebase": "default",
          "ignore": [
            "node_modules",
            ".git",
            "firebase-debug.log",
            "firebase-debug.*.log"
          ]
        }
      ],
      "hosting": {
        "public": "public",
        "ignore": ["firebase.json", "**/.*", "**/node_modules/**"]
      },
      "storage": {"rules": "storage.rules"},
      "flutter": {
        "platforms": {
          "android": {
            "default": {
              "projectId": "chat-sns-project",
              "appId": "1:889410445548:android:53d67e153fae0a460185c9",
              "fileOutput": "android/app/google-services.prod.json"
            }
          },
          "ios": {
            "default": {
              "projectId": "chat-sns-project",
              "appId": "1:889410445548:ios:58820ac80a95a1120185c9",
              "uploadDebugSymbols": true,
              "fileOutput": "ios/Runner/GoogleService-Info-Prod.plist"
            }
          },
          "dart": {
            "lib/firebase_options_prod.dart": {
              "projectId": "chat-sns-project",
              "configurations": {
                "android": "1:889410445548:android:53d67e153fae0a460185c9",
                "ios": "1:889410445548:ios:58820ac80a95a1120185c9"
              }
            }
          }
        }
      }
    }
  }
};
