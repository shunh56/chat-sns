// ESM形式でインポート
import { createOctokit } from "./octokit-helper.js";
import axios from "axios";
import fs from "fs";
import path from "path";

// GitHub 関連の環境変数
const GITHUB_TOKEN = process.env.GITHUB_TOKEN;
const GITHUB_EVENT_PATH = process.env.GITHUB_EVENT_PATH;
const GITHUB_REPOSITORY = process.env.GITHUB_REPOSITORY;
const GITHUB_SHA = process.env.GITHUB_SHA;

// Octokitインスタンス
let octokit;

// OpenRouter API 関連の設定
const OPENROUTER_API_KEY = process.env.OPENROUTER_API_KEY;
const OPENROUTER_API_URL = "https://openrouter.ai/api/v1";
const AI_MODEL = "google/gemini-2.0-pro-exp-02-05:free"; // 使用するモデルを指定

// ファイル拡張子のフィルタリング（レビュー対象）
const REVIEW_FILE_EXTENSIONS = [
  ".js",
  ".jsx",
  ".ts",
  ".tsx",
  ".py",
  ".rb",
  ".go",
  ".java",
  ".php",
  ".c",
  ".cpp",
  ".cs",
  ".swift",
  ".kt",
  ".rs",
  ".dart",
  ".yaml",
  ".json", // Flutter/Dartプロジェクト用に追加
];

// 除外するディレクトリ
const EXCLUDED_DIRECTORIES = [
  "node_modules",
  "vendor",
  "dist",
  "build",
  ".git",
  ".github",
  "bin",
  "obj",
  ".dart_tool",
  ".fvm",
  ".pub-cache", // Flutter固有のキャッシュディレクトリ
  "ios/Pods",
  "android/.gradle", // プラットフォーム固有の依存関係ディレクトリ
];

// GitHub APIクライアントの初期化はmain関数内で行う

async function main() {
  try {
    console.log("AI Code Review を開始します...");

    // Octokitの初期化を待機
    octokit = await createOctokit(GITHUB_TOKEN);

    // イベントデータの読み込み
    const eventData = JSON.parse(fs.readFileSync(GITHUB_EVENT_PATH, "utf8"));
    const [owner, repo] = GITHUB_REPOSITORY.split("/");

    // PRの場合とpushの場合で処理を分岐
    if (eventData.pull_request) {
      await handlePullRequest(owner, repo, eventData);
    } else {
      await handleCommit(owner, repo);
    }

    console.log("AI Code Review が完了しました");
  } catch (error) {
    console.error("エラーが発生しました:", error);
    process.exit(1);
  }
}

async function handlePullRequest(owner, repo, eventData) {
  const pullNumber = eventData.pull_request.number;
  console.log(`PR #${pullNumber} をレビューします`);

  // PRの変更ファイルを取得
  const { data: files } = await octokit.pulls.listFiles({
    owner,
    repo,
    pull_number: pullNumber,
  });

  // レビュー対象のファイルをフィルタリング
  const filesToReview = files.filter(
    (file) =>
      REVIEW_FILE_EXTENSIONS.includes(path.extname(file.filename)) &&
      !EXCLUDED_DIRECTORIES.some((dir) => file.filename.startsWith(dir + "/"))
  );

  if (filesToReview.length === 0) {
    console.log("レビュー対象のファイルが見つかりませんでした");
    return;
  }

  // 各ファイルの内容を取得してレビュー
  for (const file of filesToReview) {
    // ファイルの内容を取得
    const { data: fileContent } = await octokit.repos.getContent({
      owner,
      repo,
      path: file.filename,
      ref: eventData.pull_request.head.sha,
    });

    // Base64デコード
    const content = Buffer.from(fileContent.content, "base64").toString();

    // AIにレビューを依頼
    const review = await getAIReview(file.filename, content);

    // PRにコメントを追加
    await octokit.pulls.createReviewComment({
      owner,
      repo,
      pull_number: pullNumber,
      body: review,
      commit_id: eventData.pull_request.head.sha,
      path: file.filename,
      line: getFirstChangedLine(file),
    });

    console.log(`ファイル ${file.filename} のレビューを投稿しました`);
  }

  // 全体的な要約コメントを追加
  if (filesToReview.length > 0) {
    const summary = await getAISummary(filesToReview.map((f) => f.filename));
    await octokit.issues.createComment({
      owner,
      repo,
      issue_number: pullNumber,
      body: `## AIレビュー要約\n\n${summary}`,
    });
  }
}

