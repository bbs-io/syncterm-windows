import cp from 'child_process';
import shell from 'shelljs';
import fs from 'fs';
import path from 'path'
import Git from 'git-commands';
import GitHub from 'github-api';
import fetch from 'node-fetch';

process.chdir(`${__dirname}/../`);

const { GITHUB_TOKEN } = process.env;
const git = new Git({ reps: path.normalize(`${__dirname}/../`) });
const gh = new GitHub({ token: GITHUB_TOKEN });
const repo = gh.getRepo('bbs-io', 'syncterm-windows');

// syncterm setup output
const { built, build, version } = JSON.parse(fs.readFileSync(`${__dirname}/../input/syncterm.json`));
const asset = `./output/SyncTERM-${version}-${build}-Setup.exe`;

const delay = ms => new Promise(resolve => setTimeout(resolve, ms));

const unwrap = req => req.then(({ status, statusText, data }) => {
  if (status >= 300) throw Object.assign(new Error(statusText), data, { status, statusText });
  return data;
})

const getNightlyTagCommit = async () => {
  const tags = await unwrap(repo.listTags());
  const tag = tags.find(t => t.name === 'nightly');
  if (!tag) return null;
  return tag.commit.sha;
};

const refreshTag = async () => {
  const commit = git.command('rev-parse HEAD').trim(); // latest commit
  const nc = await getNightlyTagCommit();

  if (nc && nc == commit) {
    console.log(`Tag 'nightly' is current.`);
    return;
  }

  if (nc) {
    console.log(`Removing old 'nightly' tag`);
    await unwrap(repo.deleteRef('tags/nightly'));
  }

  console.log(`Setting 'nightly' tag to ${commit}`);
  await unwrap(repo.createRef({
    ref: 'refs/tags/nightly',
    sha: commit,
  }));

  console.log(`Set 'nightly' tag to latest commit.`);
  return;
};

const getRelease = async () => {
  const releases = await unwrap(repo.listReleases());
  const release = releases.find(r => r.tag_name === 'nightly');
  return release;
}

const createRelease = async () => {
  console.log(`Creating 'nightly' release`);
  const data = await unwrap(repo.createRelease({
    tag_name: 'nightly',
    name: 'Nightly Release',
    body: 'Nightly release build daily at 0700 UTC',
    draft: false,
    prerelease: false,
  }));
  return data;
}

const removeAsset = async asset => {
  console.log(`Removing old asset`, asset.url);
  const result = await fetch(
    asset.url,
    {
      method: 'DELETE',
      headers: { authorization: `token ${GITHUB_TOKEN}` }
    }
  );
  const { status, statusText } = result;
  const txt = await result.text();
  const data = (() => {
    try {
      return JSON.parse(txt);
    } catch (_) {
      return { detail: txt };
    }
  })();
  if (result.status >= 300) throw Object.assign(new Error('Error deleting asset'), data, { asset, status, statusText });
}

const addAsset = async (release) => {
  console.log(`Uploading new release asset ${asset}`);

  // asset uploads use a different host name, uploads.github.com for upload url
  const base = release.assets_url.replace(`//api.github.com/`, `//uploads.github.com/`);
  const url = `${base}?name=${encodeURIComponent(path.basename(asset))}`
  const readStream = fs.createReadStream(asset);
  const fileSize = fs.statSync(asset).size;
  
  const result = await fetch(url, {
    method: 'POST',
    headers: {
      authorization: `token ${GITHUB_TOKEN}`,
      Accept: 'application/vnd.github.v3+json',
      'Content-Length': fileSize,
      'Content-Type': 'application/x-msdownload', // 'application/octet-stream', // 'application/vnd.microsoft.portable-executable',
    },
    body: readStream
  });
  const { status, statusText } = result;
  const txt = await result.text();
  const data = (() => {
    try {
      return JSON.parse(txt);
    } catch (_) {
      return { detail: txt };
    }
  })();
  if (result.status >= 300) throw Object.assign(new Error('Error deleting asset'), data, { asset, status, statusText });
}

const refreshRelease = async () => {
  let release = await getRelease();
  if (!release) release = await createRelease();

  for (const asset of release.assets) {
    await removeAsset(asset);
  }

  await addAsset(release);
}

async function main() {
  process.chdir(`${__dirname}/../`);

  if (!GITHUB_TOKEN) {
    throw new Error('No GITHUB_TOKEN environment variable');
  }
  if (!fs.existsSync(asset)) {
    throw new Error(`Missing expected setup asset file ${asset}`);
  }

  // download and extract input files
  await refreshTag();
  await refreshRelease();
}

main().catch(error => {
  console.error(error);
  process.exit(1);
});