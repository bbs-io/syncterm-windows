import shell from "shelljs";
import fetch from "node-fetch";
import path from "path";
import fs from "fs";
import ftp from "ftp-get";
import unzipper from "unzipper";
import clone from "fclone";

// syncterm path after download
const syncterm = path.normalize(`${__dirname}/../input/syncterm/syncterm.exe`);
let version = "unknown";
let built = "unknown";
let build = "unknown";

const isDev = process.env.BUILD_TYPE === "dev";

const delay = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

const cleanup = () => {
  shell.rm("-rf", "./input");
};

const getDownloadUrl = async () => {
  if (isDev) {
    return "https://syncterm.bbsdev.net/syncterm.zip";
  }

  // get latest from sourceforge
  const r = await fetch(
    "https://sourceforge.net/projects/syncterm/files/latest/download",
    {
      follow: 2,
      headers: {
        accept:
          "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
        "accept-encoding": "",
      },
    }
  ).catch((error) => clone(error));

  return r.url.replace(/-src.tgz$/, "-win32.zip");
};

const downloadAndExtractSyncTerm = async () => {
  // const zipFileUrl = "https://syncterm.bbsdev.net/syncterm.zip";
  const zipFileUrl = await getDownloadUrl();
  const outputDir = "./input/syncterm/";

  console.log(`Downloading ${zipFileUrl} to ${outputDir}`);
  shell.mkdir("-p", outputDir);

  const detail = {};

  await fetch(zipFileUrl).then((result) =>
    result.body
      .pipe(unzipper.Parse())
      .on("entry", (entry) => {
        const filePath = `${outputDir}${entry.path}`;
        shell.mkdir("-p", path.dirname(filePath));
        entry
          .pipe(fs.createWriteStream(filePath))
          .on("finish", () => {
            console.log(` Extracted: ${filePath}`);

            if (entry.path === "syncterm.exe") {
              built = entry.vars.lastModifiedDateTime;
              build = built.toJSON().replace(/\D/g, "").substr(2, 6);
              const { path, type, size } = entry;

              Object.assign(detail, {
                path,
                type,
                size,
                built,
                build,
                isDev,
              });
            }
          })
          .on("error", (error) => {
            console.error(error);
            process.exit(3);
          });
      })
      .promise()
  );
  detail.version = shell
    .exec(`${__dirname}/../input/syncterm/syncterm.exe -v`)
    .stdout.trim()
    .split(/\s+/)[1];

  version = detail.version;
  built = detail.built;
  build = detail.build;

  fs.writeFileSync(
    "./input/syncterm.json",
    JSON.stringify(detail, null, 4),
    "utf8"
  );

  await delay(500);
};

const downloadSynchronetBbsList = () => {
  const sbbslist = "ftp://ftp.synchro.net/syncterm.lst";
  const sbbslistPath = "./input/synchronet/syncterm.lst";

  console.log(`Downloading ${sbbslist} to ${sbbslistPath}`);
  shell.mkdir("-p", path.dirname(sbbslistPath));
  return new Promise((resolve, reject) =>
    ftp.get(sbbslist, sbbslistPath, (err) => (err ? reject(err) : resolve()))
  );
};

const prepareInput = async () => {
  await downloadAndExtractSyncTerm();
  await downloadSynchronetBbsList();
  await delay(100); // wait a second, in case of AV scan
};

const prepareSetupScript = () => {
  let script = fs.readFileSync("./SyncTERM-Setup.template.iss", "utf8");
  fs.writeFileSync(
    "./input/SyncTERM-Setup.iss",
    script.replace(
      /#\{VERSION\}#/g,
      isDev ? `dev-${version}-${build}` : version
    ),
    "utf8"
  );
};

async function main() {
  process.chdir(`${__dirname}/../`);

  // download and extract input files
  await cleanup();
  await prepareInput();
  await prepareSetupScript({ build, version });
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
