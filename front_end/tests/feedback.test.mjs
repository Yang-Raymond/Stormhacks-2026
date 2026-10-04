import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { runInNewContext } from 'node:vm';
import test from 'node:test';
import ts from 'typescript';

test('short passwords explain the registration minimum regardless of character mix', () => {
  const source = ts.transpileModule(readFileSync(new URL('../components/auth/PasswordStrength.tsx', import.meta.url), 'utf8'), {
    compilerOptions: { module: ts.ModuleKind.CommonJS, jsx: ts.JsxEmit.React },
  }).outputText;
  const context = { exports: {} };
  runInNewContext(source, context);
  for (const password of ['1!', 'abc123!', 'abcdefg']) {
    const result = context.exports.calculatePasswordStrength(password);
    assert.equal(result.score, 1);
    assert.match(result.label, /at least 8 characters/);
  }
  assert.equal(context.exports.calculatePasswordStrength('longpassword1!').label, 'Strong');
});

test('dark accent text meets normal text contrast on app surfaces', () => {
  const css = readFileSync(new URL('../app/globals.css', import.meta.url), 'utf8');
  const color = name => css.match(new RegExp(`--color-${name}: #([0-9a-f]{6})`))[1];
  const luminance = hex => hex.match(/../g).map(x => parseInt(x, 16) / 255)
    .map(x => x <= 0.04045 ? x / 12.92 : ((x + 0.055) / 1.055) ** 2.4)
    .reduce((sum, x, i) => sum + x * [0.2126, 0.7152, 0.0722][i], 0);
  for (const background of ['surface', 'surface-2', 'canvas', 'canvas-2']) {
    assert.ok((luminance(color('accent-ink')) + 0.05) / (luminance(color(background)) + 0.05) >= 4.5);
  }
});
