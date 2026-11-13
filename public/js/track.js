// EverythingSings analytics tracker. No cookies, no storage, no fingerprinting.
// Sends: a page view, a named click on links marked data-track, and time on page when leaving.
(() => {
  const ENDPOINT = "https://everythingsings-analytics.everythingsings.workers.dev/e"; // set once the Worker address exists
  // Respect Do Not Track / Global Privacy Control, and skip automated browsers.
  if (navigator.doNotTrack === "1" || window.doNotTrack === "1" || navigator.globalPrivacyControl || navigator.webdriver) return;

  const path = location.pathname;
  const start = Date.now();
  const send = (data) => { try { navigator.sendBeacon(ENDPOINT, JSON.stringify(data)); } catch (_) {} };

  send({ t: "pv", p: path, r: document.referrer });

  document.addEventListener("click", (e) => {
    const a = e.target && e.target.closest ? e.target.closest("a[data-track]") : null;
    if (a) send({ t: "click", p: path, l: a.dataset.track });
  }, true);

  let left = false;
  const leave = () => {
    if (left) return;
    left = true;
    send({ t: "leave", p: path, d: Math.round((Date.now() - start) / 1000) });
  };
  addEventListener("pagehide", leave);
  document.addEventListener("visibilitychange", () => { if (document.visibilityState === "hidden") leave(); });
})();
