import shell from 'shelljs';
import fetch from 'node-fetch';
import path from 'path';
import fs, { promises as fsp } from 'fs';
import ftp from 'ftp-get';
import unzipper from 'unzipper';

// syncterm path after download
const syncterm = path.normalize(`${__dirname}/../input/syncterm/syncterm.exe`);
let version = 'unknown';
let built = 'unknown';
let build = 'unknown';
let setupFile = null;

const delay = ms => new Promise(resolve => setTimeout(resolve, ms));

const cleanup = () => {
  shell.rm('-rf', './input');
}

const downloadAndExtractSyncTerm = async () => {
  const zipFileUrl = 'https://syncterm.bbsdev.net/syncterm.zip';
  const outputDir = './input/syncterm/';

  console.log(`Downloading ${zipFileUrl} to ${outputDir}`);
  shell.mkdir('-p', outputDir);

  await fetch(zipFileUrl).then(result =>
    result.body.pipe(unzipper.Parse())
      .on('entry', entry => {
        const filePath = `${outputDir}${entry.path}`;
        shell.mkdir('-p', path.dirname(filePath))
        entry.pipe(fs.createWriteStream(filePath))
          .on('finish', () => {
            console.log(` Extracted: ${filePath}`);
            if (entry.path === 'syncterm.exe') {
              built = entry.vars.lastModifiedDateTime
              build = built.toJSON().replace(/\D/g, '').substr(2, 6);
              version = shell.exec(`${syncterm} -v`).stdout.trim().split(/\s+/)[1];

              const { path, type, size } = entry;
              fs.writeFileSync('./input/syncterm.json', JSON.stringify({ path, type, size, version, built, build }, null, 4), 'utf8');
            }
          })
          .on('error', error => {
            console.error(error);
            process.exit(3);
          });
      }
      )
      .promise()
  );
  await delay(500);
  
}

const downloadSynchronetBbsList = () => {
  const sbbslist = 'ftp://ftp.synchro.net/syncterm.lst';
  const sbbslistPath = './input/synchronet/syncterm.lst';

  console.log(`Downloading ${sbbslist} to ${sbbslistPath}`);
  shell.mkdir('-p', path.dirname(sbbslistPath));
  return new Promise((resolve, reject) => ftp.get(sbbslist, sbbslistPath, err => err ? reject(err) : resolve()));
}

const prepareInput = async () => {
  await downloadAndExtractSyncTerm();
  await downloadSynchronetBbsList();
  await delay(100); // wait a second, in case of AV scan
};

const prepareSetupScript = () => {
  let script = fs.readFileSync('./SyncTERM-Setup.template.iss', 'utf8');
  fs.writeFileSync('./input/SyncTERM-Setup.iss', script.replace(/#\{VERSION\}#/g, `${version}-${build}`), 'utf8');
};

async function main() {
  process.chdir(`${__dirname}/../`);

  // download and extract input files
  await cleanup();
  await prepareInput();
  await prepareSetupScript({ build, version });
}

main().catch(error => {
  console.error(error);
  process.exit(1);
});