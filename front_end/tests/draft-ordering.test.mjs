import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { runInNewContext } from 'node:vm';
import test from 'node:test';
import ts from 'typescript';

const source = ts.transpileModule(readFileSync(new URL('../lib/api.ts', import.meta.url), 'utf8'), {
  compilerOptions: { module: ts.ModuleKind.CommonJS },
}).outputText;

function client() {
  const requests = [];
  const context = { exports: {}, fetch: (url, options) => new Promise((resolve, reject) => {
    requests.push({ url, options, finish: () => resolve({ status: 204 }), reject });
  }) };
  runInNewContext(source, context);
  return { api: context.exports.api, requests };
}
const tick = () => new Promise(resolve => setImmediate(resolve));

test('autosave, navigation flush, reset, Run and reload retain call order', async () => {
  const { api, requests } = client();
  const calls = [
    api('/problems/p/draft', { method: 'PUT', body: { code: 'old' } }),
    api('/problems/p/draft', { method: 'PUT', body: { code: 'new' }, keepalive: true }),
    api('/problems/p/draft', { method: 'DELETE' }),
    api('/problems/p/run', { body: { code: 'run' } }),
    api('/problems/p'),
  ];
  for (let i = 0; i < calls.length; i++) {
    assert.equal(requests.length, i + 1);
    requests[i].finish();
    await calls[i];
    await tick();
  }
  assert.equal(requests[1].options.keepalive, true);
  assert.equal(requests[2].options.method, 'DELETE');
  assert.equal(requests[3].url, '/api/problems/p/run');
});

test('a failed request does not block newer writes or unrelated problems', async () => {
  const { api, requests } = client();
  const first = api('/problems/p/draft', { body: { code: 'old' } });
  const rejected = assert.rejects(first);
  const second = api('/problems/p/draft', { body: { code: 'new' } });
  const other = api('/problems/q/draft', { body: { code: 'other' } });
  assert.equal(requests.length, 2);
  requests[0].reject(new Error('network'));
  requests[1].finish();
  await rejected;
  await tick();
  assert.equal(requests.length, 3);
  requests[2].finish();
  await Promise.all([second, other]);
});
