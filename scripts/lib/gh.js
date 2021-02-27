import fs from "fs";
import { Octokit } from "@octokit/rest";
import { token, owner, repo } from "./env";
import spawn from "./spawn";

export { owner, repo };
export const octokit = new Octokit({ auth: token });

/**
 * Gets the latest commit hash
 */
export const getCurrentCommit = () => spawn(`git rev-parse --verify HEAD`);

export const getCommit = (commit_sha) =>
  octokit.git
    .getCommit({
      owner,
      repo,
      commit_sha,
    })
    .then((r) => r.data)
    .catch((error) => {
      if (error.status === 404) return null;
      throw error;
    });

export const getTags = (search = "") =>
  octokit.git
    .listMatchingRefs({
      owner,
      repo,
      ref: `tags/${search}`,
    })
    .then((r) => r.data);

export const getTag = async (tagName) =>
  octokit.git
    .getRef({
      owner,
      repo,
      ref: `tags/${tagName}`,
    })
    .then((r) => r.data)
    .catch((error) => {
      if (error.status === 404) return null;
      throw error;
    });

export const createTag = (sha, tag) =>
  octokit.git
    .createRef({
      owner,
      repo,
      ref: `refs/tags/${tag}`,
      sha,
    })
    .then((r) => (r && r.data) || r || null);

export const deleteTag = (tag) =>
  octokit.git
    .deleteRef({
      owner,
      repo,
      ref: `tags/${tag}`,
    })
    .then((r) => (r && r.data) || r || null);

export const getRelease = (tagName) =>
  octokit.repos
    .getReleaseByTag({
      owner,
      repo,
      tag: tagName,
    })
    .then((r) => r.data)
    .catch((error) => {
      if (error.status === 404) return null;
      throw error;
    });

export const createRelease = (tag_name, { name, body, draft, prerelease }) =>
  octokit.repos
    .createRelease({
      owner,
      repo,
      tag_name,
      name,
      body,
      draft: !!draft,
      prerelease: !!prerelease,
    })
    .then((r) => (r && r.data) || r || null);

export const deleteRelease = (release_id) =>
  octokit.repos
    .deleteRelease({
      owner,
      repo,
      release_id,
    })
    .then((r) => (r && r.data) || r || null);

export const getAssets = (release_id) =>
  octokit.repos
    .listReleaseAssets({
      owner,
      repo,
      release_id,
    })
    .then((r) => r && r.data)
    .catch((error) => {
      if (error.status === 404) return [];
      throw error;
    });

export const uploadAsset = (release_id, fileName, filePath) =>
  octokit.repos.uploadReleaseAsset({
    owner,
    repo,
    release_id,
    name: fileName,
    data: fs.readFileSync(filePath),
  });

export const deleteAsset = (asset_id) =>
  octokit.repos
    .deleteReleaseAsset({
      owner,
      repo,
      asset_id,
    })
    .then((r) => (r && r.data) || r || null);

export default {
  getCurrentCommit,
  tag: getTag,
  tags: getTags,
  createTag,
  commit: getCommit,
  deleteTag,
  release: getRelease,
  createRelease,
  deleteRelease,
  assets: getAssets,
  uploadAsset,
  deleteAsset,
};
