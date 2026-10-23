-- Sign in sessions unused for 30 days end (frontend notes 109 and 112, 2026-10-23): the session row, its refresh tokens and its MFA claims
-- (both cascade) go, and with them the IP address and browser the sign in provider kept for it. A browser that comes back later signs in
-- again. Daily at 03:29 UTC, after the other prune jobs. Supabase's own session limits need the Pro plan; this does the same on any plan.
do $$
begin
  create extension if not exists pg_cron;
  perform cron.schedule('prune-idle-sessions', '29 3 * * *', $job$delete from auth.sessions
      where coalesce(updated_at, created_at) < now() - interval '30 days'
        and coalesce(refreshed_at, '-infinity'::timestamp) < (now() at time zone 'utc') - interval '30 days'$job$);
exception when others then
  raise notice 'idle session job not scheduled: %', sqlerrm;
end $$;
