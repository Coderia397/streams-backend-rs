-- Five profiles per account, Kids profiles included (owner, 2026-10-27; frontend note 136). The automatic Kids profile counted for
-- nothing before (migration 20261011150000), so an account could hold five profiles plus Kids. Accounts already over five keep their
-- profiles; they cannot add one until they are under five. Running this file again changes nothing.
create or replace function public.enforce_profile_limit() returns trigger
language plpgsql set search_path = public as $$
begin
  -- two parallel inserts for one account must not both pass the count
  perform pg_advisory_xact_lock(hashtextextended(new.user_id::text, 0));
  if (select count(*) from public.profiles where user_id = new.user_id) >= 5 then
    raise exception 'profile limit reached' using errcode = 'P0001';
  end if;
  return new;
end $$;

revoke all on function public.enforce_profile_limit() from public, anon, authenticated;
