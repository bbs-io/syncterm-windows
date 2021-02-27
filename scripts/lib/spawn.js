import cp from "child_process";
import parseArgs from "string-argv";
import which from "which";

const cache = {};

export default (command) => {
  const [cmd, ...args] = parseArgs(command);
  let exe = (cache[cmd] = cache[cmd] || which.sync(cmd));
  const { status, stdout, stderr } = cp.spawnSync(exe, args, {
    env: { ...process.env, NO_COLOR: "1" },
    encoding: "utf-8",
  });
  if (status === 0) return stdout.trim();
  throw Object.assign(new Error("Error running external command."), {
    status,
    stdout,
    stderr,
  });
};
