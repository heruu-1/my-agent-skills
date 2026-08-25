#!/usr/bin/env node

'use strict';

const fs = require('node:fs');
const path = require('node:path');

function loadBundle(root, bundleName) {
  const manifestPath = path.join(root, 'bundles', bundleName, 'bundle.json');
  if (!fs.existsSync(manifestPath)) throw new Error(`Unknown bundle: ${bundleName}`);
  const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
  if (manifest.name !== bundleName || !Array.isArray(manifest.skills) || manifest.skills.length === 0) {
    throw new Error(`Invalid bundle manifest: ${manifestPath}`);
  }
  return manifest;
}

function buildBundle(rootPath, bundleName, outPath) {
  const root = path.resolve(rootPath);
  const out = path.resolve(outPath);
  if (out === root || out.startsWith(`${root}${path.sep}`)) {
    throw new Error('Bundle output must be outside the source repository');
  }
  const manifest = loadBundle(root, bundleName);
  if (fs.existsSync(out) && fs.readdirSync(out).length > 0) {
    throw new Error(`Output directory is not empty: ${out}`);
  }
  fs.mkdirSync(path.join(out, 'skills'), { recursive: true });
  for (const skill of manifest.skills) {
    const source = path.join(root, 'skills', skill);
    if (!fs.existsSync(path.join(source, 'SKILL.md'))) throw new Error(`Bundle skill is missing: ${skill}`);
    fs.cpSync(source, path.join(out, 'skills', skill), { recursive: true, errorOnExist: true });
  }
  const references = path.join(root, 'references');
  if (fs.existsSync(references)) fs.cpSync(references, path.join(out, 'references'), { recursive: true, errorOnExist: true });
  fs.writeFileSync(path.join(out, 'bundle.json'), `${JSON.stringify(manifest, null, 2)}\n`);
  return manifest;
}

function parseArgs(argv) {
  const args = {};
  for (let index = 0; index < argv.length; index += 1) {
    if (argv[index] === '--bundle') args.bundle = argv[++index];
    else if (argv[index] === '--out') args.out = argv[++index];
    else throw new Error(`Unknown argument: ${argv[index]}`);
  }
  if (!args.bundle || !args.out) throw new Error('Usage: node scripts/build-bundle.js --bundle <name> --out <directory>');
  return args;
}

if (require.main === module) {
  try {
    const args = parseArgs(process.argv.slice(2));
    const manifest = buildBundle(path.join(__dirname, '..'), args.bundle, args.out);
    console.log(`Built ${manifest.name} (${manifest.skills.length} skills) at ${path.resolve(args.out)}`);
  } catch (error) {
    console.error(`ERROR: ${error.message}`);
    process.exitCode = 1;
  }
}

module.exports = { buildBundle, loadBundle, parseArgs };
