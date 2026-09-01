#!/usr/bin/env node

'use strict';

const fs = require('node:fs');
const { spawnSync } = require('node:child_process');

/**
 * Compare the current working tree and index with the distribution base ref.
 *
 * @param {string} repo - Repository working-tree path.
 * @param {string} baseRef - Git ref used as the pull request base.
 * @returns {boolean} Whether the distribution has file changes.
 * @throws {Error} If Git cannot perform the comparison.
 */
function detectDistributionChanges(repo, baseRef) {
  const result = spawnSync('git', ['diff', '--quiet', baseRef, '--'], {
    cwd: repo,
    encoding: 'utf8',
  });

  if (result.error) throw result.error;
  if (result.status === 0) return false;
  if (result.status === 1) return true;

  const detail = result.stderr.trim() || `git diff exited with status ${result.status}`;
  throw new Error(`Unable to compare the distribution tree with ${baseRef}: ${detail}`);
}

if (require.main === module) {
  try {
    const baseRef = process.argv[2];
    if (!baseRef) {
      throw new Error('Usage: node scripts/detect-distribution-changes.js <base-ref>');
    }

    const hasChanges = detectDistributionChanges(process.cwd(), baseRef);
    const output = `has_changes=${hasChanges}\n`;
    if (process.env.GITHUB_OUTPUT) fs.appendFileSync(process.env.GITHUB_OUTPUT, output, 'utf8');
    else process.stdout.write(output);

    console.log(
      hasChanges
        ? 'The synchronized distribution contains file changes.'
        : 'The synchronized distribution tree is unchanged.',
    );
  } catch (error) {
    console.error(`ERROR: ${error.message}`);
    process.exitCode = 1;
  }
}

module.exports = { detectDistributionChanges };