async function handleCommit(owner, repo) {
  console.log(`コミット ${GITHUB_SHA} をレビューします`);

  // コミットの変更ファイルを取得
  const { data: commit } = await octokit.repos.getCommit({
    owner,
    repo,
    ref: GITHUB_SHA,
  });

  // レビュー対象のファイルをフィルタリング
  const filesToReview = commit.files.filter(
    (file) =>
      REVIEW_FILE_EXTENSIONS.includes(path.extname(file.filename)) &&
      !EXCLUDED_DIRECTORIES.some((dir) => file.filename.startsWith(dir + "/"))
  );

  if (filesToReview.length === 0) {
    console.log("レビュー対象のファイルが見つかりませんでした");
    return;
  }

  console.log(`${filesToReview.length} ファイルをレビューします`);

  // 各ファイルの内容を取得してレビュー（コミットの場合はGitHub上にコメントできないため、コンソール出力のみ）
  for (const file of filesToReview) {
    // ファイルの内容を取得
    const { data: fileContent } = await octokit.repos.getContent({
      owner,
      repo,
      path: file.filename,
      ref: GITHUB_SHA,
    });

    // Base64デコード
    const content = Buffer.from(fileContent.content, "base64").toString();

    // AIにレビューを依頼
    const review = await getAIReview(file.filename, content);

    console.log(`\n===== ${file.filename} のレビュー =====\n`);
    console.log(review);
    console.log("\n=====================================\n");
  }
}

async function getAIReview(filename, content) {
  console.log(`ファイル ${filename} のAIレビューを要求中...`);

  // ファイル拡張子に基づいてプロンプトを調整
  const fileExtension = path.extname(filename).toLowerCase();
  let systemPrompt = "";

  if (fileExtension === ".dart") {
    // Dart/Flutterファイル向けのプロンプト
    systemPrompt =
      "あなたは優秀なFlutterおよびDart開発者であり、コードレビュアーです。提供されるコードを詳細に分析し、以下の点に注目してください：\n" +
      "- Dartコードの品質と可読性\n" +
      "- Flutterのパフォーマンスに関する問題（不要なリビルド、非効率なWidget構造など）\n" +
      "- 状態管理のベストプラクティス（Provider, Riverpod, BLoC, GetXなど）\n" +
      "- UI/UXの改善点（レスポンシブ設計、アクセシビリティなど）\n" +
      "- Dartの言語機能の適切な活用（null safety, extension methodsなど）\n" +
      "- Flutterのパッケージ管理とプロジェクト構成\n" +
      "- テスト可能性とテストコードのレビュー\n" +
      "- Flutter固有のセキュリティ問題や懸念点\n\n" +
      "レビューは簡潔かつ具体的で、対応可能な改善点を含めてください。コードスニペットで具体的な修正例を示すと役立ちます。";
  } else if (fileExtension === ".yaml" && filename.includes("pubspec")) {
    // pubspec.yamlファイル向けのプロンプト
    systemPrompt =
      "あなたは優秀なFlutterプロジェクト管理の専門家およびコードレビュアーです。このpubspec.yamlファイルを詳細に分析し、以下の点に注目してください：\n" +
      "- 依存関係のバージョン管理の問題（バージョン制約、互換性など）\n" +
      "- 使用されていない可能性のある依存関係\n" +
      "- 重複または競合する依存関係\n" +
      "- セキュリティリスクのある古いバージョンの依存関係\n" +
      "- Flutter固有の設定の問題（assets, fonts, platformsなど）\n" +
      "- package構成に関するベストプラクティス\n\n" +
      "レビューは簡潔かつ具体的で、対応可能な改善点を含めてください。";
  } else {
    // その他のファイル向けの一般的なプロンプト
    systemPrompt =
      "あなたは優秀なプログラマーおよびコードレビュアーです。提供されるコードを詳細に分析し、以下の点に注目してください：\n" +
      "- コードの品質と可読性\n" +
      "- パフォーマンスの問題\n" +
      "- セキュリティの脆弱性\n" +
      "- ベストプラクティスからの逸脱\n" +
      "- 改善の提案\n\n" +
      "レビューは簡潔かつ具体的で、対応可能な改善点を含めてください。";
  }

  try {
    const response = await axios.post(
      OPENROUTER_API_URL,
      {
        model: AI_MODEL,
        messages: [
          {
            role: "user",
            content: [
              {
                type: "text",
                text: `${systemPrompt}\n\nファイル名: ${filename}\n\n${content}`,
              },
            ],
          },
        ],
        max_tokens: 2000,
      },
      {
        headers: {
          Authorization: `Bearer ${OPENROUTER_API_KEY}`,
          "Content-Type": "application/json",
          "HTTP-Referer": "https://github.com/actions",
          "X-Title": "GitHub Actions AI Code Review",
        },
      }
    );

    // レスポンスの構造を検証
    if (
      response.data &&
      response.data.choices &&
      Array.isArray(response.data.choices) &&
      response.data.choices.length > 0 &&
      response.data.choices[0].message &&
      response.data.choices[0].message.content
    ) {
      return response.data.choices[0].message.content;
    } else {
      console.log(
        "APIレスポンスの形式が予期しない構造です:",
        JSON.stringify(response.data, null, 2)
      );
      return "⚠️ AIレビューの生成中に問題が発生しました。APIからの応答の形式が想定と異なります。";
    }
  } catch (error) {
    console.error(
      "AIレビューの取得中にエラーが発生しました:",
      error.response?.data || error.message
    );
    // デバッグ情報を追加
    if (error.response) {
      console.error(
        "API応答の詳細:",
        JSON.stringify(error.response.data, null, 2)
      );
      console.error("ステータスコード:", error.response.status);
    }
    return "⚠️ AIレビューの生成中にエラーが発生しました。詳細はログを確認してください。";
  }
}

