const test = require('node:test');
const assert = require('node:assert/strict');
const { validateDistribution, validateInstallText } = require('./validate-distribution');

test('the checked-in distribution has complete metadata and install routing', () => {
  const result = validateDistribution(__dirname + '\\..');
  assert.deepEqual(result.errors, []);
});

test('rejects an installer that points at the upstream repository', () => {
  const errors = validateInstallText(
    'npx skills add addyosmani/agent-skills',
    'fixture.md',
  );
  assert.equal(errors.length, 1);
  assert.match(errors[0], /upstream repository/);
});

test('accepts the Heru distribution repository in install text', () => {
  assert.deepEqual(
    validateInstallText('npx skills add heruu-1/my-agent-skills', 'fixture.md'),
    [],
  );
});
