-- Edit Profile's gender and the Trailers You've Watched shelf, per profile (frontend note 78, 2026-10-18). Applied to the project on
-- 2026-10-18 through the Supabase tools; this file was added on 2026-10-26 from the project's own migration record, so setup.sql
-- matches the live database.
alter table public.profile_settings
  add column if not exists gender text check (gender is null or gender in ('woman','man','none')),
  add column if not exists trailers_watched jsonb not null default '[]'::jsonb check (jsonb_typeof(trailers_watched) = 'array' and jsonb_array_length(trailers_watched) <= 40);
comment on column public.profile_settings.gender is 'Edit Profile: woman, man or none (prefer not to say).';
comment on column public.profile_settings.trailers_watched is 'Trailers You have Watched: up to 40 entries, newest first, each {id, tv}.';
