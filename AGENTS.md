# AGENTS.md

## Working agreement: the learner does the work, the agent guides

This repo is where the learner (the human) learns arm64 assembly on macOS by
writing it themself. The aim is the middle road: the learner does the work, and
does not get stuck in details that don't matter for what they are learning.

### The loop

1. **The agent writes a high-level plan first.** At the start of each new goal,
   write a short, chronological list of steps. Each step names a milestone and
   the concept it teaches. It does not contain the code.
2. **We walk the plan together, one step at a time.**
3. **The learner guesses the next move.** Before each step, the learner says
   what they think comes next: the instruction, system call, test, or command.
4. **The agent corrects and fills in.** Confirm what is right. Say plainly what
   is wrong and why. Then give the smallest hint that gets the learner moving.
5. **The agent detects when the learner needs tutoring.** If a guess shows a gap
   in a prerequisite concept (for example: calling convention, condition flags,
   memory layout), pause and teach that concept briefly before continuing.

### Guidance for the agent

- Don't write the solution unless the learner asks for it. Prefer hints,
  questions, and pointers to the relevant line, header, or documentation.
- Unblock the learner quickly on details outside the lesson (build flags, linker
  quirks, tool setup, boilerplate): give the answer directly, with one line on why.
- Keep each step small enough that it ends in something the learner can run or
  see.
- When the plan changes, update it and say why.

## Project board

Work for this repo is tracked on the GitHub Project
<https://github.com/users/jtigger/projects/10>. Keep the board up to date as we
work:

- Each goal is a GitHub issue in this repo, written as a user story
  ("I want ... / So that I can ..."). See issue #1 for an example.
- The board's `Status` field has five values:
  - `Todo`: not started.
  - `In Progress`: we are working on it.
  - `Ready for Review`: its scope is done and its pull request is up, but no
    review has started.
  - `In Review`: the reviewer has started reviewing.
  - `Done`: the reviewer accepted it.
- For now, the learner is the reviewer. The agent moves an issue as far as
  `Ready for Review`. Only the reviewer moves it to `In Review` or `Done`, and
  only the reviewer closes it as completed.
- Each plan step is a sub-issue of its goal issue
  (`gh issue create --parent <goal#>`). Add each sub-issue to the board
  (`gh project item-add 10 --owner jtigger --url <issue-url>`) and move its
  `Status` as the step starts and as its pull request goes up.
- Labels are grouped into categories by prefix (`<category>/<value>`). An
  issue has at most one label from each category: values within a category
  are mutually exclusive. The only category so far is `work/`, and every issue
  must have exactly one `work/` label:
  - `work/feature`: a product enhancement, something the end user can see.
  - `work/chore`: an infrastructure improvement (build, tests, tooling, docs).
  - `work/bug`: a fix for behavior that doesn't meet its specification. New
    behavior that no specification covers yet is a `work/feature`, even when
    the current behavior looks wrong.
- Sub-issues have the same labels as their parent. Whenever a parent's labels
  change, change all of its sub-issues' labels to match.
- When the plan gains a step, create its sub-issue. When the plan drops a step,
  close its sub-issue as "not planned" (`gh issue close <#> --reason "not planned"`).
- `gh project` needs the `project` token scope (`gh auth refresh -s project`).

## Branches and pull requests

- Do all work on a development branch, never directly on `main`, and put the
  branch up as a pull request.
- A pull request is an engineering task: it describes, at a high level and in
  plain language, what changes are being made. Its story (the GitHub issue)
  answers "why".
- Fill in every section of `.github/pull_request_template.md`. `gh pr create
  --body` does not apply the template, so write the sections out.
- A pull request never closes its story. The most it does is say the story's
  scope is complete and ready for review. So never write a GitHub closing
  keyword (`close`, `closes`, `closed`, `fix`, `fixes`, `fixed`, `resolve`,
  `resolves`, `resolved`) before an issue number, in a pull request or in a
  commit message. Reference the story as a plain `#N`.
