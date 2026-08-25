#!/usr/bin/env node

'use strict';

const fs = require('node:fs');
const path = require('node:path');

const INSTALL_DOCS = [
  'README.md',
  'docs/adoption-guide.md',
  'docs/antigravity-setup.md',
  'docs/codex-setup.md',
  'docs/commandcode-setup.md',
  'docs/developer-onboarding.md',
  'docs/gemini-cli-setup.md',
  'docs/getting-started.md',
  'docs/opencode-setup.md',
];

const INSTALL_COMMAND = /(?:npx skills add|git clone|plugin marketplace add|plugin install|gemini skills install|cmd skills add|agy plugin install|codex plugin marketplace add)[^\r\n]*addyosmani\/agent-skills/i;

function validateInstallText(text, label) {
  return INSTALL_COMMAND.test(text)
    ? [`${label}: installer still points at the upstream repository`] 
    : [];
}

function readJson(filePath, errors) {
  try {
    return JSON.parse(fs.readFileSync(filePath, 'utf8'));
  } catch (error) {
    errors.push(`${filePath}: ${error.message}`);
    return null;
  }
}

function validateDistribution(rootPath) {
  const root = path.resolve(rootPath);
  const errors = [];
  const skillsRoot = path.join(root, 'skills');
  const skillNames = fs.existsSync(skillsRoot)
    ? fs.readdirSync(skillsRoot, { withFileTypes: true })
      .filter((entry) => entry.isDirectory() && fs.existsSync(path.join(skillsRoot, entry.name, 'SKILL.md')))
      .map((entry) => entry.name)
      .sort()
    : [];

  const catalogPath = path.join(root, 'catalog', 'skills.json');
  const catalog = readJson(catalogPath, errors);
  if (catalog) {
    if (catalog.total_skills !== skillNames.length) {
      errors.push(`catalog total_skills=${catalog.total_skills} but discovered ${skillNames.length}`);
    }
    if (catalog.extension_skills !== catalog.skills.length) {
      errors.push(`catalog extension_skills=${catalog.extension_skills} but lists ${catalog.skills.length}`);
    }
    const catalogNames = catalog.skills.map((skill) => skill.name).sort();
    const missing = catalogNames.filter((name) => !skillNames.includes(name));
    if (missing.length) errors.push(`catalog names do not exist in skills/: ${missing.join(', ')}`);
    const provenance = catalog.provenance || {};
    if (provenance.source_repository !== catalog.repository) errors.push('catalog provenance repository mismatch');
    if (!/^[0-9a-f]{7,40}$/i.test(provenance.source_commit || '')) errors.push('catalog provenance source_commit is invalid');
    if (!/^\d{4}-\d{2}-\d{2}$/.test(provenance.last_verified || '')) errors.push('catalog provenance last_verified is invalid');
    const requiredAgents = ['codex', 'claude-code', 'cursor', 'gemini-cli', 'antigravity', 'opencode'];
    for (const agent of requiredAgents) {
      if (!provenance.compatibility?.includes(agent)) errors.push(`catalog compatibility missing ${agent}`);
    }
  }

  const plugin = readJson(path.join(root, '.codex-plugin', 'plugin.json'), errors);
  if (plugin && catalog && plugin.version !== catalog.release) {
    errors.push(`plugin version ${plugin.version} does not match catalog release ${catalog.release}`);
  }

  const bundlesRoot = path.join(root, 'bundles');
  if (!fs.existsSync(bundlesRoot)) {
    errors.push('bundles/: directory missing');
  } else if (catalog) {
    const catalogByBundle = new Map();
    for (const skill of catalog.skills) {
      if (!catalogByBundle.has(skill.bundle)) catalogByBundle.set(skill.bundle, []);
      catalogByBundle.get(skill.bundle).push(skill.name);
    }
    for (const bundleName of catalogByBundle.keys()) {
      const manifestPath = path.join(bundlesRoot, bundleName, 'bundle.json');
      const manifest = readJson(manifestPath, errors);
      if (!manifest) continue;
      if (manifest.version !== catalog.release) errors.push(`${bundleName}: version does not match catalog release`);
      const expected = [...catalogByBundle.get(bundleName)].sort();
      const actual = Array.isArray(manifest.skills) ? [...manifest.skills].sort() : [];
      if (JSON.stringify(actual) !== JSON.stringify(expected)) errors.push(`${bundleName}: skills do not match catalog`);
    }
  }

  for (const relativePath of INSTALL_DOCS) {
    const filePath = path.join(root, relativePath);
    if (!fs.existsSync(filePath)) {
      errors.push(`${relativePath}: missing install document`);
      continue;
    }
    errors.push(...validateInstallText(fs.readFileSync(filePath, 'utf8'), relativePath));
  }

  for (const workflow of ['.github/workflows/ci.yml', '.github/workflows/weekly-upstream-sync.yml']) {
    if (!fs.existsSync(path.join(root, workflow))) errors.push(`${workflow}: workflow missing`);
  }
  const readme = fs.existsSync(path.join(root, 'README.md')) ? fs.readFileSync(path.join(root, 'README.md'), 'utf8') : '';
  if (!readme.includes('## All 39 Skills')) errors.push('README.md: 39-skill catalog heading missing');

  return { errors, skillCount: skillNames.length };
}

if (require.main === module) {
  const result = validateDistribution(process.argv[2] || path.join(__dirname, '..'));
  if (result.errors.length) {
    for (const error of result.errors) console.error(`ERROR: ${error}`);
    process.exitCode = 1;
  } else {
    console.log(`Distribution validation passed (${result.skillCount} skills).`);
  }
}

module.exports = { validateDistribution, validateInstallText };
