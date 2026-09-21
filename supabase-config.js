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



  // Cross-device exam result helpers
  async saveExamResult(result) {
    const user = await this.user();
    if (!user) throw new Error("LOGIN_REQUIRED");
    const studentProfile = await this.profile() || {};
    const row = {
      result_id: result.id,
      paper_id: result.paperId && /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(result.paperId) ? result.paperId : null,
      access_code: result.paperPassword || null,
      teacher_user_id: result.teacherUserId || null,
      student_user_id: user.id,
      student_name: result.studentName || studentProfile.name || user.user_metadata?.display_name || 'Student',
      result: result,
      created_at: result.date || new Date().toISOString(),
      updated_at: new Date().toISOString()
    };
    const { data, error } = await window.supabaseClient
      .from('teacher_exam_results').upsert(row, { onConflict: 'result_id' }).select().single();
    if (error) throw error;
    return data;
  },

  async getTeacherResults() {
    const user = await this.user();
    if (!user) return [];
    const { data, error } = await window.supabaseClient
      .from('teacher_exam_results').select('*').eq('teacher_user_id', user.id).order('created_at', {ascending:false});
    if (error) throw error;
    return (data || []).map(row => ({ ...(row.result || {}), id: row.result_id || row.result?.id, studentName: row.student_name || row.result?.studentName || row.result?.student?.name || 'Student', student: { ...(row.result?.student || {}), name: row.student_name || row.result?.student?.name || 'Student', id: row.student_user_id || row.result?.student?.id || '' }, teacherUserId: row.teacher_user_id, paperId: row.paper_id || row.result?.paperId, paperPassword: row.access_code || row.result?.paperPassword }));
  },

  async getStudentResults() {
    const user = await this.user();
    if (!user) return [];
    const { data, error } = await window.supabaseClient
      .from('teacher_exam_results').select('*').eq('student_user_id', user.id).order('updated_at', {ascending:false});
    if (error) throw error;
    return (data || []).map(row => ({ ...(row.result || {}), id: row.result_id || row.result?.id, studentName: row.student_name || row.result?.studentName || row.result?.student?.name || 'Student', student: { ...(row.result?.student || {}), name: row.student_name || row.result?.student?.name || 'Student', id: row.student_user_id || row.result?.student?.id || '' }, teacherUserId: row.teacher_user_id, paperId: row.paper_id || row.result?.paperId, paperPassword: row.access_code || row.result?.paperPassword }));
  },

  async updateExamResult(result) {
    const user = await this.user();
    if (!user) throw new Error("LOGIN_REQUIRED");
    const { data, error } = await window.supabaseClient
      .from('teacher_exam_results')
      .update({ result: result, updated_at: new Date().toISOString(), student_name: result.studentName || result.student?.name || 'Student' })
      .eq('result_id', result.id).eq('teacher_user_id', user.id).select().single();
    if (error) throw error;
    return data;
  },

    async signOut() {
      const { error } = await window.supabaseClient.auth.signOut();
      if (error) throw error;
    }
  };
})();
