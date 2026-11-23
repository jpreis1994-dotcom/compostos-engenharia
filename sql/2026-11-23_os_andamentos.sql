-- Migração: histórico de ANDAMENTOS das OS (mudanças de status) — 23/11/2026
-- Cada vez que o status de uma OS muda (pela lista ou pela edição), o banco
-- grava quem mudou, quando, e de qual status para qual. O sistema mostra
-- isso no sino do topo e no histórico dentro da OS.
-- Pode rodar mais de uma vez sem problema.
begin;

create table if not exists public.os_andamentos (
  id              bigint generated always as identity primary key,
  os_id           bigint,          -- sem FK: o histórico fica mesmo se a OS for excluída
  numero_os       text,
  cliente_nome    text,
  status_anterior text,
  status_novo     text,
  usuario_id      uuid,
  usuario_nome    text,
  criado_em       timestamptz not null default now()
);
create index if not exists os_andamentos_criado_em_idx on public.os_andamentos (criado_em desc);
create index if not exists os_andamentos_os_id_idx     on public.os_andamentos (os_id);

-- Somente leitura para quem está logado; quem grava é o gatilho abaixo
alter table public.os_andamentos enable row level security;
drop policy if exists "Leitura autenticado" on public.os_andamentos;
create policy "Leitura autenticado" on public.os_andamentos for select to authenticated using (true);

-- Gatilho: registra a mudança de status
create or replace function public.fn_os_andamento()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_nome text;
begin
  if upper(trim(coalesce(new.status,''))) = upper(trim(coalesce(old.status,''))) then
    return new;
  end if;
  select coalesce(nullif(u.raw_user_meta_data->>'nome',''),
                  nullif(u.raw_user_meta_data->>'full_name',''),
                  split_part(u.email,'@',1))
    into v_nome
    from auth.users u
   where u.id = auth.uid();
  insert into public.os_andamentos
    (os_id, numero_os, cliente_nome, status_anterior, status_novo, usuario_id, usuario_nome)
  values
    (new.id, new.numero_os::text, new.cliente_nome, old.status, new.status, auth.uid(), coalesce(v_nome,'Sistema'));
  return new;
end
$$;

drop trigger if exists trg_os_andamento on public.ordens_servico;
create trigger trg_os_andamento
  after update of status on public.ordens_servico
  for each row execute function public.fn_os_andamento();

-- Tempo real: avisa na hora quem estiver com o sistema aberto
do $$
begin
  if not exists (select 1 from pg_publication_tables
                  where pubname='supabase_realtime' and schemaname='public' and tablename='os_andamentos') then
    alter publication supabase_realtime add table public.os_andamentos;
  end if;
end
$$;

commit;
