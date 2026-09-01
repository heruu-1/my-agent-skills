#!/usr/bin/env node

'use strict';

const { spawnSync } = require('node:child_process');
const { INSTALL_DOCS } = require('./validate-distribution');

const FORK_OWNED_CONFLICTS = new Set([
  '.agents/plugins/marketplace.json',
  '.claude-plugin/marketplace.json',
  '.claude-plugin/plugin.json',
  '.codex-plugin/plugin.json',
  ...INSTALL_DOCS,
  'docs/comparison.md',
  'plugin.json',
]);

function runGit(repo, args, echo = false) {
  const result = spawnSync('git', args, {
    cwd: repo,
    encoding: 'utf8',
  });

  if (echo) {
    if (result.stdout) process.stdout.write(result.stdout);
    if (result.stderr) process.stderr.write(result.stderr);
  }

  if (result.error) throw result.error;
  return result;
}

function abortMerge(repo) {
  const mergeHead = runGit(repo, ['rev-parse', '--quiet', '--verify', 'MERGE_HEAD']);
  if (mergeHead.status === 0) runGit(repo, ['merge', '--abort'], true);
}

/**
 * Merge an upstream Git ref into a clean repository, automatically preferring
 * the fork version only when every conflict is in the fork-owned allowlist.
 *
 * @param {string} repo - Repository working-tree path.
 * @param {string} upstreamRef - Git ref to merge, such as `upstream/main`.
 * @returns {{resolvedConflicts: string[]}} Paths auto-resolved by the guarded merge.
 * @throws {Error} If the tree is dirty, Git inspection or merging fails, or a
 * conflict falls outside the fork-owned allowlist. Failed merges are aborted.
 */
function mergeUpstream(repo, upstreamRef) {
  const status = runGit(repo, ['status', '--porcelain']);
  if (status.status !== 0) throw new Error(status.stderr.trim() || 'Unable to inspect working tree');
  if (status.stdout.trim()) throw new Error('Refusing to merge upstream into a dirty working tree');

  const initial = runGit(repo, ['merge', '--no-edit', upstreamRef], true);
  if (initial.status === 0) return { resolvedConflicts: [] };

  const conflictResult = runGit(repo, ['diff', '--name-only', '--diff-filter=U']);
  const conflicts = conflictResult.stdout
    .split(/\r?\n/)
    .map((file) => file.trim().replaceAll('\\', '/'))
    .filter(Boolean)
    .sort();

  if (conflicts.length === 0) {
    abortMerge(repo);
    throw new Error(initial.stderr.trim() || 'Upstream merge failed without file conflicts');
  }

  const disallowed = conflicts.filter((file) => !FORK_OWNED_CONFLICTS.has(file));
  if (disallowed.length) {
    abortMerge(repo);
    throw new Error(
      `Refusing to auto-resolve conflicts outside the fork-owned allowlist: ${disallowed.join(', ')}`,
    );
  }

  abortMerge(repo);
  const resolved = runGit(repo, ['merge', '--no-edit', '-X', 'ours', upstreamRef], true);
  if (resolved.status !== 0) {
    abortMerge(repo);
    throw new Error(resolved.stderr.trim() || 'Guarded upstream merge failed');
  }

  console.log(`Auto-resolved fork-owned conflicts: ${conflicts.join(', ')}`);
  return { resolvedConflicts: conflicts };
}

if (require.main === module) {
  try {
    const upstreamRef = process.argv[2];
    if (!upstreamRef) throw new Error('Usage: node scripts/merge-upstream.js <upstream-ref>');
    mergeUpstream(process.cwd(), upstreamRef);
  } catch (error) {
    console.error(`ERROR: ${error.message}`);
    process.exitCode = 1;
  }
}

module.exports = { FORK_OWNED_CONFLICTS, mergeUpstream };