async function getAISummary(filenames) {
  console.log("PRの全体要約を要求中...");

  // Flutterファイルが含まれているかをチェック
  const hasDartFiles = filenames.some((filename) => filename.endsWith(".dart"));
  const hasPubspecFile = filenames.some((filename) =>
    filename.includes("pubspec.yaml")
  );

  let systemPrompt = "";

  if (hasDartFiles || hasPubspecFile) {
    // Flutterプロジェクトの場合、特化したプロンプトを使用
    systemPrompt =
      "あなたは優秀なFlutter/Dart開発者およびコードレビュアーです。このプルリクエストの全体的な評価を行い、以下の観点から分析してください：\n" +
      "- 全体的なコード品質とFlutterのベストプラクティスへの準拠\n" +
      "- アーキテクチャと設計パターンの一貫性（MVVM, Clean Architectureなど）\n" +
      "- パフォーマンス最適化の機会\n" +
      "- コード再利用性と保守性\n" +
      "- UI/UXの一貫性と改善点\n" +
      "- テスト戦略と改善点\n" +
      "- セキュリティの懸念事項\n\n" +
      "この変更がプロジェクト全体に与える影響と、優先すべき改善点について言及してください。";
  } else {
    // 一般的なシステムプロンプト
    systemPrompt =
      "あなたは優秀なプログラマーおよびコードレビュアーです。このプルリクエストの全体的な評価と要約を提供してください。";
  }

  try {
    const response = await axios.post(
      OPENROUTER_API_URL,
      {
        model: AI_MODEL,
        messages: [
          {
            role: "system",
            content: systemPrompt,
          },
          {
            role: "user",
            content: `このプルリクエストには以下のファイルが含まれています：\n${filenames.join(
              "\n"
            )}\n\n全体的な評価と改善のアドバイスをお願いします。`,
          },
        ],
        max_tokens: 1000,
      },
      {
        headers: {
          Authorization: `Bearer ${OPENROUTER_API_KEY}`,
          "Content-Type": "application/json",
          "HTTP-Referer": "https://github.com/actions",
        },
      }
    );

    return response.data.choices[0].message.content;
  } catch (error) {
    console.error(
      "AI要約の取得中にエラーが発生しました:",
      error.response?.data || error.message
    );
    return "⚠️ AI要約の生成中にエラーが発生しました。詳細はログを確認してください。";
  }
}

// ファイルの変更箇所の最初の行を取得する関数
function getFirstChangedLine(file) {
  // patchから最初の変更行を解析
  if (file.patch) {
    const match = file.patch.match(/@@ -\d+,\d+ \+(\d+),/);
    if (match && match[1]) {
      return parseInt(match[1], 10);
    }
  }
  return 1; // デフォルト値
}

// スクリプトの実行
main().catch((error) => {
  console.error("致命的なエラーが発生しました:", error);
  process.exit(1);
});
