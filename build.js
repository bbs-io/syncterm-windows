import shell from 'shelljs';
import fetch from 'node-fetch';
import path from 'path';
import fs, { promises as fsp } from 'fs';
import unzipper from 'unzipper';
import PromiseFtp from 'promise-ftp';

// syncterm path after download
const syncterm = path.normalize(`${__dirname}/input/syncterm/syncterm.exe`);

const delay = ms => new Promise(resolve => setTimeout(resolve, ms));

const downloadAndExtract = (zipFileUrl, outputDir, matcher = () => true) => {
  console.log(`Downloading ${zipFileUrl} to ${outputDir}`);
  shell.mkdir('-p', outputDir);

  return fetch(zipFileUrl).then(res => res.body
    .pipe(unzipper.Parse())
    .on('entry', function (entry) {
      if (!matcher(entry)) {
        entry.autodrain();
        return;
      }
      const outFile = `${outputDir}/${entry.path}`;
      console.log('Extracting: ', outFile);
      shell.mkdir('-p', path.dirname(outFile));
      entry.pipe(fs.createWriteStream(outFile));
    })
    .promise()
  );
}

const downloadTelnetGuideList = () => {
  // listDate for downloading Telnet BBS List Monthly Archive
  const listDate = new Date();
  if (listDate.getDate() === 1) {
    // first day of the month, use last month's list - avoid missing file issue
    listDate.setDate(-1);
  }
  let MM = listDate.getMonth() + 1;
  if (MM < 10) MM = '0' + MM;
  const YY = listDate.getFullYear().toString().substr(2);

  return downloadAndExtract(`https://www.telnetbbsguide.com/bbslist/ibbs${MM}${YY}.zip`, './input/telnetbbsguide', entry => entry.path === 'syncterm.lst'); 
}

const downloadSynchronetBbsList = () => {
  console.log('Downloading ftp://ftp.synchro.net/syncterm.lst to ./input/synchronet/syncterm.lst');
  const ftp = new PromiseFtp()
  return ftp.connect({ host: 'ftp.synchro.net' })
    .then(() => ftp.get('syncterm.lst'))
    .then(stream => new Promise((resolve, reject) => {
      shell.mkdir('-p', './input/synchronet')
      stream.pipe(fs.createWriteStream('./input/synchronet/syncterm.lst'))
        .once('close', resolve)
        .once('finish', resolve)
        .once('error', reject);
    }))
    .then(() => delay(500))
    .then(() => ftp.end());
}

const prepareInput = async () => {
  if (fs.existsSync('./input')) shell.rm('-rf', './input');
  await downloadAndExtract('https://syncterm.bbsdev.net/syncterm.zip', './input/syncterm');
  // await downloadTelnetGuideList();
  await downloadSynchronetBbsList();
  await delay(1000); // wait a second, in case of AV scan
};

const getBuildAndVersion = () => {
  const stats = fs.statSync(syncterm);
  const build = stats.ctime.toJSON().replace(/\D/g,'').substr(0,14);

  // shows syncterm version output
  console.log('\n');
  const version = shell.exec(`${syncterm} -v`).stdout.trim().split(/\s+/)[1];
  console.log('  compiled on ', stats.ctime, '\n');

  return {version, build};
}

const prepareSetupScript = ({ build, version }) => {
  let script = fs.readFileSync('./SyncTERM-Setup.template.iss', 'utf8');
  fs.writeFileSync('./input/SyncTERM-Setup.iss', script.replace(/#\{VERSION\}#/g, `${version}-${build}`), 'utf8');
};

async function main() {
  process.chdir(__dirname);

  // download and extract input files
  // await prepareInput();

  await prepareSetupScript(await getBuildAndVersion());
}

main().catch(error => {
  console.error(error);
  process.exit(1);
});