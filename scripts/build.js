import cp from "child_process";
import shell from "shelljs";
import path from "path";
import fs from "fs";

// syncterm path after download
const { built, build, version } = JSON.parse(
  fs.readFileSync(`${__dirname}/../input/syncterm.json`)
);
const delay = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

const cleanup = () => {
  shell.rm("-rf", "./output");
};

const buildSetup = () => {
  if (fs.existsSync("./output")) shell.rm("-rf", "./output");
  shell.mkdir("-p", "./output");
  const inno6global = path.normalize(
    "C:/Program Files (x86)/Inno Setup 6/ISCC.exe"
  );
  const inno6user = path.normalize(
    `${process.env.LOCALAPPDATA}/Programs/Inno Setup 6/ISCC.exe`
  );
  const iscc = fs.existsSync(inno6global)
    ? inno6global
    : fs.existsSync(inno6user)
    ? inno6user
    : `ISCC.exe`;

  const iss = path.normalize("./input/SyncTERM-Setup.iss");
  const result = cp.execFileSync(iscc, [iss]);
  console.log(result.toString("utf8"));
};

async function main() {
  process.chdir(`${__dirname}/../`);

  // download and extract input files
  await cleanup();
  await buildSetup();
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
