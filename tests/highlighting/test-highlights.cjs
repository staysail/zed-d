// SPDX-License-Identifier: MIT
// Run with Node.js and tree-sitter-cli against the extension's pinned grammar.
// Usage: node test-highlights.cjs <tree-sitter.exe> <grammar-directory>
const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { spawnSync } = require('node:child_process');

const [cli, grammar] = process.argv.slice(2);
if (!cli || !grammar) {
  console.error('Usage: node test-highlights.cjs <tree-sitter.exe> <grammar-directory>');
  process.exit(1);
}
const fixture = path.join(__dirname, 'highlights.d');
const query = path.resolve(__dirname, '..', '..', 'languages', 'd', 'highlights.scm');
function run(args) {
  const result = spawnSync(cli, args, { encoding: 'utf8', maxBuffer: 16 * 1024 * 1024 });
  assert.ifError(result.error);
  assert.equal(result.status, 0, result.stderr + result.stdout);
  return result.stdout;
}

// The pinned grammar predates tree-sitter.json. Add CLI metadata in an
// isolated copy rather than modifying the contributor's grammar checkout.
const temporary = fs.mkdtempSync(path.join(os.tmpdir(), 'zed-d-highlights-'));
let output;
try {
  const prepared = path.join(temporary, 'tree-sitter-d');
  fs.mkdirSync(prepared);
  fs.cpSync(path.join(grammar, 'src'), path.join(prepared, 'src'), { recursive: true });
  fs.writeFileSync(path.join(prepared, 'tree-sitter.json'), JSON.stringify({
    grammars: [{ name: 'd', scope: 'source.d', path: '.', 'file-types': ['d', 'di'] }],
    metadata: { version: '0.0.1', license: 'MIT' },
  }));
  const config = path.join(temporary, 'config.json');
  fs.writeFileSync(config, JSON.stringify({ 'parser-directories': [temporary] }));
  const options = ['-p', prepared, '--config-path', config];
  // Reject fixtures that only "pass" because of parser error recovery.
  run(['parse', ...options, '--quiet', fixture]);
  output = run(['query', ...options, '--captures', query, fixture]);
} finally {
  fs.rmSync(temporary, { recursive: true, force: true });
}
const captures = [...output.matchAll(
  /pattern:\s*(\d+), capture:\s*\d+ - ([\w.]+), start: \((\d+), (\d+)\), end: \((\d+), (\d+)\)/g,
)].map(([, pattern, name, row, column, endRow, endColumn]) => ({
  pattern: +pattern, name, row: +row, column: +column, endRow: +endRow, endColumn: +endColumn,
}));

let count = 0;
for (const [row, line] of fs.readFileSync(fixture, 'utf8').split(/\r?\n/).entries()) {
  const marker = line.indexOf('// expect: ');
  if (marker < 0) continue;
  const code = line.slice(0, marker);
  for (const expectation of line.slice(marker + 11).split(', ')) {
    const separator = expectation.lastIndexOf('=');
    const token = expectation.slice(0, separator);
    const expected = expectation.slice(separator + 1);
    assert.ok(separator > 0, `Malformed expectation on line ${row + 1}`);
    const index = code.indexOf(token);
    assert.ok(index >= 0, `Missing token ${token} on line ${row + 1}`);
    const column = Buffer.byteLength(code.slice(0, index));
    const endColumn = column + Buffer.byteLength(token);
    // Zed ignores private captures and lets later query patterns override
    // equal ranges. Nested captures override an enclosing string/comment.
    const matching = captures.filter(c => !c.name.startsWith('_') &&
      (c.row < row || (c.row === row && c.column <= column)) &&
      (c.endRow > row || (c.endRow === row && c.endColumn >= endColumn)));
    matching.sort((a, b) =>
      (a.endRow - a.row) - (b.endRow - b.row) ||
      (a.endColumn - a.column) - (b.endColumn - b.column) || b.pattern - a.pattern);
    assert.equal(matching[0]?.name, expected,
      `Line ${row + 1}: ${token} should be ${expected}, got ${matching[0]?.name}`);
    count++;
  }
}
assert.ok(count > 0, 'The fixture must contain highlighting assertions');
console.log(`Passed ${count} highlighting assertions; fixture parses without errors.`);
