import gh, { octokit, owner, repo } from "./lib/gh";

async function handleWorkflow(workflow_id) {
  let working = true;
  while (working) {
    const {
      data: { total_count, workflow_runs: runs },
    } = await octokit.actions.listWorkflowRuns({
      owner,
      repo,
      workflow_id,
    });

    while (runs.length > 7) {
      const { id: run_id } = runs.pop();
      console.log(`Deleting run: ${run_id}`);
      await octokit.actions.deleteWorkflowRun({
        owner,
        repo,
        run_id,
      });
    }

    working = total_count > runs.length;
  }
}

async function cleanupWorkflows() {
  const per_page = 100;
  let lastPage = 1; // will adjust after request
  for (let page = 1; page <= lastPage; page++) {
    const {
      data: { total_count, workflows },
    } = await octokit.actions.listRepoWorkflows({
      owner,
      repo,
      per_page,
      page,
    });

    // calculate new lastPage
    lastPage = Math.floor(total_count / per_page) + 1;

    for (const wf of workflows) {
      console.log(`Handling Workflow: ${wf.name}`);
      await handleWorkflow(wf.id);
    }
  }
}

async function cleanupNightlies() {
  // get list of tag names
  const tags = await gh
    .tags("dev-")
    .then((list) => list.map((t) => t.ref.split("/").pop()));

  // sort based of the build stamp as an integer;
  tags.sort((a, b) => ~~b.split("-").pop() - ~~a.split("-").pop());

  while (tags.length > 14) {
    const tag = tags.pop();
    const r = await gh.release(tag);
    if (r) {
      await gh.deleteRelease(r.id);
    }
    await gh.deleteTag(tag);
  }
}

async function cleanupAbandonedReleases() {
  const releases = (await gh.allReleases())
    .filter((r) => r.tag_name.startsWith("dev-"))
    .map((r) => ({ id: r.id, tag: r.tag_name }))
    .sort((a, b) => ~~b.tag.split("-").pop() - ~~a.tag.split("-").pop());

  while (releases.length > 14) {
    const r = releases.pop();
    await gh.deleteRelease(r.id);
  }
  console.log(releases);
}

async function main() {
  await cleanupWorkflows();
  await cleanupNightlies();
  // await cleanupAbandonedReleases();
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
