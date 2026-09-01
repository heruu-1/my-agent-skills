const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const WORKFLOW_DIR = path.join(__dirname, '..', '.github', 'workflows');
const REQUIRED_PINS = new Map([
  ['actions/checkout', '3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1'],
  ['actions/setup-node', '820762786026740c76f36085b0efc47a31fe5020 # v7.0.0'],
]);

test('official Node actions use the reviewed Node 24 commit pins', () => {
  const observedActions = new Set();

  for (const name of fs.readdirSync(WORKFLOW_DIR).filter((file) => file.endsWith('.yml'))) {
    const workflow = fs.readFileSync(path.join(WORKFLOW_DIR, name), 'utf8');

    for (const [action, pin] of REQUIRED_PINS) {
      const usesAction = new RegExp(`uses:\\s+${action.replace('/', '\\/')}@([^\\r\\n]+)`, 'g');
      for (const match of workflow.matchAll(usesAction)) {
        observedActions.add(action);
        assert.equal(match[1].trim(), pin, `${name} must pin ${action} to its reviewed Node 24 release`);
      }
    }
  }

  assert.deepEqual(observedActions, new Set(REQUIRED_PINS.keys()));
});
