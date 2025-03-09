// octokit-helper.js
import { Octokit } from '@octokit/core';

/**
 * Octokit インスタンスを作成する関数
 * @param {string} token - GitHub token
 * @returns {Promise<object>} Octokit インスタンス
 */
export async function createOctokit(token) {
  const octokit = new Octokit({
    auth: token
  });
  
  // 必要なエンドポイントを追加したOctokitインスタンスを拡張
  return {
    ...octokit,
    pulls: {
      listFiles: async (params) => {
        return octokit.request('GET /repos/{owner}/{repo}/pulls/{pull_number}/files', params);
      },
      createReviewComment: async (params) => {
        return octokit.request('POST /repos/{owner}/{repo}/pulls/{pull_number}/comments', params);
      }
    },
    repos: {
      getContent: async (params) => {
        return octokit.request('GET /repos/{owner}/{repo}/contents/{path}', {
          ...params,
          mediaType: {
            format: 'raw'
          }
        });
      },
      getCommit: async (params) => {
        return octokit.request('GET /repos/{owner}/{repo}/commits/{ref}', params);
      }
    },
    issues: {
      createComment: async (params) => {
        return octokit.request('POST /repos/{owner}/{repo}/issues/{issue_number}/comments', params);
      }
    }
  };
}