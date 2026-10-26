-- The guide through the site (frontend components/layout/tour.rs) shows once per profile: the first time a new profile is used on a
-- computer, on whichever device that is, and never again (owner, 2026-10-26; frontend note 130). guide_seen_at is null for a profile that
-- has not had it. Profiles that existed before this migration count as seen; it is set when the column is added, so running this file
-- again does not mark newer profiles. claim_profile_guide sets it once and answers whether this call was the one that set it, so two
-- devices can never both show the guide.
do $$
begin
  if not exists (select 1 from information_schema.columns where table_schema = 'public' and table_name = 'profiles' and column_name = 'guide_seen_at') then
    alter table public.profiles add column guide_seen_at timestamptz;
    update public.profiles set guide_seen_at = created_at;
  end if;
end $$;
comment on column public.profiles.guide_seen_at is 'When the guide through the site was shown to this profile; null until then (claim_profile_guide).';

create or replace function public.claim_profile_guide(p_profile uuid)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_owner uuid;
begin
  select user_id into v_owner from public.profiles where id = p_profile;
  if v_owner is null or v_owner is distinct from (select auth.uid()) then
    raise exception 'not allowed' using errcode = '42501';
  end if;
  update public.profiles set guide_seen_at = now() where id = p_profile and guide_seen_at is null;
  return found;
end $$;
revoke all on function public.claim_profile_guide(uuid) from public, anon;
grant execute on function public.claim_profile_guide(uuid) to authenticated;
