import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  try {
    const { username, newPassword } = await req.json()

    if (!username || !newPassword) {
      return new Response(
        JSON.stringify({ error: 'Username dan password baru wajib diisi' }),
        { headers: { 'Content-Type': 'application/json' }, status: 400 },
      )
    }

    if (newPassword.length < 6) {
      return new Response(
        JSON.stringify({ error: 'Password minimal 6 karakter' }),
        { headers: { 'Content-Type': 'application/json' }, status: 400 },
      )
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    )

    const { data: profile, error: profileError } = await supabase
      .from('profiles')
      .select('id')
      .eq('username', username)
      .single()

    if (profileError || !profile) {
      return new Response(
        JSON.stringify({ error: 'Username tidak ditemukan' }),
        { headers: { 'Content-Type': 'application/json' }, status: 404 },
      )
    }

    const { error: updateError } = await supabase.auth.admin.updateUserById(
      profile.id,
      { password: newPassword },
    )

    if (updateError) {
      return new Response(
        JSON.stringify({ error: 'Gagal mereset password' }),
        { headers: { 'Content-Type': 'application/json' }, status: 500 },
      )
    }

    await supabase
      .from('profiles')
      .update({ password: newPassword })
      .eq('id', profile.id)

    return new Response(
      JSON.stringify({ success: true }),
      { headers: { 'Content-Type': 'application/json' }, status: 200 },
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message ?? 'Terjadi kesalahan' }),
      { headers: { 'Content-Type': 'application/json' }, status: 500 },
    )
  }
})
