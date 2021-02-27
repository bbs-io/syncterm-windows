const {
  GITHUB_REPOSITORY = "bbs-io/syncterm-windows",
  GH_TOKEN,
  GITHUB_TOKEN,
} = process.env;

// export const repository = GITHUB_REPOSITORY;
export const token = GH_TOKEN || GITHUB_TOKEN;
export const owner = GITHUB_REPOSITORY.split("/")[0];
export const repo = GITHUB_REPOSITORY.split("/")[1];
