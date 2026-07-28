-- Schema do Mapeamento da Rede
-- Cole isso no SQL Editor do Supabase (projeto novo) e rode.

-- pgcrypto vem por padrão no Supabase, deixo o create por garantia
create extension if not exists "pgcrypto";

-- ------------------------------------------------------------------
-- Tabela fichas
-- ------------------------------------------------------------------
create table if not exists public.fichas (
  id             bigserial primary key,
  user_id        uuid not null default auth.uid() references auth.users(id) on delete cascade,
  data_criacao   date not null default current_date,
  responsavel    text,
  nome           text not null,
  telefone       text,
  municipio      text not null,
  bairro         text,
  profissao      text,
  grau           text,        -- A / B / C
  indicou        text,        -- nome de quem indicou
  tipo_indicou   text,        -- Assessor / Liderança / Apoiador
  relacao        text,
  setor          text[] not null default '{}',
  influencia     text,
  apresenta      text,
  quantidade     text,
  reuniao        text,
  nivel          smallint,    -- 1..5
  obs            text,
  criado_em      timestamptz not null default now(),
  atualizado_em  timestamptz not null default now()
);

-- ------------------------------------------------------------------
-- Trigger de atualizado_em
-- ------------------------------------------------------------------
create or replace function public.tg_atualizado_em()
returns trigger language plpgsql as $$
begin
  new.atualizado_em = now();
  return new;
end;
$$;

drop trigger if exists tr_fichas_atualizado on public.fichas;
create trigger tr_fichas_atualizado
before update on public.fichas
for each row execute function public.tg_atualizado_em();

-- ------------------------------------------------------------------
-- Índice para pull mais recente primeiro
-- ------------------------------------------------------------------
create index if not exists fichas_user_atualizado_idx
  on public.fichas(user_id, atualizado_em desc);

-- ------------------------------------------------------------------
-- Row Level Security — cada user só vê o próprio dado
-- ------------------------------------------------------------------
alter table public.fichas enable row level security;

drop policy if exists "fichas: select own" on public.fichas;
drop policy if exists "fichas: insert own" on public.fichas;
drop policy if exists "fichas: update own" on public.fichas;
drop policy if exists "fichas: delete own" on public.fichas;

create policy "fichas: select own" on public.fichas
  for select using (auth.uid() = user_id);

create policy "fichas: insert own" on public.fichas
  for insert with check (auth.uid() = user_id);

create policy "fichas: update own" on public.fichas
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "fichas: delete own" on public.fichas
  for delete using (auth.uid() = user_id);

-- ------------------------------------------------------------------
-- Verificação rápida — depois de rodar, valide com:
-- select * from pg_policies where tablename = 'fichas';
-- select column_name, data_type from information_schema.columns
--   where table_schema='public' and table_name='fichas' order by ordinal_position;
-- ------------------------------------------------------------------
