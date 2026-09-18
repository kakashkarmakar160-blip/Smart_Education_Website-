/* Smart Education — Supabase browser connection
 * Browser-safe Publishable key only.
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

  window.smartEduAuth = {
    async user() {
      const { data, error } = await window.supabaseClient.auth.getUser();
      if (error) return null;
      return data?.user || null;
    },

    async profile() {
      const user = await this.user();
      if (!user) return null;
      const { data, error } = await window.supabaseClient
        .from("profiles")
        .select("*")
        .eq("id", user.id)
        .maybeSingle();
      if (error) {
        console.error("Profile load failed:", error);
        return null;
      }
      return data || null;
    },

    async saveProfile(profile) {
      const user = await this.user();
      if (!user) throw new Error("LOGIN_REQUIRED");
      const payload = {
        id: user.id,
        name: profile.name || null,
        phone: profile.phone || null,
        role: profile.role || null,
        class_name: profile.className || null,
        semester: profile.semester || null,
        avatar_url: profile.avatarUrl || null,
        updated_at: new Date().toISOString()
      };
      const { data, error } = await window.supabaseClient
        .from("profiles")
        .upsert(payload, { onConflict: "id" })
        .select()
        .single();
      if (error) throw error;
      return data;
    },

    async signOut() {
      const { error } = await window.supabaseClient.auth.signOut();
      if (error) throw error;
    }
  };
})();
