const { Octokit } = require('@octokit/rest');
const axios = require('axios');
const fs = require('fs');
const path = require('path');

// GitHub 関連の環境変数
const GITHUB_TOKEN = process.env.GITHUB_TOKEN;
const GITHUB_EVENT_PATH = process.env.GITHUB_EVENT_PATH;
const GITHUB_REPOSITORY = process.env.GITHUB_REPOSITORY;
const GITHUB_SHA = process.env.GITHUB_SHA;

// OpenRouter API 関連の設定
const OPENROUTER_API_KEY = process.env.OPENROUTER_API_KEY;
const OPENROUTER_API_URL = 'https://openrouter.ai/api/v1/chat/completions';
const AI_MODEL = 'anthropic/claude-3-5-sonnet'; // 使用するモデルを指定

// ファイル拡張子のフィルタリング（レビュー対象）
const REVIEW_FILE_EXTENSIONS = [
  '.js', '.jsx', '.ts', '.tsx', 
  '.py', '.rb', '.go', '.java', 
  '.php', '.c', '.cpp', '.cs', 
  '.swift', '.kt', '.rs'
];

// 除外するディレクトリ
const EXCLUDED_DIRECTORIES = [
  'node_modules', 'vendor', 'dist', 'build', 
  '.git', '.github', 'bin', 'obj'
];

// GitHub APIクライアントの初期化
const octokit = new Octokit({
  auth: GITHUB_TOKEN
});

async function main() {
  try {
    console.log('AI Code Review を開始します...');
    
    // イベントデータの読み込み
    const eventData = JSON.parse(fs.readFileSync(GITHUB_EVENT_PATH, 'utf8'));
    const [owner, repo] = GITHUB_REPOSITORY.split('/');
    
    // PRの場合とpushの場合で処理を分岐
    if (eventData.pull_request) {
      await handlePullRequest(owner, repo, eventData);
    } else {
      await handleCommit(owner, repo);
    }
    
    console.log('AI Code Review が完了しました');
  } catch (error) {
    console.error('エラーが発生しました:', error);
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
    pull_number: pullNumber
  });
  
  // レビュー対象のファイルをフィルタリング
  const filesToReview = files.filter(file => 
    REVIEW_FILE_EXTENSIONS.includes(path.extname(file.filename)) &&
    !EXCLUDED_DIRECTORIES.some(dir => file.filename.startsWith(dir + '/'))
  );
  
  if (filesToReview.length === 0) {
    console.log('レビュー対象のファイルが見つかりませんでした');
    return;
  }
  
  // 各ファイルの内容を取得してレビュー
  for (const file of filesToReview) {
    // ファイルの内容を取得
    const { data: fileContent } = await octokit.repos.getContent({
      owner,
      repo,
      path: file.filename,
      ref: eventData.pull_request.head.sha
    });
    
    // Base64デコード
    const content = Buffer.from(fileContent.content, 'base64').toString();
    
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
      line: getFirstChangedLine(file)
    });
    
    console.log(`ファイル ${file.filename} のレビューを投稿しました`);
  }
  
  // 全体的な要約コメントを追加
  if (filesToReview.length > 0) {
    const summary = await getAISummary(filesToReview.map(f => f.filename));
    await octokit.issues.createComment({
      owner,
      repo,
      issue_number: pullNumber,
      body: `## AIレビュー要約\n\n${summary}`
    });
  }
}

async function handleCommit(owner, repo) {
  console.log(`コミット ${GITHUB_SHA} をレビューします`);
  
  // コミットの変更ファイルを取得
  const { data: commit } = await octokit.repos.getCommit({
    owner,
    repo,
    ref: GITHUB_SHA
  });
  
  // レビュー対象のファイルをフィルタリング
  const filesToReview = commit.files.filter(file => 
    REVIEW_FILE_EXTENSIONS.includes(path.extname(file.filename)) &&
    !EXCLUDED_DIRECTORIES.some(dir => file.filename.startsWith(dir + '/'))
  );
  
  if (filesToReview.length === 0) {
    console.log('レビュー対象のファイルが見つかりませんでした');
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
      ref: GITHUB_SHA
    });
    
    // Base64デコード
    const content = Buffer.from(fileContent.content, 'base64').toString();
    
    // AIにレビューを依頼
    const review = await getAIReview(file.filename, content);
    
    console.log(`\n===== ${file.filename} のレビュー =====\n`);
    console.log(review);
    console.log('\n=====================================\n');
  }
}

async function getAIReview(filename, content) {
  console.log(`ファイル ${filename} のAIレビューを要求中...`);
  
  try {
    const response = await axios.post(
      OPENROUTER_API_URL,
      {
        model: AI_MODEL,
        messages: [
          {
            role: 'system',
            content: 'あなたは優秀なプログラマーおよびコードレビュアーです。提供されるコードを詳細に分析し、以下の点に注目してください：\n' +
                     '- コードの品質と可読性\n' +
                     '- パフォーマンスの問題\n' +
                     '- セキュリティの脆弱性\n' +
                     '- ベストプラクティスからの逸脱\n' +
                     '- 改善の提案\n\n' +
                     'レビューは簡潔かつ具体的で、対応可能な改善点を含めてください。'
          },
          {
            role: 'user',
            content: `ファイル名: ${filename}\n\n${content}`
          }
        ],
        max_tokens: 2000
      },
      {
        headers: {
          'Authorization': `Bearer ${OPENROUTER_API_KEY}`,
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://github.com/actions'
        }
      }
    );
    
    return response.data.choices[0].message.content;
  } catch (error) {
    console.error('AIレビューの取得中にエラーが発生しました:', error.response?.data || error.message);
    return '⚠️ AIレビューの生成中にエラーが発生しました。詳細はログを確認してください。';
  }
}

async function getAISummary(filenames) {
  console.log('PRの全体要約を要求中...');
  
  try {
    const response = await axios.post(
      OPENROUTER_API_URL,
      {
        model: AI_MODEL,
        messages: [
          {
            role: 'system',
            content: 'あなたは優秀なプログラマーおよびコードレビュアーです。このプルリクエストの全体的な評価と要約を提供してください。'
          },
          {
            role: 'user',
            content: `このプルリクエストには以下のファイルが含まれています：\n${filenames.join('\n')}\n\n全体的な評価と改善のアドバイスをお願いします。`
          }
        ],
        max_tokens: 1000
      },
      {
        headers: {
          'Authorization': `Bearer ${OPENROUTER_API_KEY}`,
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://github.com/actions'
        }
      }
    );
    
    return response.data.choices[0].message.content;
  } catch (error) {
    console.error('AI要約の取得中にエラーが発生しました:', error.response?.data || error.message);
    return '⚠️ AI要約の生成中にエラーが発生しました。詳細はログを確認してください。';
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
main();
