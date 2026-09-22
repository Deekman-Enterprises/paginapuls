-- Paginapuls — database schema + beveiliging (Row Level Security)
-- Plak dit in je Supabase-project onder: SQL Editor -> New query -> plak -> Run.
--
-- Wat dit opzet:
--   1. Twee tabellen: sites (klantwebsites) en team_members (bureaumedewerkers).
--   2. Een helper-functie is_agency() die checkt of het ingelogde e-mailadres
--      voorkomt in team_members (= "iemand van het bureau").
--   3. Row Level Security policies:
--        - Bureau (is_agency() = true) mag alles lezen/toevoegen/bewerken/verwijderen.
--        - Een klant mag alleen de eigen site-rij lezen (contact_email = eigen e-mail).
--        - Een teamlid mag altijd de eigen rij in team_members lezen.
--
-- Belangrijk: dit vervangt de neplogin uit de demo. Inloggen zelf (de eenmalige
-- code) verloopt via Supabase Auth (e-mail OTP) — niet via deze tabellen. Deze
-- tabellen bepalen alleen WAT een ingelogd e-mailadres mag zien.

create extension if not exists "pgcrypto";

create table if not exists sites (
  id text primary key,
  name text not null,
  url text not null,
  sector_key text not null default 'algemeen',
  seed_suffix text,
  contact_name text not null,
  contact_email text not null unique,
  created_at timestamptz not null default now()
);

create table if not exists team_members (
  id text primary key,
  name text not null,
  email text not null unique,
  created_at timestamptz not null default now()
);

-- security definer: mag zelf altijd team_members lezen (ongeacht RLS van de
-- aanroeper), zodat de check "zit dit e-mailadres in team_members?" niet
-- vastloopt in zijn eigen RLS-policy (oneindige recursie).
create or replace function is_agency()
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1 from team_members
    where lower(email) = lower(coalesce(auth.jwt() ->> 'email', ''))
  );
$$;

alter table sites enable row level security;
alter table team_members enable row level security;

-- ---------- sites ----------
drop policy if exists "agency full access on sites" on sites;
create policy "agency full access on sites"
  on sites for all
  using (is_agency())
  with check (is_agency());

drop policy if exists "client reads own site" on sites;
create policy "client reads own site"
  on sites for select
  using (lower(contact_email) = lower(coalesce(auth.jwt() ->> 'email', '')));

-- ---------- team_members ----------
drop policy if exists "agency full access on team_members" on team_members;
create policy "agency full access on team_members"
  on team_members for all
  using (is_agency())
  with check (is_agency());

drop policy if exists "member reads own row" on team_members;
create policy "member reads own row"
  on team_members for select
  using (lower(email) = lower(coalesce(auth.jwt() ->> 'email', '')));

-- ---------- startdata: hetzelfde bureau-team en dezelfde 5 demo-klanten als in de demo ----------
insert into team_members (id, name, email) values
  ('thomas-deekman', 'Thomas Deekman', 'thomasdeekman@gmail.com'),
  ('lisa-bakker', 'Lisa Bakker', 'lisa@paginapuls.nl'),
  ('youssef-el-amrani', 'Youssef El Amrani', 'youssef@paginapuls.nl')
on conflict (id) do nothing;

insert into sites (id, name, url, sector_key, contact_name, contact_email) values
  ('bakkerij-van-doorn', 'Bakkerij Van Doorn', 'bakkerijvandoorn.nl', 'bakkerij', 'Renée van Doorn', 'renee@bakkerijvandoorn.nl'),
  ('fysiopunt-utrecht', 'FysioPunt Utrecht', 'fysiopuntutrecht.nl', 'fysio', 'Bas Hendriks', 'bas@fysiopuntutrecht.nl'),
  ('groengroei-tuinservice', 'GroenGroei Tuinservice', 'groengroei.nl', 'hovenier', 'Mark Groen', 'mark@groengroei.nl'),
  ('advocatenkantoor-de-ridder', 'Advocatenkantoor De Ridder', 'deridderadvocaten.nl', 'advocaat', 'Sanne de Ridder', 'sanne@deridderadvocaten.nl'),
  ('sportshop-actief', 'SportShop Actief', 'sportshopactief.nl', 'webshop', 'Kevin Aarts', 'kevin@sportshopactief.nl')
on conflict (id) do nothing;

-- Let op: pas 'thomasdeekman@gmail.com' hierboven eventueel aan naar het
-- e-mailadres waarmee jij zelf wilt inloggen als bureau, vóórdat je dit script
-- draait (of update de rij later gewoon in Table editor).

-- ---------- live sync tussen meerdere ingelogde teamleden (optioneel maar aan te raden) ----------
-- Zonder dit werkt alles gewoon, maar zie je een wijziging van een collega pas na een refresh.
alter publication supabase_realtime add table sites;
alter publication supabase_realtime add table team_members;

