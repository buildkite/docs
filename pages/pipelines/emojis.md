# Emojis

Buildkite supports over 300 custom emojis which you can use in your Pipelines and terminal output.

To use an emoji, write the name of the emoji in between colons, like `\:buildkite\:` which shows up as :buildkite:.

A few common emojis are listed below, but you can see the [full list of available emoji](https://github.com/buildkite/emojis#emoji-reference) on GitHub.

<table>
  <thead>
    <tr>
      <th>Name</th>
      <th>Emoji</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>\:buildkite\:</code></td>
      <td>:buildkite:</td>
    </tr>
    <tr>
      <td><code>\:one-does-not-simply\:</code></td>
      <td>:one-does-not-simply:</td>
    </tr>
    <tr>
      <td><code>\:nomad\:</code></td>
      <td>:nomad:</td>
    </tr>
    <tr>
      <td><code>\:algolia\:</code></td>
      <!-- vale off -->
      <td>:algolia:</td>
      <!-- vale on -->
    </tr>
  </tbody>
</table>

## Adding custom emojis

Add your own emoji by opening a [pull request](https://github.com/buildkite/emojis#contributing-new-emoji) containing a 64x64 PNG image and a name to the emoji repository.

> 🚧 Buildkite emojis in other tools
> Buildkite loads custom emojis as <a href="https://github.com/buildkite/emojis">images</a>. Other tools, such as GitHub, might not display the images correctly, and will only show the `:text-form:`.
// streams.mjs
import { pipeline } from 'node:stream/promises';
import { createReadStream, createWriteStream } from 'node:fs';
import { createGzip } from 'node:zlib';

// ensure you have a `package.json` file for this test!
await pipeline
(
  createReadStream('package.json'),
  createGzip(),
  createWriteStream('package.json.gz')
);

// run with `node streams.mjs`
// tests.mjs
import assert from 'node:assert';
import test from 'node:test';

test('that 1 is equal 1', () => {
  assert.strictEqual(1, 1);
});

test('that throws as 1 is not equal 2', () => {
  // throws an exception because 1 != 2
  assert.strictEqual(1, 2);
});

// run with `node tests.mjs`
// crypto.mjs
import { createHash } from 'node:crypto';
import { readFile } from 'node:fs/promises';

const hasher = createHash('sha1');

hasher.setEncoding('hex');
// ensure you have a `package.json` file for this test!
hasher.write(await readFile('package.json'));
hasher.end();

const fileHash = hasher.read();

// run with `node crypto.mjs`
