import shell from "shelljs";
import fetch from "node-fetch";
import path from "path";
import fs from "fs";
import FtpClient from "ftp";
import unzipper from "unzipper";
import clone from "fclone";

// syncterm path after download
const syncterm = path.normalize(`${__dirname}/../input/syncterm/syncterm.exe`);

const detail = {};

let version = "unknown";
let built = "unknown";
let build = "unknown";
let bbslist = null;

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

  await fetch(zipFileUrl).then(
    (result) =>
      new Promise((resolve, reject) => {
        result.body
          .pipe(fs.createWriteStream("./input/syncterm.zip"))
          .on("error", reject)
          .on("close", resolve);
      })
  );

  await delay(100);

  await fs
    .createReadStream("./input/syncterm.zip")
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

            // fix offset - time is seems off by 4 hrs
            built.setMinutes(built.getMinutes() + 4 * 60);

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
    .promise();

  version = shell
    .exec(`${__dirname}/../input/syncterm/syncterm.exe -v`)
    .stdout.trim()
    .split(/\s+/)[1];
};

const downloadSynchronetBbsList = () =>
  new Promise((resolve, reject) => {
    const sbbslist = "ftp://ftp.synchro.net/syncterm.lst";
    const sbbslistPath = "./input/synchronet/syncterm.lst";

    console.log(`Downloading ${sbbslist} to ${sbbslistPath}`);

    const ftp = new FtpClient();
    ftp.on("error", reject);
    ftp.on("ready", () => {
      ftp.lastMod("/syncterm.lst", (error, lastMod) => {
        if (error) return reject(error);

        // fix offset
        lastMod.setMinutes(
          -1 * lastMod.getTimezoneOffset() + lastMod.getMinutes()
        );

        // stow when the list was created
        bbslist = lastMod;

        shell.mkdir("-p", "./input/synchronet");
        ftp.get("/syncterm.lst", (error, readStream) => {
          if (error) return reject(error);
          readStream
            .pipe(fs.createWriteStream(sbbslistPath))
            .on("error", reject)
            .on("close", resolve);
        });
      });
    });
    ftp.connect({
      host: "ftp.synchro.net",
      port: 21,
    });
  }).then(() => delay(500));

const prepareInput = async () => {
  await downloadSynchronetBbsList();
  await downloadAndExtractSyncTerm();
  fs.writeFileSync(
    "./input/syncterm.json",
    JSON.stringify(
      {
        version,
        built,
        build,
        bbslist,
        isDev,
      },
      null,
      4
    ),
    "utf8"
  );

  await delay(500); // wait half a second, in case of AV scan
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

main()
  .then(() => delay(100))
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
