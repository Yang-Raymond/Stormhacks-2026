export type ThemePreference = "light" | "dark" | "system";

/** Runs before paint so the saved/system theme also applies before React hydrates. */
export const themeScript = `(() => {
  const root = document.documentElement;
  const media = window.matchMedia('(prefers-color-scheme: dark)');
  function read() {
    try { return localStorage.getItem('ladybug:theme'); } catch { return null; }
  }
  function apply(value) {
    const preference = value === 'light' || value === 'dark' ? value : 'system';
    root.dataset.themePreference = preference;
    root.dataset.theme = preference === 'system' ? (media.matches ? 'dark' : 'light') : preference;
    root.style.colorScheme = root.dataset.theme;
  }
  apply(read());
  media.addEventListener('change', () => apply(root.dataset.themePreference));
  window.addEventListener('storage', (event) => {
    if (event.key === 'ladybug:theme' || event.key === null) apply(read());
  });
  window.addEventListener('ladybug:theme-change', () => apply(root.dataset.themePreference));
})();`;

export function setTheme(preference: ThemePreference) {
  try { localStorage.setItem("ladybug:theme", preference); } catch { /* Still works without storage. */ }
  document.documentElement.dataset.themePreference = preference;
  window.dispatchEvent(new Event("ladybug:theme-change"));
}
