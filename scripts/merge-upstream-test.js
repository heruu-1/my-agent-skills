const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { execFileSync } = require('node:child_process');

const { FORK_OWNED_CONFLICTS, mergeUpstream } = require('./merge-upstream');
const { INSTALL_DOCS } = require('./validate-distribution');

function git(repo, ...args) {
  return execFileSync('git', args, { cwd: repo, encoding: 'utf8' }).trim();
}

function write(repo, relativePath, contents) {
  const filePath = path.join(repo, relativePath);
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  fs.writeFileSync(filePath, contents);
}

function createConflictingRepository(conflictPath) {
  const repo = fs.mkdtempSync(path.join(os.tmpdir(), 'merge-upstream-'));
  git(repo, 'init', '-b', 'main');
  git(repo, 'config', 'user.name', 'Merge Upstream Test');
  git(repo, 'config', 'user.email', 'merge-upstream@example.invalid');
  git(repo, 'config', 'core.autocrlf', 'false');

  write(repo, conflictPath, 'base\n');
  write(repo, 'upstream-only.txt', 'base\n');
  git(repo, 'add', '.');
  git(repo, 'commit', '-m', 'base');
  git(repo, 'branch', 'upstream');

  write(repo, conflictPath, 'fork customization\n');
  git(repo, 'add', conflictPath);
  git(repo, 'commit', '-m', 'customize fork');

  git(repo, 'checkout', 'upstream');
  write(repo, conflictPath, 'upstream customization\n');
  write(repo, 'upstream-only.txt', 'updated upstream\n');
  git(repo, 'add', '.');
  git(repo, 'commit', '-m', 'update upstream');
  git(repo, 'checkout', 'main');

  return repo;
}

test('resolves allowlisted fork metadata conflicts while retaining clean upstream changes', () => {
  const repo = createConflictingRepository('README.md');

  const result = mergeUpstream(repo, 'upstream');

  assert.deepEqual(result.resolvedConflicts, ['README.md']);
  assert.equal(fs.readFileSync(path.join(repo, 'README.md'), 'utf8'), 'fork customization\n');
  assert.equal(fs.readFileSync(path.join(repo, 'upstream-only.txt'), 'utf8'), 'updated upstream\n');
  assert.equal(git(repo, 'rev-list', '--parents', '-n', '1', 'HEAD').split(' ').length, 3);
});

test('treats every distribution-rewritten installer document as fork-owned', () => {
  const missing = INSTALL_DOCS.filter((file) => !FORK_OWNED_CONFLICTS.has(file));

  assert.deepEqual(missing, []);
});

test('fails closed and aborts when a conflict is outside the fork-owned allowlist', () => {
  const conflictPath = 'skills/example/SKILL.md';
  const repo = createConflictingRepository(conflictPath);
  const before = git(repo, 'rev-parse', 'HEAD');

  assert.throws(
    () => mergeUpstream(repo, 'upstream'),
    /Refusing to auto-resolve conflicts outside the fork-owned allowlist: skills\/example\/SKILL\.md/,
  );

  assert.equal(git(repo, 'rev-parse', 'HEAD'), before);
  assert.equal(fs.existsSync(path.join(repo, '.git', 'MERGE_HEAD')), false);
  assert.equal(fs.readFileSync(path.join(repo, conflictPath), 'utf8'), 'fork customization\n');
});

test('rejects a dirty working tree without changing repository state', () => {
  const repo = createConflictingRepository('README.md');
  const before = git(repo, 'rev-parse', 'HEAD');
  write(repo, 'local-only.txt', 'uncommitted work\n');

  assert.throws(
    () => mergeUpstream(repo, 'upstream'),
    /Refusing to merge upstream into a dirty working tree/,
  );

  assert.equal(git(repo, 'rev-parse', 'HEAD'), before);
  assert.equal(fs.existsSync(path.join(repo, '.git', 'MERGE_HEAD')), false);
  assert.equal(fs.readFileSync(path.join(repo, 'local-only.txt'), 'utf8'), 'uncommitted work\n');
});

test('weekly sync workflow invokes the guarded upstream merge script', () => {
  const workflow = fs.readFileSync(
    path.join(__dirname, '..', '.github', 'workflows', 'weekly-upstream-sync.yml'),
    'utf8',
  );

  assert.match(workflow, /node scripts\/merge-upstream\.js upstream\/main/);
  assert.doesNotMatch(workflow, /git merge --no-edit upstream\/main/);
});

test('weekly sync keeps main as the pull request base and uses a separate sync branch', () => {
  const workflow = fs.readFileSync(
    path.join(__dirname, '..', '.github', 'workflows', 'weekly-upstream-sync.yml'),
    'utf8',
  );

  assert.match(workflow, /fetch-depth: 0\s+ref: main/);
  assert.match(workflow, /branch: automation\/upstream-sync\s+delete-branch: true\s+base: main/);
  assert.doesNotMatch(workflow, /git checkout -B automation\/upstream-sync/);
});

test('weekly sync skips pull request creation when the merged tree is unchanged', () => {
  const workflow = fs.readFileSync(
    path.join(__dirname, '..', '.github', 'workflows', 'weekly-upstream-sync.yml'),
    'utf8',
  );

  assert.match(workflow, /id: sync_diff/);
  assert.match(workflow, /git diff --quiet origin\/main --/);
  assert.match(
    workflow,
    /name: Open sync pull request\s+if: \$\{\{ steps\.sync_diff\.outputs\.has_changes == 'true' \}\}/,
  );
});
