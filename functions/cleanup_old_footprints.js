/**
 * 旧Footprintデータ削除スクリプト（v1 → v2移行用）
 *
 * 使い方:
 * 1. functions ディレクトリに移動: cd functions
 * 2. Firebase認証:
 *    - オプション1: gcloud auth application-default login
 *    - オプション2: GOOGLE_APPLICATION_CREDENTIALS環境変数を設定
 * 3. DRY RUN: node cleanup_old_footprints.js --dry-run
 * 4. 実行: node cleanup_old_footprints.js
 *
 * 削除対象:
 * - users/{userId}/footprinteds (旧ネスト構造)
 * - users/{userId}/footprints (旧ネスト構造)
 */

const admin = require('firebase-admin');

// Firebase Admin初期化（既存の初期化があればスキップ）
if (!admin.apps.length) {
  try {
    // プロジェクトIDを環境変数から取得
    // コマンドライン引数で --project=PROJECT_ID を指定可能
    const args = process.argv.slice(2);
    const projectArg = args.find(arg => arg.startsWith('--project='));
    const projectId = projectArg
      ? projectArg.split('=')[1]
      : (process.env.FIREBASE_PROJECT_ID || 'chat-sns-project');

    admin.initializeApp({
      projectId: projectId,
    });

    console.log(`✅ Firebase Admin初期化完了: ${projectId}\n`);
  } catch (error) {
    console.error('❌ Firebase Admin初期化エラー:', error.message);
    console.error('\n以下のいずれかの方法で認証してください:');
    console.error('1. gcloud auth application-default login');
    console.error('2. GOOGLE_APPLICATION_CREDENTIALS環境変数を設定');
    console.error('3. サービスアカウントキーを使用してinitializeApp()を呼び出す\n');
    process.exit(1);
  }
}

const db = admin.firestore();

/**
 * 全ユーザーの旧footprintデータを削除
 */
async function cleanupOldFootprints() {
  console.log('🔍 旧Footprintデータの削除を開始します...\n');

  try {
    // 全ユーザーを取得
    const usersSnapshot = await db.collection('users').get();

    let totalDeleted = 0;
    let userCount = 0;

    for (const userDoc of usersSnapshot.docs) {
      const userId = userDoc.id;
      userCount++;

      console.log(`[${userCount}/${usersSnapshot.docs.length}] ユーザー: ${userId}`);

      // footprintedsサブコレクション削除
      const footprintedsCount = await deleteSubcollection(userId, 'footprinteds');

      // footprintsサブコレクション削除
      const footprintsCount = await deleteSubcollection(userId, 'footprints');

      const userTotal = footprintedsCount + footprintsCount;
      totalDeleted += userTotal;

      if (userTotal > 0) {
        console.log(`  ✅ ${userTotal}件のドキュメントを削除\n`);
      } else {
        console.log(`  ℹ️  削除対象なし\n`);
      }
    }

    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log(`✨ 削除完了！`);
    console.log(`   処理ユーザー数: ${userCount}`);
    console.log(`   削除ドキュメント数: ${totalDeleted}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  } catch (error) {
    console.error('❌ エラーが発生しました:', error);
    throw error;
  }
}

/**
 * サブコレクションを削除
 */
async function deleteSubcollection(userId, subcollectionName) {
  const collectionRef = db
    .collection('users')
    .doc(userId)
    .collection(subcollectionName);

  const snapshot = await collectionRef.get();

  if (snapshot.empty) {
    return 0;
  }

  console.log(`  🗑️  ${subcollectionName}: ${snapshot.size}件`);

  // バッチ削除（最大500件ずつ）
  const batchSize = 500;
  let deletedCount = 0;

  while (deletedCount < snapshot.size) {
    const batch = db.batch();
    const docs = snapshot.docs.slice(deletedCount, deletedCount + batchSize);

    docs.forEach(doc => {
      batch.delete(doc.ref);
    });

    await batch.commit();
    deletedCount += docs.length;
  }

  return snapshot.size;
}

/**
 * DRY RUN: 削除せずに対象データを確認
 */
async function dryRun() {
  console.log('🔍 DRY RUN: 削除対象データを確認します...\n');

  const usersSnapshot = await db.collection('users').get();

  let totalFootprinteds = 0;
  let totalFootprints = 0;

  for (const userDoc of usersSnapshot.docs) {
    const userId = userDoc.id;

    const footprintedsSnapshot = await db
      .collection('users')
      .doc(userId)
      .collection('footprinteds')
      .get();

    const footprintsSnapshot = await db
      .collection('users')
      .doc(userId)
      .collection('footprints')
      .get();

    if (!footprintedsSnapshot.empty || !footprintsSnapshot.empty) {
      console.log(`ユーザー: ${userId}`);
      console.log(`  - footprinteds: ${footprintedsSnapshot.size}件`);
      console.log(`  - footprints: ${footprintsSnapshot.size}件\n`);
    }

    totalFootprinteds += footprintedsSnapshot.size;
    totalFootprints += footprintsSnapshot.size;
  }

  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('📊 削除対象の合計:');
  console.log(`   footprinteds: ${totalFootprinteds}件`);
  console.log(`   footprints: ${totalFootprints}件`);
  console.log(`   合計: ${totalFootprinteds + totalFootprints}件`);
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
}

// スクリプト実行
const args = process.argv.slice(2);

if (args.includes('--dry-run')) {
  dryRun().then(() => {
    console.log('✅ DRY RUN完了');
    process.exit(0);
  }).catch(error => {
    console.error('❌ エラー:', error);
    process.exit(1);
  });
} else {
  console.log('⚠️  警告: このスクリプトは旧Footprintデータを完全に削除します。');
  console.log('⚠️  復元できません！DRY RUNで確認してから実行してください。\n');
  console.log('   DRY RUN: node cleanup_old_footprints.js --dry-run\n');

  // 本番実行（5秒待機）
  setTimeout(() => {
    cleanupOldFootprints().then(() => {
      process.exit(0);
    }).catch(error => {
      console.error('❌ エラー:', error);
      process.exit(1);
    });
  }, 5000);
}
