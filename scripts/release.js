import path from "path";
import fs from "fs";
import gh from "./lib/gh";

// Get details from prebuild output
process.chdir(`${__dirname}/../`);
const { built, build, version, isDev } = JSON.parse(
  fs.readFileSync(`${__dirname}/../input/syncterm.json`)
);

const delay = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

const getReleaseInfo = (tag) => {
  if (tag === "dev") {
    return {
      name: "Latest Development Release",
      desc: `checked daily at 12:00 UTC\n\n- version: ${version}\n- built: ${built}`,
    };
  } else if (tag === "stable") {
    return {
      name: "Latest Stable Release",
      desc: `checked daily at 12:00 UTC\n\n- version: ${version}\n- built: ${built}`,
    };
  } else if (tag.indexOf("v") === 0) {
    return {
      name: `Release ${tag}`,
      desc: `- version: ${version}\n- built: ${built}`,
    };
  }

  return {
    name: `Development Release ${tag}`,
    desc: `- version: ${version}\n- built: ${built}`,
  };
};

const handleRelease = async ({ asset, tags }) => {
  const fileName = path.basename(asset);
  const commit = await gh.getCurrentCommit();

  for (const t of tags) {
    console.log(`Handling tag:`, t);
    const { name, desc } = getReleaseInfo(t);
    let tag = await gh.tag(t);
    if (!tag) {
      console.log("Creating Tag:", t);
      tag = await gh.createTag(commit, t);
    }

    let release = await gh.release(t);
    if (!release) {
      console.log("Creating Release:", t);
      release = await gh.createRelease(t, {
        name,
        body: desc,
        prerelease: isDev,
      });
    }

    const assets = await gh.assets(release.id);
    let hasAsset = !!assets.find(
      (a) => a.name.toLowerCase() === fileName.toLowerCase()
    );

    if (hasAsset && tag.object.sha != commit) {
      console.log(`Forcing Update:`, t);
      await gh.deleteRelease(release.id);
      await delay(1000);
      await gh.deleteTag(t);
      await delay(1000);
      tag = await gh.createTag(commit, t);
      release = await gh.createRelease(t, {
        name,
        body: desc,
        prerelease: isDev,
      });
      hasAsset = false;
    }

    if (!hasAsset) {
      console.log(`Uploading asset ${t}:`, fileName);
      await gh.uploadAsset(release.id, fileName, asset);
    }
  }
};

const main = async () => {
  const asset = isDev
    ? `./output/SyncTERM-dev-${version}-${build}-Setup.exe`
    : `./output/SyncTERM-${version}-Setup.exe`;

  console.log({ version, build, isDev, asset });

  await handleRelease({
    asset,
    tags: isDev
      ? ["dev", `dev-${version}-${build}`]
      : ["stable", `v${version}`],
  });
};

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
