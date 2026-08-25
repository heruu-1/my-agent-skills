'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const test = require('node:test');
const { buildBundle } = require('./build-bundle');

test('builds a bundle with its manifest and skill sources', () => {
  const root = path.resolve(__dirname, '..');
  const out = fs.mkdtempSync(path.join(os.tmpdir(), 'heru-bundle-'));
  const result = buildBundle(root, 'heru-research-ml', out);
  assert.equal(result.skills.length, 5);
  assert.equal(JSON.parse(fs.readFileSync(path.join(out, 'bundle.json'), 'utf8')).name, 'heru-research-ml');
  for (const name of result.skills) {
    assert.ok(fs.existsSync(path.join(out, 'skills', name, 'SKILL.md')));
  }
  fs.rmSync(out, { recursive: true, force: true });
});

test('rejects an unknown bundle', () => {
  assert.throws(() => buildBundle(path.resolve(__dirname, '..'), 'missing-bundle', os.tmpdir()), /Unknown bundle/);
});

test('all checked-in bundles can be built', () => {
  const root = path.resolve(__dirname, '..');
  const bundles = fs.readdirSync(path.join(root, 'bundles'), { withFileTypes: true })
    .filter((entry) => entry.isDirectory())
    .map((entry) => entry.name);
  for (const bundle of bundles) {
    const out = fs.mkdtempSync(path.join(os.tmpdir(), 'heru-bundle-all-'));
    const result = buildBundle(root, bundle, out);
    assert.ok(result.skills.length > 0, `${bundle} should contain skills`);
    fs.rmSync(out, { recursive: true, force: true });
  }
});
