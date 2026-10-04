import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { runInNewContext } from 'node:vm';
import test from 'node:test';
import ts from 'typescript';

const source = ts.transpileModule(readFileSync(new URL('../lib/theme.ts', import.meta.url), 'utf8'), { compilerOptions: { module: ts.ModuleKind.CommonJS } }).outputText;
function browser({ saved = null, dark = false, storageBlocked = false } = {}) {
  const events = {};
  const mediaEvents = {};
  const root = { dataset: {}, style: {} };
  const media = { matches: dark, addEventListener: (name, fn) => { mediaEvents[name] = fn; } };
  const context = {
    exports: {}, document: { documentElement: root }, Event: class { constructor(type) { this.type = type; } },
    window: { matchMedia: () => media, addEventListener: (name, fn) => { events[name] = fn; }, dispatchEvent: (event) => events[event.type]?.(event) },
    localStorage: {
      getItem: () => { if (storageBlocked) throw Error('Blocked'); return saved; },
      setItem: (_, value) => { if (storageBlocked) throw Error('Blocked'); saved = value; },
    },
  };
  runInNewContext(source, context);
  runInNewContext(context.exports.themeScript, context);
  return {
    root,
    choose: context.exports.setTheme,
    stored: () => saved,
    system: (value) => { media.matches = value; mediaEvents.change(); },
    otherTab: (value) => { saved = value; events.storage({ key: 'ladybug:theme' }); },
  };
}

test('system preference applies before hydration and follows OS changes', () => {
  for (const dark of [false, true]) {
    const page = browser({ dark });
    assert.equal(page.root.dataset.themePreference, 'system');
    assert.equal(page.root.dataset.theme, dark ? 'dark' : 'light');
    page.system(!dark);
    assert.equal(page.root.dataset.theme, dark ? 'light' : 'dark');
    assert.equal(page.root.style.colorScheme, page.root.dataset.theme);
  }
});

test('explicit selection persists, overrides OS changes, and system restores detection', () => {
  const page = browser({ dark: true });
  page.choose('light');
  assert.equal(page.stored(), 'light');
  page.system(true);
  assert.equal(page.root.dataset.theme, 'light');
  assert.equal(browser({ saved: page.stored(), dark: true }).root.dataset.theme, 'light');
  page.choose('dark');
  page.system(false);
  assert.equal(page.root.dataset.theme, 'dark');
  page.choose('system');
  assert.equal(page.root.dataset.theme, 'light');
});

test('storage events synchronize tabs and invalid saved values use system', () => {
  const page = browser({ saved: 'invalid', dark: true });
  assert.equal(page.root.dataset.themePreference, 'system');
  page.otherTab('light');
  assert.equal(page.root.dataset.theme, 'light');
  page.otherTab(null);
  assert.equal(page.root.dataset.theme, 'dark');
});

test('themes remain usable when local storage is blocked', () => {
  const page = browser({ storageBlocked: true });
  page.choose('dark');
  assert.equal(page.root.dataset.theme, 'dark');
  page.choose('system');
  assert.equal(page.root.dataset.theme, 'light');
});
