/* Smart Education — Supabase connection
 * This file contains the browser-safe Supabase Publishable key.
 * NEVER put an sb_secret_ key in this file.
 */
(function () {
  const SUPABASE_URL = "https://adneuympnwijfrudycwu.supabase.co";
  const SUPABASE_PUBLISHABLE_KEY = "sb_publishable_JHaY4uvYMk0UKGdDqItfPw_EYIVib2l";

  if (!window.supabase || typeof window.supabase.createClient !== "function") {
    console.error("Supabase JS library did not load.");
    return;
  }

  window.SUPABASE_URL = SUPABASE_URL;
  window.SUPABASE_PUBLISHABLE_KEY = SUPABASE_PUBLISHABLE_KEY;
  window.supabaseClient = window.supabase.createClient(
    SUPABASE_URL,
    SUPABASE_PUBLISHABLE_KEY
  );
})();
