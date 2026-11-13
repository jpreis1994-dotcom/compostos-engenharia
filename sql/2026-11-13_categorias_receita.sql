-- Migração: categorias e subcategorias de receita (Compostos) — gerado em 13/11/2026
-- Tudo numa transação: se qualquer comando falhar, nada é gravado.
begin;

-- 1) Cópias de segurança (reverter = copiar de volta destas tabelas)
create table if not exists bkp_20261113_fluxo_caixa as select * from public.fluxo_caixa;
create table if not exists bkp_20261113_ordens_servico as select * from public.ordens_servico;
create table if not exists bkp_20261113_contas_receber as select * from public.contas_receber;
alter table public.bkp_20261113_fluxo_caixa enable row level security;
alter table public.bkp_20261113_ordens_servico enable row level security;
alter table public.bkp_20261113_contas_receber enable row level security;

-- 2) Estrutura nova
alter table public.fluxo_caixa add column if not exists subcategoria text;
create table if not exists public.receita_categorias (
  id bigint generated always as identity primary key,
  categoria text not null,
  subcategoria text,
  servico boolean not null default true,
  ativo boolean not null default true,
  ordem integer not null default 0,
  created_at timestamptz not null default now()
);
alter table public.receita_categorias enable row level security;
drop policy if exists "Permitir tudo autenticado" on public.receita_categorias;
create policy "Permitir tudo autenticado" on public.receita_categorias for all to authenticated using (true) with check (true);
insert into public.receita_categorias (categoria, subcategoria, servico, ordem) select * from (values
  ('OBRA', 'Obra de posto novo', true, 10),
  ('OBRA', 'Obra de reforma / instalação', true, 20),
  ('OBRA', 'Outras obras', true, 30),
  ('INSTALAÇÃO', 'Bomba', true, 40),
  ('INSTALAÇÃO', 'Filtro', true, 50),
  ('INSTALAÇÃO', 'Tanque', true, 60),
  ('INSTALAÇÃO', 'Aparelho de medição', true, 70),
  ('LAUDO', 'NR 11 – Movimentação e armazenagem', true, 80),
  ('LAUDO', 'NR 12 – Máquinas e equipamentos', true, 90),
  ('LAUDO', 'NR 13 – Caldeiras, vasos de pressão e compressores', true, 100),
  ('LAUDO', 'NR 35 – Trabalho em altura (linha de vida)', true, 110),
  ('LAUDO', 'Tanque aéreo', true, 120),
  ('LAUDO', 'Integridade de tanque', true, 130),
  ('LAUDO', 'VOC / passivo ambiental', true, 140),
  ('LAUDO', 'Hidrogeológico', true, 150),
  ('LAUDO', 'Atestado de classe / conformidade', true, 160),
  ('LAUDO', 'Arqueação de tanque', true, 170),
  ('LAUDO', 'Acústico', true, 180),
  ('LAUDO', 'Perícia', true, 190),
  ('LAUDO', 'Outros laudos', true, 200),
  ('TESTE DE ESTANQUEIDADE', 'Posto de combustível', true, 210),
  ('TESTE DE ESTANQUEIDADE', 'Outras empresas / rede de gás', true, 220),
  ('MANUTENÇÃO', 'Manutenção de equipamento', true, 230),
  ('MANUTENÇÃO', 'Manutenção aparelho de medição', true, 240),
  ('LIMPEZA DE TANQUE', NULL, true, 250),
  ('VENDA DE PEÇAS', 'Peças soldáveis', true, 260),
  ('VENDA DE PEÇAS', 'Tanques', true, 270),
  ('VENDA DE PEÇAS', 'Outras peças e materiais', true, 280),
  ('PROJETO', 'Cobertura metálica', true, 290),
  ('PROJETO', 'Posto de combustível', true, 300),
  ('COMISSÃO', NULL, false, 310),
  ('RESPONSABILIDADE TÉCNICA', 'Mensal', true, 320),
  ('RESPONSABILIDADE TÉCNICA', 'Avulsa', true, 330),
  ('REEMBOLSO DE ART', NULL, true, 340),
  ('RECEITA FINANCEIRA', 'Juros e multas recebidos', false, 350)
) v(c,s,sv,o) where not exists (select 1 from public.receita_categorias);

-- 3) Receitas do fluxo: nova categoria/subcategoria (só se o lançamento ainda estiver como no backup)
insert into public.fluxo_caixa (tipo, categoria, subcategoria, descricao, valor, data_movimento, cliente, origem, mes, ano, observacao, os_id, conta_receber_id, conta_pagar_id, cnpj, fornecedor, forma_conta, classificacao)
  select tipo, 'VENDA DE PEÇAS', 'Outras peças e materiais', descricao, 4400.0, data_movimento, cliente, origem, mes, ano,
         trim(both ' —' from coalesce(observacao,'') || ' — Dividido na migração de categorias (13/11)'), 201, conta_receber_id, conta_pagar_id, cnpj, fornecedor, forma_conta, classificacao
  from public.fluxo_caixa where id=492 and tipo='RECEITA' and valor=5400.0;
insert into public.fluxo_caixa (tipo, categoria, subcategoria, descricao, valor, data_movimento, cliente, origem, mes, ano, observacao, os_id, conta_receber_id, conta_pagar_id, cnpj, fornecedor, forma_conta, classificacao)
  select tipo, 'VENDA DE PEÇAS', 'Outras peças e materiais', descricao, 6000.0, data_movimento, cliente, origem, mes, ano,
         trim(both ' —' from coalesce(observacao,'') || ' — Dividido na migração de categorias (13/11)'), 200, conta_receber_id, conta_pagar_id, cnpj, fornecedor, forma_conta, classificacao
  from public.fluxo_caixa where id=539 and tipo='RECEITA' and valor=7000.0;
insert into public.fluxo_caixa (tipo, categoria, subcategoria, descricao, valor, data_movimento, cliente, origem, mes, ano, observacao, os_id, conta_receber_id, conta_pagar_id, cnpj, fornecedor, forma_conta, classificacao)
  select tipo, 'OBRA', 'Obra de reforma / instalação', descricao, 800.0, data_movimento, cliente, origem, mes, ano,
         trim(both ' —' from coalesce(observacao,'') || ' — Dividido na migração de categorias (13/11)'), os_id, conta_receber_id, conta_pagar_id, cnpj, fornecedor, forma_conta, classificacao
  from public.fluxo_caixa where id=974 and tipo='RECEITA' and valor=2000.0;
insert into public.fluxo_caixa (tipo, categoria, subcategoria, descricao, valor, data_movimento, cliente, origem, mes, ano, observacao, os_id, conta_receber_id, conta_pagar_id, cnpj, fornecedor, forma_conta, classificacao)
  select tipo, 'VENDA DE PEÇAS', 'Outras peças e materiais', descricao, 920.0, data_movimento, cliente, origem, mes, ano,
         trim(both ' —' from coalesce(observacao,'') || ' — Dividido na migração de categorias (13/11)'), os_id, conta_receber_id, conta_pagar_id, cnpj, fornecedor, forma_conta, classificacao
  from public.fluxo_caixa where id=1005 and tipo='RECEITA' and valor=1220.0;
insert into public.fluxo_caixa (tipo, categoria, subcategoria, descricao, valor, data_movimento, cliente, origem, mes, ano, observacao, os_id, conta_receber_id, conta_pagar_id, cnpj, fornecedor, forma_conta, classificacao)
  select tipo, 'VENDA DE PEÇAS', 'Outras peças e materiais', descricao, 300.0, data_movimento, cliente, origem, mes, ano,
         trim(both ' —' from coalesce(observacao,'') || ' — Dividido na migração de categorias (13/11)'), os_id, conta_receber_id, conta_pagar_id, cnpj, fornecedor, forma_conta, classificacao
  from public.fluxo_caixa where id=1129 and tipo='RECEITA' and valor=600.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=84 and tipo='RECEITA' and valor=296.8;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='Atestado de classe / conformidade' where id=89 and tipo='RECEITA' and valor=2000.0;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Posto de combustível' where id=90 and tipo='RECEITA' and valor=1000.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='Integridade de tanque' where id=91 and tipo='RECEITA' and valor=1113.03;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Posto de combustível' where id=93 and tipo='RECEITA' and valor=800.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='Integridade de tanque' where id=94 and tipo='RECEITA' and valor=1113.03;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Posto de combustível' where id=95 and tipo='RECEITA' and valor=1000.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='Integridade de tanque' where id=96 and tipo='RECEITA' and valor=1113.03;
update public.fluxo_caixa set categoria='VENDA DE PEÇAS', subcategoria='Outras peças e materiais' where id=101 and tipo='RECEITA' and valor=4060.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=103 and tipo='RECEITA' and valor=358.33;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Outras empresas / rede de gás' where id=105 and tipo='RECEITA' and valor=500.0;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Outras obras' where id=108 and tipo='RECEITA' and valor=3282.0;
update public.fluxo_caixa set categoria='RESPONSABILIDADE TÉCNICA', subcategoria='Avulsa' where id=109 and tipo='RECEITA' and valor=2100.0;
update public.fluxo_caixa set categoria='LIMPEZA DE TANQUE', subcategoria=NULL where id=111 and tipo='RECEITA' and valor=2300.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=113 and tipo='RECEITA' and valor=1232.0;
update public.fluxo_caixa set categoria='VENDA DE PEÇAS', subcategoria='Outras peças e materiais' where id=114 and tipo='RECEITA' and valor=7310.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=115 and tipo='RECEITA' and valor=1568.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='Tanque aéreo' where id=121 and tipo='RECEITA' and valor=12250.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 35 – Trabalho em altura (linha de vida)' where id=127 and tipo='RECEITA' and valor=1503.03;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de reforma / instalação' where id=135 and tipo='RECEITA' and valor=10000.0;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de reforma / instalação' where id=136 and tipo='RECEITA' and valor=1190.0;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Posto de combustível' where id=138 and tipo='RECEITA' and valor=1000.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=140 and tipo='RECEITA' and valor=296.8;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Posto de combustível' where id=147 and tipo='RECEITA' and valor=840.0;
update public.fluxo_caixa set categoria='MANUTENÇÃO', subcategoria='Manutenção de equipamento' where id=148 and tipo='RECEITA' and valor=270.0;
update public.fluxo_caixa set categoria='LIMPEZA DE TANQUE', subcategoria=NULL where id=149 and tipo='RECEITA' and valor=3200.0;
update public.fluxo_caixa set categoria='RESPONSABILIDADE TÉCNICA', subcategoria='Avulsa' where id=151 and tipo='RECEITA' and valor=4300.0;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de reforma / instalação' where id=154 and tipo='RECEITA' and valor=5000.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=155 and tipo='RECEITA' and valor=358.33;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de reforma / instalação' where id=157 and tipo='RECEITA' and valor=7000.0;
update public.fluxo_caixa set categoria='VENDA DE PEÇAS', subcategoria='Outras peças e materiais' where id=160 and tipo='RECEITA' and valor=1000.0;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de reforma / instalação' where id=166 and tipo='RECEITA' and valor=3500.0;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Outras obras' where id=170 and tipo='RECEITA' and valor=34700.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=175 and tipo='RECEITA' and valor=1232.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=176 and tipo='RECEITA' and valor=1568.0;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Posto de combustível' where id=177 and tipo='RECEITA' and valor=700.0;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Outras obras' where id=178 and tipo='RECEITA' and valor=4730.0;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de reforma / instalação' where id=182 and tipo='RECEITA' and valor=4300.0;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Posto de combustível' where id=183 and tipo='RECEITA' and valor=15750.0;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Outras obras' where id=184 and tipo='RECEITA' and valor=5950.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='Tanque aéreo' where id=187 and tipo='RECEITA' and valor=1500.0;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Posto de combustível' where id=190 and tipo='RECEITA' and valor=1840.0;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de reforma / instalação' where id=192 and tipo='RECEITA' and valor=5000.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 13 – Caldeiras, vasos de pressão e compressores' where id=195 and tipo='RECEITA' and valor=600.0;
update public.fluxo_caixa set categoria='RESPONSABILIDADE TÉCNICA', subcategoria='Mensal' where id=201 and tipo='RECEITA' and valor=1000.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=204 and tipo='RECEITA' and valor=358.33;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de reforma / instalação' where id=205 and tipo='RECEITA' and valor=5000.0;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de reforma / instalação' where id=210 and tipo='RECEITA' and valor=5000.0;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de reforma / instalação' where id=214 and tipo='RECEITA' and valor=4300.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=215 and tipo='RECEITA' and valor=1232.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 13 – Caldeiras, vasos de pressão e compressores' where id=217 and tipo='RECEITA' and valor=600.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=218 and tipo='RECEITA' and valor=1568.0;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de reforma / instalação' where id=219 and tipo='RECEITA' and valor=30000.0;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de posto novo' where id=221 and tipo='RECEITA' and valor=78000.0;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de reforma / instalação' where id=224 and tipo='RECEITA' and valor=5000.0;
update public.fluxo_caixa set categoria='LIMPEZA DE TANQUE', subcategoria=NULL where id=226 and tipo='RECEITA' and valor=1400.0;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de reforma / instalação' where id=228 and tipo='RECEITA' and valor=10000.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='Tanque aéreo' where id=240 and tipo='RECEITA' and valor=1200.0;
update public.fluxo_caixa set categoria='RESPONSABILIDADE TÉCNICA', subcategoria='Mensal' where id=241 and tipo='RECEITA' and valor=1000.0;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de reforma / instalação' where id=243 and tipo='RECEITA' and valor=8000.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=245 and tipo='RECEITA' and valor=358.33;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='Tanque aéreo' where id=247 and tipo='RECEITA' and valor=5500.0;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de reforma / instalação' where id=252 and tipo='RECEITA' and valor=1310.0;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de reforma / instalação' where id=253 and tipo='RECEITA' and valor=2400.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=257 and tipo='RECEITA' and valor=1568.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=258 and tipo='RECEITA' and valor=1232.0;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de reforma / instalação' where id=262 and tipo='RECEITA' and valor=4300.0;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de posto novo' where id=269 and tipo='RECEITA' and valor=20000.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=273 and tipo='RECEITA' and valor=800.0;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Posto de combustível' where id=274 and tipo='RECEITA' and valor=1000.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='Tanque aéreo' where id=275 and tipo='RECEITA' and valor=1350.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 13 – Caldeiras, vasos de pressão e compressores' where id=279 and tipo='RECEITA' and valor=2915.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='Integridade de tanque' where id=284 and tipo='RECEITA' and valor=1000.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='Tanque aéreo' where id=289 and tipo='RECEITA' and valor=2000.0;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Posto de combustível' where id=292 and tipo='RECEITA' and valor=1500.0;
update public.fluxo_caixa set categoria='RESPONSABILIDADE TÉCNICA', subcategoria='Mensal' where id=294 and tipo='RECEITA' and valor=1000.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=298 and tipo='RECEITA' and valor=358.33;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='Tanque aéreo' where id=300 and tipo='RECEITA' and valor=1608.39;
update public.fluxo_caixa set categoria='VENDA DE PEÇAS', subcategoria='Tanques' where id=303 and tipo='RECEITA' and valor=10000.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=311 and tipo='RECEITA' and valor=1232.0;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de reforma / instalação' where id=313 and tipo='RECEITA' and valor=4300.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=323 and tipo='RECEITA' and valor=1568.0;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Posto de combustível' where id=330 and tipo='RECEITA' and valor=1308.39;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de posto novo' where id=331 and tipo='RECEITA' and valor=39000.0;
update public.fluxo_caixa set tipo='DESPESA', categoria='TARIFAS BANCÁRIAS', subcategoria=NULL, tipo_despesa=NULL, tipo_servico=NULL where id=333 and tipo='RECEITA' and valor=3.5;
update public.fluxo_caixa set categoria='RESPONSABILIDADE TÉCNICA', subcategoria='Mensal' where id=355 and tipo='RECEITA' and valor=1000.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='Integridade de tanque' where id=362 and tipo='RECEITA' and valor=2308.39;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='Integridade de tanque' where id=363 and tipo='RECEITA' and valor=2108.39;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='Integridade de tanque' where id=364 and tipo='RECEITA' and valor=1908.39;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=367 and tipo='RECEITA' and valor=1208.39;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='Outros laudos' where id=370 and tipo='RECEITA' and valor=1600.0;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Posto de combustível' where id=371 and tipo='RECEITA' and valor=1000.0;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Posto de combustível' where id=372 and tipo='RECEITA' and valor=2208.39;
update public.fluxo_caixa set categoria='APORTE (PRÓPRIO)', subcategoria=NULL where id=375 and tipo='RECEITA' and valor=2000.0;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de reforma / instalação' where id=380 and tipo='RECEITA' and valor=1938.4;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de reforma / instalação' where id=383 and tipo='RECEITA' and valor=8500.0;
update public.fluxo_caixa set categoria='LIMPEZA DE TANQUE', subcategoria=NULL where id=405 and tipo='RECEITA' and valor=7000.0;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de posto novo' where id=406 and tipo='RECEITA' and valor=39000.0;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de posto novo' where id=407 and tipo='RECEITA' and valor=39000.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=418 and tipo='RECEITA' and valor=296.8;
update public.fluxo_caixa set categoria='LIMPEZA DE TANQUE', subcategoria=NULL where id=422 and tipo='RECEITA' and valor=1300.0;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de reforma / instalação' where id=429 and tipo='RECEITA' and valor=4300.0;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de reforma / instalação' where id=436 and tipo='RECEITA' and valor=3500.0;
update public.fluxo_caixa set categoria='APORTE (PRÓPRIO)', subcategoria=NULL where id=437 and tipo='RECEITA' and valor=200.0;
update public.fluxo_caixa set categoria='APORTE (PRÓPRIO)', subcategoria=NULL where id=439 and tipo='RECEITA' and valor=2600.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=448 and tipo='RECEITA' and valor=1232.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=449 and tipo='RECEITA' and valor=1568.0;
update public.fluxo_caixa set categoria='APORTE (PRÓPRIO)', subcategoria=NULL where id=464 and tipo='RECEITA' and valor=200.0;
update public.fluxo_caixa set categoria='VENDA DE PEÇAS', subcategoria='Tanques' where id=474 and tipo='RECEITA' and valor=15000.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=476 and tipo='RECEITA' and valor=358.33;
update public.fluxo_caixa set categoria='APORTE (PRÓPRIO)', subcategoria=NULL where id=480 and tipo='RECEITA' and valor=2000.0;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de reforma / instalação', os_id=202 where id=489 and tipo='RECEITA' and valor=7000.0;
update public.fluxo_caixa set categoria='MANUTENÇÃO', subcategoria='Manutenção de equipamento', os_id=201, valor=1000.0, observacao=trim(both ' —' from coalesce(observacao,'') || ' — Dividido na migração de categorias (13/11)') where id=492 and tipo='RECEITA' and valor=5400.0;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Posto de combustível' where id=498 and tipo='RECEITA' and valor=1700.0;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Posto de combustível', os_id=216 where id=514 and tipo='RECEITA' and valor=1300.0;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de reforma / instalação' where id=516 and tipo='RECEITA' and valor=4150.0;
update public.fluxo_caixa set categoria='APORTE (PRÓPRIO)', subcategoria=NULL where id=517 and tipo='RECEITA' and valor=200.0;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Posto de combustível', os_id=163 where id=528 and tipo='RECEITA' and valor=2000.0;
update public.fluxo_caixa set categoria='INSTALAÇÃO', subcategoria='Tanque', os_id=200, valor=1000.0, observacao=trim(both ' —' from coalesce(observacao,'') || ' — Dividido na migração de categorias (13/11)') where id=539 and tipo='RECEITA' and valor=7000.0;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Posto de combustível' where id=540 and tipo='RECEITA' and valor=1254.19;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=541 and tipo='RECEITA' and valor=1115.06;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Posto de combustível', os_id=195 where id=542 and tipo='RECEITA' and valor=1433.39;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Posto de combustível', os_id=187 where id=543 and tipo='RECEITA' and valor=1168.39;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Posto de combustível', os_id=188 where id=544 and tipo='RECEITA' and valor=1168.39;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Posto de combustível', os_id=189 where id=545 and tipo='RECEITA' and valor=1433.39;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Posto de combustível', os_id=193 where id=546 and tipo='RECEITA' and valor=1168.39;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Posto de combustível', os_id=194 where id=547 and tipo='RECEITA' and valor=1168.39;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Posto de combustível', os_id=218 where id=548 and tipo='RECEITA' and valor=600.0;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Posto de combustível', os_id=190 where id=549 and tipo='RECEITA' and valor=1698.39;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Posto de combustível', os_id=191 where id=550 and tipo='RECEITA' and valor=1433.39;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Posto de combustível' where id=551 and tipo='RECEITA' and valor=1433.39;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Posto de combustível', os_id=196 where id=552 and tipo='RECEITA' and valor=1608.39;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Posto de combustível', os_id=213 where id=553 and tipo='RECEITA' and valor=400.0;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de reforma / instalação', os_id=213 where id=554 and tipo='RECEITA' and valor=1000.0;
update public.fluxo_caixa set categoria='VENDA DE PEÇAS', subcategoria='Peças soldáveis', os_id=213 where id=555 and tipo='RECEITA' and valor=508.0;
update public.fluxo_caixa set categoria='LIMPEZA DE TANQUE', subcategoria=NULL, os_id=205 where id=556 and tipo='RECEITA' and valor=4000.0;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Posto de combustível', os_id=205 where id=557 and tipo='RECEITA' and valor=1200.0;
update public.fluxo_caixa set categoria='REEMBOLSO DE ART', subcategoria=NULL, os_id=205 where id=558 and tipo='RECEITA' and valor=108.39;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 13 – Caldeiras, vasos de pressão e compressores' where id=559 and tipo='RECEITA' and valor=600.0;
update public.fluxo_caixa set categoria='REEMBOLSO DE ART', subcategoria=NULL where id=560 and tipo='RECEITA' and valor=108.39;
update public.fluxo_caixa set categoria='COMISSÃO', subcategoria=NULL where id=561 and tipo='RECEITA' and valor=480.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=562 and tipo='RECEITA' and valor=1000.0;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Posto de combustível' where id=563 and tipo='RECEITA' and valor=1000.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='Integridade de tanque' where id=564 and tipo='RECEITA' and valor=1000.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=570 and tipo='RECEITA' and valor=1250.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='Tanque aéreo' where id=573 and tipo='RECEITA' and valor=1000.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 13 – Caldeiras, vasos de pressão e compressores' where id=574 and tipo='RECEITA' and valor=1000.0;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Posto de combustível' where id=575 and tipo='RECEITA' and valor=1500.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=576 and tipo='RECEITA' and valor=1000.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='Tanque aéreo' where id=577 and tipo='RECEITA' and valor=1500.0;
update public.fluxo_caixa set categoria='RESPONSABILIDADE TÉCNICA', subcategoria='Mensal' where id=578 and tipo='RECEITA' and valor=1000.0;
update public.fluxo_caixa set categoria='RECEITA FINANCEIRA', subcategoria='Juros e multas recebidos' where id=579 and tipo='RECEITA' and valor=106.66;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 12 – Máquinas e equipamentos' where id=580 and tipo='RECEITA' and valor=1500.0;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de posto novo' where id=581 and tipo='RECEITA' and valor=13644.0;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de posto novo' where id=582 and tipo='RECEITA' and valor=13944.0;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Posto de combustível' where id=583 and tipo='RECEITA' and valor=1800.0;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Posto de combustível' where id=584 and tipo='RECEITA' and valor=2000.0;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Outras empresas / rede de gás' where id=585 and tipo='RECEITA' and valor=1608.39;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Posto de combustível' where id=586 and tipo='RECEITA' and valor=1808.4;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=587 and tipo='RECEITA' and valor=1000.0;
update public.fluxo_caixa set categoria='RECEITA FINANCEIRA', subcategoria='Juros e multas recebidos' where id=588 and tipo='RECEITA' and valor=106.66;
update public.fluxo_caixa set categoria='LIMPEZA DE TANQUE', subcategoria=NULL where id=589 and tipo='RECEITA' and valor=2800.0;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de reforma / instalação' where id=590 and tipo='RECEITA' and valor=2490.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='VOC / passivo ambiental' where id=591 and tipo='RECEITA' and valor=6500.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem', os_id=140 where id=592 and tipo='RECEITA' and valor=1400.0;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Posto de combustível' where id=594 and tipo='RECEITA' and valor=1400.0;
update public.fluxo_caixa set categoria='REEMBOLSO DE ART', subcategoria=NULL where id=595 and tipo='RECEITA' and valor=108.39;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Outras empresas / rede de gás' where id=597 and tipo='RECEITA' and valor=1600.0;
update public.fluxo_caixa set categoria='REEMBOLSO DE ART', subcategoria=NULL where id=598 and tipo='RECEITA' and valor=108.39;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de reforma / instalação' where id=602 and tipo='RECEITA' and valor=5000.0;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Posto de combustível' where id=604 and tipo='RECEITA' and valor=1500.0;
update public.fluxo_caixa set categoria='REEMBOLSO DE ART', subcategoria=NULL where id=605 and tipo='RECEITA' and valor=108.39;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Posto de combustível' where id=607 and tipo='RECEITA' and valor=1200.0;
update public.fluxo_caixa set categoria='REEMBOLSO DE ART', subcategoria=NULL where id=608 and tipo='RECEITA' and valor=108.39;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=611 and tipo='RECEITA' and valor=296.8;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Posto de combustível' where id=615 and tipo='RECEITA' and valor=1740.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='Atestado de classe / conformidade' where id=616 and tipo='RECEITA' and valor=1500.0;
update public.fluxo_caixa set categoria='REEMBOLSO DE ART', subcategoria=NULL where id=617 and tipo='RECEITA' and valor=108.39;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=620 and tipo='RECEITA' and valor=1232.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=621 and tipo='RECEITA' and valor=1568.0;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de reforma / instalação' where id=626 and tipo='RECEITA' and valor=5000.0;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Posto de combustível' where id=641 and tipo='RECEITA' and valor=1808.39;
update public.fluxo_caixa set categoria='APORTE (PRÓPRIO)', subcategoria=NULL where id=643 and tipo='RECEITA' and valor=200.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=645 and tipo='RECEITA' and valor=2060.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='Outros laudos' where id=646 and tipo='RECEITA' and valor=1500.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='Integridade de tanque' where id=647 and tipo='RECEITA' and valor=1400.0;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Outras empresas / rede de gás' where id=648 and tipo='RECEITA' and valor=1000.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 13 – Caldeiras, vasos de pressão e compressores' where id=649 and tipo='RECEITA' and valor=1000.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='Integridade de tanque' where id=650 and tipo='RECEITA' and valor=1000.0;
update public.fluxo_caixa set categoria='REEMBOLSO DE ART', subcategoria=NULL where id=651 and tipo='RECEITA' and valor=103.03;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=655 and tipo='RECEITA' and valor=1700.0;
update public.fluxo_caixa set categoria='REEMBOLSO DE ART', subcategoria=NULL where id=656 and tipo='RECEITA' and valor=108.39;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de reforma / instalação' where id=728 and tipo='RECEITA' and valor=5000.0;
update public.fluxo_caixa set categoria='APORTE (PRÓPRIO)', subcategoria=NULL where id=741 and tipo='RECEITA' and valor=200.0;
update public.fluxo_caixa set categoria='APORTE (PRÓPRIO)', subcategoria=NULL where id=744 and tipo='RECEITA' and valor=60.0;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de reforma / instalação' where id=745 and tipo='RECEITA' and valor=5000.0;
update public.fluxo_caixa set categoria='RESPONSABILIDADE TÉCNICA', subcategoria='Mensal' where id=747 and tipo='RECEITA' and valor=1000.0;
update public.fluxo_caixa set categoria='APORTE (PRÓPRIO)', subcategoria=NULL where id=755 and tipo='RECEITA' and valor=2000.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=756 and tipo='RECEITA' and valor=358.33;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=766 and tipo='RECEITA' and valor=908.39;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=767 and tipo='RECEITA' and valor=908.39;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de reforma / instalação' where id=770 and tipo='RECEITA' and valor=5000.0;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de reforma / instalação' where id=772 and tipo='RECEITA' and valor=620.0;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de reforma / instalação' where id=773 and tipo='RECEITA' and valor=1240.0;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de reforma / instalação' where id=774 and tipo='RECEITA' and valor=1240.0;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de posto novo' where id=775 and tipo='RECEITA' and valor=41382.0;
update public.fluxo_caixa set categoria='APORTE (PRÓPRIO)', subcategoria=NULL where id=782 and tipo='RECEITA' and valor=500.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=793 and tipo='RECEITA' and valor=1250.0;
update public.fluxo_caixa set categoria='LIMPEZA DE TANQUE', subcategoria=NULL where id=795 and tipo='RECEITA' and valor=1300.0;
update public.fluxo_caixa set categoria='APORTE (PRÓPRIO)', subcategoria=NULL where id=800 and tipo='RECEITA' and valor=70.0;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de posto novo' where id=801 and tipo='RECEITA' and valor=2500.0;
update public.fluxo_caixa set categoria='LIMPEZA DE TANQUE', subcategoria=NULL where id=802 and tipo='RECEITA' and valor=2411.28;
update public.fluxo_caixa set categoria='LIMPEZA DE TANQUE', subcategoria=NULL where id=803 and tipo='RECEITA' and valor=723.38;
update public.fluxo_caixa set categoria='LIMPEZA DE TANQUE', subcategoria=NULL where id=804 and tipo='RECEITA' and valor=65.34;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de reforma / instalação' where id=815 and tipo='RECEITA' and valor=15000.0;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Posto de combustível' where id=816 and tipo='RECEITA' and valor=1000.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='Integridade de tanque' where id=817 and tipo='RECEITA' and valor=1600.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=823 and tipo='RECEITA' and valor=1115.07;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Posto de combustível' where id=824 and tipo='RECEITA' and valor=1254.19;
update public.fluxo_caixa set categoria='MANUTENÇÃO', subcategoria='Manutenção de equipamento' where id=828 and tipo='RECEITA' and valor=550.0;
update public.fluxo_caixa set categoria='MANUTENÇÃO', subcategoria='Manutenção de equipamento' where id=829 and tipo='RECEITA' and valor=1200.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 13 – Caldeiras, vasos de pressão e compressores' where id=841 and tipo='RECEITA' and valor=708.39;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de posto novo' where id=845 and tipo='RECEITA' and valor=24000.0;
update public.fluxo_caixa set categoria='VENDA DE PEÇAS', subcategoria='Outras peças e materiais' where id=852 and tipo='RECEITA' and valor=12000.0;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Outras empresas / rede de gás' where id=854 and tipo='RECEITA' and valor=1000.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=857 and tipo='RECEITA' and valor=1232.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=858 and tipo='RECEITA' and valor=1568.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=859 and tipo='RECEITA' and valor=296.8;
update public.fluxo_caixa set categoria='APORTE (PRÓPRIO)', subcategoria=NULL where id=864 and tipo='RECEITA' and valor=200.0;
update public.fluxo_caixa set categoria='RESPONSABILIDADE TÉCNICA', subcategoria='Avulsa', cliente='EXTIMPOL' where id=871 and tipo='RECEITA' and valor=900.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='Integridade de tanque' where id=872 and tipo='RECEITA' and valor=2750.0;
update public.fluxo_caixa set categoria='APORTE (PRÓPRIO)', subcategoria=NULL where id=885 and tipo='RECEITA' and valor=200.0;
update public.fluxo_caixa set categoria='LIMPEZA DE TANQUE', subcategoria=NULL where id=888 and tipo='RECEITA' and valor=2500.0;
update public.fluxo_caixa set categoria='RESPONSABILIDADE TÉCNICA', subcategoria='Mensal' where id=889 and tipo='RECEITA' and valor=1000.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=906 and tipo='RECEITA' and valor=358.33;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Posto de combustível' where id=922 and tipo='RECEITA' and valor=1228.39;
update public.fluxo_caixa set categoria='APORTE (PRÓPRIO)', subcategoria=NULL where id=923 and tipo='RECEITA' and valor=2000.0;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Posto de combustível' where id=924 and tipo='RECEITA' and valor=1250.0;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Outras empresas / rede de gás' where id=925 and tipo='RECEITA' and valor=1250.0;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de posto novo' where id=929 and tipo='RECEITA' and valor=2500.0;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de posto novo' where id=945 and tipo='RECEITA' and valor=18666.66;
update public.fluxo_caixa set categoria='RESPONSABILIDADE TÉCNICA', subcategoria='Avulsa' where id=947 and tipo='RECEITA' and valor=2500.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=958 and tipo='RECEITA' and valor=900.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=959 and tipo='RECEITA' and valor=900.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=960 and tipo='RECEITA' and valor=296.8;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=971 and tipo='RECEITA' and valor=1568.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=972 and tipo='RECEITA' and valor=1232.0;
update public.fluxo_caixa set categoria='INSTALAÇÃO', subcategoria='Filtro', valor=1200.0, observacao=trim(both ' —' from coalesce(observacao,'') || ' — Dividido na migração de categorias (13/11)') where id=974 and tipo='RECEITA' and valor=2000.0;
update public.fluxo_caixa set categoria='MANUTENÇÃO', subcategoria='Manutenção de equipamento' where id=975 and tipo='RECEITA' and valor=400.0;
update public.fluxo_caixa set categoria='VENDA DE PEÇAS', subcategoria='Outras peças e materiais' where id=976 and tipo='RECEITA' and valor=188.57;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=977 and tipo='RECEITA' and valor=1115.07;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Outras empresas / rede de gás' where id=978 and tipo='RECEITA' and valor=1000.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 13 – Caldeiras, vasos de pressão e compressores' where id=979 and tipo='RECEITA' and valor=1000.0;
update public.fluxo_caixa set categoria='VENDA DE PEÇAS', subcategoria='Peças soldáveis' where id=980 and tipo='RECEITA' and valor=525.0;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Posto de combustível' where id=981 and tipo='RECEITA' and valor=600.0;
update public.fluxo_caixa set categoria='VENDA DE PEÇAS', subcategoria='Peças soldáveis' where id=982 and tipo='RECEITA' and valor=823.8;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=983 and tipo='RECEITA' and valor=800.0;
update public.fluxo_caixa set categoria='REEMBOLSO DE ART', subcategoria=NULL where id=984 and tipo='RECEITA' and valor=108.39;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 13 – Caldeiras, vasos de pressão e compressores' where id=985 and tipo='RECEITA' and valor=4000.0;
update public.fluxo_caixa set categoria='MANUTENÇÃO', subcategoria='Manutenção aparelho de medição' where id=986 and tipo='RECEITA' and valor=800.0;
update public.fluxo_caixa set categoria='REEMBOLSO DE ART', subcategoria=NULL where id=987 and tipo='RECEITA' and valor=108.39;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 13 – Caldeiras, vasos de pressão e compressores' where id=988 and tipo='RECEITA' and valor=1800.0;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Posto de combustível' where id=989 and tipo='RECEITA' and valor=1508.39;
update public.fluxo_caixa set categoria='TESTE DE ESTANQUEIDADE', subcategoria='Posto de combustível' where id=990 and tipo='RECEITA' and valor=1228.39;
update public.fluxo_caixa set categoria='VENDA DE PEÇAS', subcategoria='Outras peças e materiais' where id=992 and tipo='RECEITA' and valor=2950.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='Atestado de classe / conformidade' where id=994 and tipo='RECEITA' and valor=2333.33;
update public.fluxo_caixa set categoria='LIMPEZA DE TANQUE', subcategoria=NULL where id=995 and tipo='RECEITA' and valor=3800.0;
update public.fluxo_caixa set categoria='MANUTENÇÃO', subcategoria='Manutenção de equipamento', valor=300.0, observacao=trim(both ' —' from coalesce(observacao,'') || ' — Dividido na migração de categorias (13/11)') where id=1005 and tipo='RECEITA' and valor=1220.0;
update public.fluxo_caixa set categoria='APORTE (PRÓPRIO)', subcategoria=NULL where id=1010 and tipo='RECEITA' and valor=200.0;
update public.fluxo_caixa set categoria='APORTE (PRÓPRIO)', subcategoria=NULL where id=1011 and tipo='RECEITA' and valor=200.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 13 – Caldeiras, vasos de pressão e compressores' where id=1017 and tipo='RECEITA' and valor=700.0;
update public.fluxo_caixa set categoria='RESPONSABILIDADE TÉCNICA', subcategoria='Mensal' where id=1018 and tipo='RECEITA' and valor=1000.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 13 – Caldeiras, vasos de pressão e compressores' where id=1021 and tipo='RECEITA' and valor=2690.0;
update public.fluxo_caixa set categoria='APORTE (PRÓPRIO)', subcategoria=NULL where id=1038 and tipo='RECEITA' and valor=30.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 13 – Caldeiras, vasos de pressão e compressores' where id=1039 and tipo='RECEITA' and valor=600.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 13 – Caldeiras, vasos de pressão e compressores' where id=1040 and tipo='RECEITA' and valor=4500.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 13 – Caldeiras, vasos de pressão e compressores' where id=1041 and tipo='RECEITA' and valor=4200.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='VOC / passivo ambiental' where id=1043 and tipo='RECEITA' and valor=4500.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=1049 and tipo='RECEITA' and valor=358.37;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='Integridade de tanque' where id=1052 and tipo='RECEITA' and valor=1400.0;
update public.fluxo_caixa set categoria='VENDA DE PEÇAS', subcategoria='Outras peças e materiais' where id=1053 and tipo='RECEITA' and valor=350.0;
update public.fluxo_caixa set categoria='APORTE (PRÓPRIO)', subcategoria=NULL where id=1055 and tipo='RECEITA' and valor=2000.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='Perícia' where id=1056 and tipo='RECEITA' and valor=4705.61;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de posto novo' where id=1059 and tipo='RECEITA' and valor=18666.66;
update public.fluxo_caixa set categoria='COMISSÃO', subcategoria=NULL where id=1063 and tipo='RECEITA' and valor=1200.0;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de reforma / instalação' where id=1068 and tipo='RECEITA' and valor=4700.0;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de reforma / instalação' where id=1069 and tipo='RECEITA' and valor=300.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='Atestado de classe / conformidade' where id=1074 and tipo='RECEITA' and valor=2333.33;
update public.fluxo_caixa set categoria='VENDA DE PEÇAS', subcategoria='Peças soldáveis' where id=1078 and tipo='RECEITA' and valor=3026.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=1084 and tipo='RECEITA' and valor=900.0;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de posto novo' where id=1088 and tipo='RECEITA' and valor=4320.0;
update public.fluxo_caixa set categoria='OBRA', subcategoria='Obra de reforma / instalação' where id=1090 and tipo='RECEITA' and valor=15000.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=1093 and tipo='RECEITA' and valor=1232.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=1094 and tipo='RECEITA' and valor=1568.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=1099 and tipo='RECEITA' and valor=296.8;
update public.fluxo_caixa set categoria='VENDA DE PEÇAS', subcategoria='Peças soldáveis' where id=1112 and tipo='RECEITA' and valor=3027.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='Integridade de tanque' where id=1113 and tipo='RECEITA' and valor=2500.0;
update public.fluxo_caixa set categoria='APORTE (PRÓPRIO)', subcategoria=NULL where id=1126 and tipo='RECEITA' and valor=300.0;
update public.fluxo_caixa set categoria='INSTALAÇÃO', subcategoria='Bomba', valor=300.0, observacao=trim(both ' —' from coalesce(observacao,'') || ' — Dividido na migração de categorias (13/11)') where id=1129 and tipo='RECEITA' and valor=600.0;
update public.fluxo_caixa set categoria='LAUDO', subcategoria='NR 11 – Movimentação e armazenagem' where id=1132 and tipo='RECEITA' and valor=2500.0;
update public.fluxo_caixa set categoria='APORTE (PRÓPRIO)', subcategoria=NULL where id=1144 and tipo='RECEITA' and valor=300.0;

-- 4) Despesas do SICOOB que estavam em outras categorias
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS' where id=341 and tipo='DESPESA' and valor=60.44;
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS' where id=757 and tipo='DESPESA' and valor=4.0;

-- 5) Ordens de serviço: tipo + sub em cada item da divisão; serviço único vira o rótulo novo
update public.ordens_servico set servicos_itens='[{"tipo":"TESTE DE ESTANQUEIDADE","sub":"Posto de combustível","valor":1000.0},{"tipo":"LAUDO","sub":"Integridade de tanque","valor":1000.0},{"tipo":"LAUDO","sub":"Atestado de classe / conformidade","valor":2000.0}]' where id=2 and coalesce(servicos_itens,'')='[{"tipo":"ESTANQUEIDADE","valor":1000},{"tipo":"INTEGRIDADE","valor":1000},{"tipo":"OUTRO","valor":2000}]';
update public.ordens_servico set servicos_itens='[{"tipo":"TESTE DE ESTANQUEIDADE","sub":"Posto de combustível","valor":1000},{"tipo":"LAUDO","sub":"Integridade de tanque","valor":1113.03}]' where id=3 and coalesce(servicos_itens,'')='';
update public.ordens_servico set servico='LIMPEZA DE TANQUE' where id=4 and coalesce(servico,'')='OBRA';
update public.ordens_servico set servicos_itens='[{"tipo":"TESTE DE ESTANQUEIDADE","sub":"Posto de combustível","valor":800},{"tipo":"LAUDO","sub":"Integridade de tanque","valor":1113.03}]' where id=5 and coalesce(servicos_itens,'')='';
update public.ordens_servico set servicos_itens='[{"tipo":"TESTE DE ESTANQUEIDADE","sub":"Posto de combustível","valor":1000},{"tipo":"LAUDO","sub":"Integridade de tanque","valor":1113.03}]' where id=6 and coalesce(servicos_itens,'')='';
update public.ordens_servico set servico='VENDA DE PEÇAS › Outras peças e materiais' where id=7 and coalesce(servico,'')='VENDA DE EQUIPAMENTOS';
update public.ordens_servico set servico='LAUDO › NR 11 – Movimentação e armazenagem' where id=8 and coalesce(servico,'')='NR 11';
update public.ordens_servico set servico='TESTE DE ESTANQUEIDADE › Outras empresas / rede de gás' where id=9 and coalesce(servico,'')='ESTANQUEIDADE';
update public.ordens_servico set servico='RESPONSABILIDADE TÉCNICA › Avulsa' where id=10 and coalesce(servico,'')='RESPONSABILIDADE TENCNICA';
update public.ordens_servico set servico='LAUDO › NR 11 – Movimentação e armazenagem' where id=12 and coalesce(servico,'')='NR 11';
update public.ordens_servico set servico='LAUDO › NR 11 – Movimentação e armazenagem' where id=13 and coalesce(servico,'')='NR 11';
update public.ordens_servico set servico='OBRA › Obra de reforma / instalação' where id=14 and coalesce(servico,'')='OBRA';
update public.ordens_servico set servico='LAUDO › NR 35 – Trabalho em altura (linha de vida)' where id=15 and coalesce(servico,'')='LAUDO LINHA DE VIDA';
update public.ordens_servico set servico='OBRA › Obra de reforma / instalação' where id=17 and coalesce(servico,'')='OBRA';
update public.ordens_servico set servico='OBRA › Obra de reforma / instalação' where id=18 and coalesce(servico,'')='OBRA';
update public.ordens_servico set servico='TESTE DE ESTANQUEIDADE › Posto de combustível' where id=19 and coalesce(servico,'')='ESTANQUEIDADE';
update public.ordens_servico set servico='OBRA › Obra de reforma / instalação' where id=20 and coalesce(servico,'')='OBRA';
update public.ordens_servico set servico='RESPONSABILIDADE TÉCNICA › Mensal' where id=21 and coalesce(servico,'')='RESPONSABILIDADE TECNICA';
update public.ordens_servico set servico='OBRA › Obra de posto novo' where id=22 and coalesce(servico,'')='OBRA';
update public.ordens_servico set servico='LAUDO › NR 12 – Máquinas e equipamentos' where id=23 and coalesce(servico,'')='NR 12';
update public.ordens_servico set servico='LAUDO › NR 11 – Movimentação e armazenagem' where id=24 and coalesce(servico,'')='NR 11';
update public.ordens_servico set servico='LAUDO › Tanque aéreo' where id=25 and coalesce(servico,'')='TANQUE AEREO';
update public.ordens_servico set servico='LAUDO › Tanque aéreo' where id=26 and coalesce(servico,'')='TANQUE AEREO';
update public.ordens_servico set servico='LAUDO › Tanque aéreo' where id=27 and coalesce(servico,'')='TANQUE AEREO E REDE DE GÁS';
update public.ordens_servico set servico='LAUDO › NR 11 – Movimentação e armazenagem' where id=28 and coalesce(servico,'')='EMPILHADEIRAS';
update public.ordens_servico set servico='TESTE DE ESTANQUEIDADE › Posto de combustível' where id=31 and coalesce(servico,'')='ESTANQUEIDADE';
update public.ordens_servico set servico='LAUDO › Tanque aéreo' where id=32 and coalesce(servico,'')='TANQUE AEREO';
update public.ordens_servico set servico='TESTE DE ESTANQUEIDADE › Posto de combustível' where id=34 and coalesce(servico,'')='ESTANQUEIDADE';
update public.ordens_servico set servico='TESTE DE ESTANQUEIDADE › Posto de combustível' where id=35 and coalesce(servico,'')='ESTANQUEIDADE';
update public.ordens_servico set servico='TESTE DE ESTANQUEIDADE › Posto de combustível' where id=36 and coalesce(servico,'')='ESTANQUEIDADE';
update public.ordens_servico set servico='OBRA › Obra de reforma / instalação' where id=37 and coalesce(servico,'')='OBRA';
update public.ordens_servico set servico='OBRA › Obra de reforma / instalação' where id=38 and coalesce(servico,'')='OBRA';
update public.ordens_servico set servico='OBRA › Obra de posto novo' where id=39 and coalesce(servico,'')='OBRA';
update public.ordens_servico set servico='VENDA DE PEÇAS › Tanques' where id=40 and coalesce(servico,'')='VENDA DE TANQUES';
update public.ordens_servico set servico='VENDA DE PEÇAS › Tanques' where id=41 and coalesce(servico,'')='TANQUE USADO';
update public.ordens_servico set servico='LAUDO › VOC / passivo ambiental' where id=42 and coalesce(servico,'')='VOC';
update public.ordens_servico set servico='LIMPEZA DE TANQUE' where id=46 and coalesce(servico,'')='OBRA';
update public.ordens_servico set servico='TESTE DE ESTANQUEIDADE › Posto de combustível' where id=47 and coalesce(servico,'')='ESTANQUEIDADE';
update public.ordens_servico set servico='TESTE DE ESTANQUEIDADE › Posto de combustível' where id=84 and coalesce(servico,'')='ESTANQUEIDADE';
update public.ordens_servico set servico='TESTE DE ESTANQUEIDADE › Posto de combustível' where id=85 and coalesce(servico,'')='ESTANQUEIDADE';
update public.ordens_servico set servico='TESTE DE ESTANQUEIDADE › Posto de combustível' where id=86 and coalesce(servico,'')='ESTANQUEIDADE';
update public.ordens_servico set servico='OBRA › Obra de reforma / instalação' where id=88 and coalesce(servico,'')='OBRA';
update public.ordens_servico set servicos_itens='[{"tipo":"TESTE DE ESTANQUEIDADE","sub":"Posto de combustível","valor":1400.0},{"tipo":"REEMBOLSO DE ART","valor":108.39}]' where id=89 and coalesce(servicos_itens,'')='[{"tipo":"ESTANQUEIDADE","valor":1400},{"tipo":"ART","valor":108.39}]';
update public.ordens_servico set servicos_itens='[{"tipo":"TESTE DE ESTANQUEIDADE","sub":"Posto de combustível","valor":1808.39}]' where id=90 and coalesce(servicos_itens,'')='[{"tipo":"ESTANQUEIDADE","valor":1808.3899999999999}]';
update public.ordens_servico set servicos_itens='[{"tipo":"LAUDO","sub":"NR 11 – Movimentação e armazenagem","valor":3345.18}]' where id=91 and coalesce(servicos_itens,'')='[{"tipo":"NR 11","valor":3345.18}]';
update public.ordens_servico set servicos_itens='[{"tipo":"TESTE DE ESTANQUEIDADE","sub":"Outras empresas / rede de gás","valor":1608.39}]' where id=92 and coalesce(servicos_itens,'')='[{"tipo":"ESTANQUEIDADE","valor":1608.39}]';
update public.ordens_servico set servico='LAUDO › NR 11 – Movimentação e armazenagem' where id=93 and coalesce(servico,'')='NR 11';
update public.ordens_servico set servicos_itens='[{"tipo":"LAUDO","sub":"NR 13 – Caldeiras, vasos de pressão e compressores","valor":600.0},{"tipo":"REEMBOLSO DE ART","valor":108.39}]' where id=95 and coalesce(servicos_itens,'')='[{"tipo":"NR 13","valor":600},{"tipo":"ART","valor":108.39}]';
update public.ordens_servico set servico='LAUDO › Integridade de tanque' where id=96 and coalesce(servico,'')='INTEGRIDADE';
update public.ordens_servico set servico='LAUDO › Integridade de tanque' where id=97 and coalesce(servico,'')='INTEGRIDADE';
update public.ordens_servico set servico='LAUDO › Integridade de tanque' where id=98 and coalesce(servico,'')='INTEGRIDADE';
update public.ordens_servico set servico='LAUDO › Outros laudos' where id=100 and coalesce(servico,'')='OUTRO';
update public.ordens_servico set servico='LAUDO › NR 11 – Movimentação e armazenagem' where id=101 and coalesce(servico,'')='NR 11';
update public.ordens_servico set servico='OBRA › Obra de reforma / instalação' where id=102 and coalesce(servico,'')='OBRA';
update public.ordens_servico set servicos_itens='[{"tipo":"OBRA","sub":"Obra de reforma / instalação","valor":3500.0}]' where id=103 and coalesce(servicos_itens,'')='[{"tipo":"OBRA","valor":3500}]';
update public.ordens_servico set servico='LAUDO › NR 11 – Movimentação e armazenagem' where id=104 and coalesce(servico,'')='NR 11';
update public.ordens_servico set servico='LAUDO › NR 11 – Movimentação e armazenagem' where id=105 and coalesce(servico,'')='NR 11';
update public.ordens_servico set servico='OBRA › Obra de reforma / instalação' where id=106 and coalesce(servico,'')='OBRA';
update public.ordens_servico set servicos_itens='[{"tipo":"TESTE DE ESTANQUEIDADE","sub":"Posto de combustível","valor":2508.39}]' where id=107 and coalesce(servicos_itens,'')='[{"tipo":"ESTANQUEIDADE","valor":2508.39}]';
update public.ordens_servico set servico='OBRA › Obra de posto novo' where id=108 and coalesce(servico,'')='COBERTURA METÁLICA';
update public.ordens_servico set servico='TESTE DE ESTANQUEIDADE › Posto de combustível' where id=109 and coalesce(servico,'')='ESTANQUEIDADE';
update public.ordens_servico set servicos_itens='[{"tipo":"TESTE DE ESTANQUEIDADE","sub":"Posto de combustível","valor":1168.39}]' where id=111 and coalesce(servicos_itens,'')='[{"tipo":"ESTANQUEIDADE","valor":1168.39}]';
update public.ordens_servico set servicos_itens='[{"tipo":"TESTE DE ESTANQUEIDADE","sub":"Posto de combustível","valor":1168.39}]' where id=112 and coalesce(servicos_itens,'')='[{"tipo":"ESTANQUEIDADE","valor":1168.39}]';
update public.ordens_servico set servicos_itens='[{"tipo":"TESTE DE ESTANQUEIDADE","sub":"Posto de combustível","valor":1433.39}]' where id=113 and coalesce(servicos_itens,'')='[{"tipo":"ESTANQUEIDADE","valor":1433.39}]';
update public.ordens_servico set servicos_itens='[{"tipo":"TESTE DE ESTANQUEIDADE","sub":"Posto de combustível","valor":1698.39}]' where id=114 and coalesce(servicos_itens,'')='[{"tipo":"ESTANQUEIDADE","valor":1698.39}]';
update public.ordens_servico set servicos_itens='[{"tipo":"TESTE DE ESTANQUEIDADE","sub":"Posto de combustível","valor":1433.39}]' where id=115 and coalesce(servicos_itens,'')='[{"tipo":"ESTANQUEIDADE","valor":1433.39}]';
update public.ordens_servico set servicos_itens='[{"tipo":"TESTE DE ESTANQUEIDADE","sub":"Posto de combustível","valor":1433.39}]' where id=116 and coalesce(servicos_itens,'')='[{"tipo":"ESTANQUEIDADE","valor":1433.39}]';
update public.ordens_servico set servicos_itens='[{"tipo":"TESTE DE ESTANQUEIDADE","sub":"Posto de combustível","valor":1168.39}]' where id=117 and coalesce(servicos_itens,'')='[{"tipo":"ESTANQUEIDADE","valor":1168.39}]';
update public.ordens_servico set servicos_itens='[{"tipo":"TESTE DE ESTANQUEIDADE","sub":"Posto de combustível","valor":1168.39}]' where id=118 and coalesce(servicos_itens,'')='[{"tipo":"ESTANQUEIDADE","valor":1168.39}]';
update public.ordens_servico set servicos_itens='[{"tipo":"TESTE DE ESTANQUEIDADE","sub":"Posto de combustível","valor":1433.39}]' where id=119 and coalesce(servicos_itens,'')='[{"tipo":"ESTANQUEIDADE","valor":1433.39}]';
update public.ordens_servico set servicos_itens='[{"tipo":"TESTE DE ESTANQUEIDADE","sub":"Posto de combustível","valor":1608.39}]' where id=120 and coalesce(servicos_itens,'')='[{"tipo":"ESTANQUEIDADE","valor":1608.39}]';
update public.ordens_servico set servico='LAUDO › Tanque aéreo' where id=121 and coalesce(servico,'')='LAUDO TÉCNICO';
update public.ordens_servico set servico='LAUDO › NR 13 – Caldeiras, vasos de pressão e compressores' where id=123 and coalesce(servico,'')='NR 13';
update public.ordens_servico set servicos_itens='[{"tipo":"INSTALAÇÃO","sub":"Tanque","valor":1000},{"tipo":"VENDA DE PEÇAS","sub":"Outras peças e materiais","valor":6000}]' where id=127 and coalesce(servicos_itens,'')='[{"tipo":"OBRA","valor":7000}]';
update public.ordens_servico set servicos_itens='[{"tipo":"MANUTENÇÃO","sub":"Manutenção de equipamento","valor":1000},{"tipo":"VENDA DE PEÇAS","sub":"Outras peças e materiais","valor":4400}]' where id=128 and coalesce(servicos_itens,'')='';
update public.ordens_servico set servico='OBRA › Obra de reforma / instalação' where id=129 and coalesce(servico,'')='OBRA';
update public.ordens_servico set servico='LAUDO › NR 11 – Movimentação e armazenagem' where id=130 and coalesce(servico,'')='NR 11';
update public.ordens_servico set servicos_itens='[{"tipo":"LAUDO","sub":"Tanque aéreo","valor":1000.0},{"tipo":"LAUDO","sub":"NR 13 – Caldeiras, vasos de pressão e compressores","valor":1000.0}]' where id=131 and coalesce(servicos_itens,'')='[{"tipo":"TANQUE AEREO","valor":1000},{"tipo":"LAUDO TÉCNICO","valor":1000}]';
update public.ordens_servico set servicos_itens='[{"tipo":"LIMPEZA DE TANQUE","valor":4000.0},{"tipo":"TESTE DE ESTANQUEIDADE","sub":"Posto de combustível","valor":1200.0},{"tipo":"REEMBOLSO DE ART","valor":108.39}]' where id=132 and coalesce(servicos_itens,'')='[{"tipo":"LIMPEZA DE TANQUE","valor":4000},{"tipo":"ESTANQUEIDADE","valor":1200},{"tipo":"ART","valor":108.39}]';
update public.ordens_servico set servicos_itens='[{"tipo":"LAUDO","sub":"NR 11 – Movimentação e armazenagem","valor":800.0},{"tipo":"REEMBOLSO DE ART","valor":108.39}]' where id=133 and coalesce(servicos_itens,'')='[{"tipo":"NR 11","valor":800},{"tipo":"ART","valor":108.39}]';
update public.ordens_servico set servico='LAUDO › NR 11 – Movimentação e armazenagem' where id=134 and coalesce(servico,'')='LAUDO TÉCNICO';
update public.ordens_servico set servicos_itens='[{"tipo":"TESTE DE ESTANQUEIDADE","sub":"Outras empresas / rede de gás","valor":1600.0},{"tipo":"REEMBOLSO DE ART","valor":108.39}]' where id=135 and coalesce(servicos_itens,'')='[{"tipo":"ESTANQUEIDADE","valor":1600},{"tipo":"ART","valor":108.39}]';
update public.ordens_servico set servico='LAUDO › NR 11 – Movimentação e armazenagem' where id=136 and coalesce(servico,'')='LAUDO TÉCNICO';
update public.ordens_servico set servicos_itens='[{"tipo":"LAUDO","sub":"NR 11 – Movimentação e armazenagem","valor":1700.0},{"tipo":"REEMBOLSO DE ART","valor":108.39}]' where id=137 and coalesce(servicos_itens,'')='[{"tipo":"NR 11","valor":1700},{"tipo":"ART","valor":108.39}]';
update public.ordens_servico set servico='LAUDO › Tanque aéreo' where id=138 and coalesce(servico,'')='TANQUE AEREO';
update public.ordens_servico set servicos_itens='[{"tipo":"TESTE DE ESTANQUEIDADE","sub":"Posto de combustível","valor":1740.0},{"tipo":"LAUDO","sub":"Atestado de classe / conformidade","valor":1500.0},{"tipo":"REEMBOLSO DE ART","valor":108.39}]' where id=139 and coalesce(servicos_itens,'')='[{"tipo":"ESTANQUEIDADE","valor":1740},{"tipo":"LAUDO DE CLASSE","valor":1500},{"tipo":"ART","valor":108.39}]';
update public.ordens_servico set servicos_itens='[{"tipo":"TESTE DE ESTANQUEIDADE","sub":"Posto de combustível","valor":400.0},{"tipo":"OBRA","sub":"Obra de reforma / instalação","valor":1000.0},{"tipo":"VENDA DE PEÇAS","sub":"Peças soldáveis","valor":508.0}]' where id=140 and coalesce(servicos_itens,'')='[{"tipo":"ESTANQUEIDADE","valor":400},{"tipo":"OBRA","valor":1000},{"tipo":"PAGAMENTO PELO MATERIAL UTILIZADO","valor":508}]';
update public.ordens_servico set servicos_itens='[{"tipo":"LAUDO","sub":"Outros laudos","valor":1500.0},{"tipo":"LAUDO","sub":"Integridade de tanque","valor":1400.0},{"tipo":"TESTE DE ESTANQUEIDADE","sub":"Outras empresas / rede de gás","valor":1000.0},{"tipo":"LAUDO","sub":"NR 13 – Caldeiras, vasos de pressão e compressores","valor":1000.0},{"tipo":"LAUDO","sub":"Integridade de tanque","valor":1000.0},{"tipo":"REEMBOLSO DE ART","valor":103.03}]' where id=141 and coalesce(servicos_itens,'')='[{"tipo":"LAUDO TÉCNICO","valor":1500},{"tipo":"INTEGRIDADE","valor":1400},{"tipo":"ESTANQUEIDADE","valor":1000},{"tipo":"NR 13","valor":1000},{"tipo":"INTEGRIDADE","valor":1000},{"tipo":"ART","valor":103.03}]';
update public.ordens_servico set servico='TESTE DE ESTANQUEIDADE › Posto de combustível' where id=142 and coalesce(servico,'')='ESTANQUEIDADE';
update public.ordens_servico set servico='TESTE DE ESTANQUEIDADE › Posto de combustível' where id=144 and coalesce(servico,'')='ESTANQUEIDADE';
update public.ordens_servico set servico='LAUDO › NR 11 – Movimentação e armazenagem' where id=145 and coalesce(servico,'')='LAUDO TÉCNICO';
update public.ordens_servico set servicos_itens='[{"tipo":"TESTE DE ESTANQUEIDADE","sub":"Posto de combustível","valor":600.0}]' where id=147 and coalesce(servicos_itens,'')='[{"tipo":"ESTANQUEIDADE","valor":600}]';
update public.ordens_servico set servicos_itens='[{"tipo":"TESTE DE ESTANQUEIDADE","sub":"Posto de combustível","valor":1000.0},{"tipo":"LAUDO","sub":"Integridade de tanque","valor":1600.0}]' where id=148 and coalesce(servicos_itens,'')='[{"tipo":"ESTANQUEIDADE","valor":1000},{"tipo":"INTEGRIDADE","valor":1600}]';
update public.ordens_servico set servico='LAUDO › NR 11 – Movimentação e armazenagem' where id=149 and coalesce(servico,'')='NR 11';
update public.ordens_servico set servico='LAUDO › NR 11 – Movimentação e armazenagem' where id=150 and coalesce(servico,'')='NR 11';
update public.ordens_servico set servicos_itens='[{"tipo":"TESTE DE ESTANQUEIDADE","sub":"Posto de combustível","valor":1200.0},{"tipo":"REEMBOLSO DE ART","valor":108.39}]' where id=151 and coalesce(servicos_itens,'')='[{"tipo":"ESTANQUEIDADE","valor":1200},{"tipo":"ART","valor":108.39}]';
update public.ordens_servico set servicos_itens='[{"tipo":"TESTE DE ESTANQUEIDADE","sub":"Posto de combustível","valor":1500.0},{"tipo":"REEMBOLSO DE ART","valor":108.39}]' where id=152 and coalesce(servicos_itens,'')='[{"tipo":"ESTANQUEIDADE","valor":1500},{"tipo":"ART","valor":108.39}]';
update public.ordens_servico set servico='LAUDO › NR 11 – Movimentação e armazenagem' where id=153 and coalesce(servico,'')='NR 11';
update public.ordens_servico set servico='PROJETO › Cobertura metálica' where id=154 and coalesce(servico,'')='COBERTURA METÁLICA';
update public.ordens_servico set servicos_itens='[{"tipo":"LAUDO","sub":"NR 13 – Caldeiras, vasos de pressão e compressores","valor":4000.0},{"tipo":"MANUTENÇÃO","sub":"Manutenção aparelho de medição","valor":800.0},{"tipo":"REEMBOLSO DE ART","valor":108.39}]' where id=155 and coalesce(servicos_itens,'')='[{"tipo":"NR 13","valor":4000},{"tipo":"INSTALAÇÃO DE EQUIPAMENTOS","valor":800},{"tipo":"OBRA","valor":108.39}]';
update public.ordens_servico set servicos_itens='[{"tipo":"INSTALAÇÃO","sub":"Filtro","valor":1200},{"tipo":"OBRA","sub":"Obra de reforma / instalação","valor":800},{"tipo":"MANUTENÇÃO","sub":"Manutenção de equipamento","valor":400},{"tipo":"VENDA DE PEÇAS","sub":"Outras peças e materiais","valor":188.57}]' where id=156 and coalesce(servicos_itens,'')='[{"tipo":"OBRA","valor":2000},{"tipo":"MANUTENÇÃO PREVENTIVA","valor":400},{"tipo":"OUTRO","valor":188.57}]';
update public.ordens_servico set servico='LAUDO › NR 13 – Caldeiras, vasos de pressão e compressores' where id=157 and coalesce(servico,'')='NR 13';
update public.ordens_servico set servico='OBRA › Obra de reforma / instalação' where id=158 and coalesce(servico,'')='OBRA';
update public.ordens_servico set servico='OBRA › Obra de reforma / instalação' where id=159 and coalesce(servico,'')='OBRA';
update public.ordens_servico set servico='OBRA › Obra de reforma / instalação' where id=160 and coalesce(servico,'')='OBRA';
update public.ordens_servico set servicos_itens='[{"tipo":"LAUDO","sub":"NR 13 – Caldeiras, vasos de pressão e compressores","valor":1800.0}]' where id=161 and coalesce(servicos_itens,'')='[{"tipo":"NR 13","valor":1800}]';
update public.ordens_servico set servicos_itens='[{"tipo":"TESTE DE ESTANQUEIDADE","sub":"Outras empresas / rede de gás","valor":1000.0},{"tipo":"LAUDO","sub":"NR 13 – Caldeiras, vasos de pressão e compressores","valor":1000.0},{"tipo":"VENDA DE PEÇAS","sub":"Peças soldáveis","valor":525.0}]' where id=162 and coalesce(servicos_itens,'')='[{"tipo":"ESTANQUEIDADE","valor":1000},{"tipo":"NR 13","valor":1000},{"tipo":"PAGAMENTO PELO MATERIAL UTILIZADO","valor":525}]';
update public.ordens_servico set servico='TESTE DE ESTANQUEIDADE › Posto de combustível' where id=164 and coalesce(servico,'')='TESTE DE ESTANQUEIDADE';
update public.ordens_servico set servico='TESTE DE ESTANQUEIDADE › Outras empresas / rede de gás' where id=165 and coalesce(servico,'')='TESTE DE ESTANQUEIDADE';
update public.ordens_servico set servico='OBRA › Obra de posto novo' where id=168 and coalesce(servico,'')='POSTO DE GASOLINA';
update public.ordens_servico set servico='MANUTENÇÃO › Manutenção de equipamento' where id=169 and coalesce(servico,'')='MANUTENÇÃO PREVENTIVA';
update public.ordens_servico set servico='MANUTENÇÃO › Manutenção de equipamento' where id=170 and coalesce(servico,'')='MANUTENÇÃO PREVENTIVA';
update public.ordens_servico set servicos_itens='[{"tipo":"TESTE DE ESTANQUEIDADE","sub":"Posto de combustível","valor":1120.0},{"tipo":"REEMBOLSO DE ART","valor":108.39}]' where id=171 and coalesce(servicos_itens,'')='[{"tipo":"ESTANQUEIDADE","valor":1120},{"tipo":"TESTE DE ESTANQUEIDADE","valor":108.39}]';
update public.ordens_servico set servicos_itens='[{"tipo":"TESTE DE ESTANQUEIDADE","sub":"Posto de combustível","valor":1400.0},{"tipo":"REEMBOLSO DE ART","valor":108.39}]' where id=172 and coalesce(servicos_itens,'')='[{"tipo":"ESTANQUEIDADE","valor":1400},{"tipo":"TESTE DE ESTANQUEIDADE","valor":108.39}]';
update public.ordens_servico set servicos_itens='[{"tipo":"TESTE DE ESTANQUEIDADE","sub":"Posto de combustível","valor":1120.0},{"tipo":"REEMBOLSO DE ART","valor":108.39}]' where id=173 and coalesce(servicos_itens,'')='[{"tipo":"ESTANQUEIDADE","valor":1120},{"tipo":"TESTE DE ESTANQUEIDADE","valor":108.39}]';
update public.ordens_servico set servicos_itens='[{"tipo":"TESTE DE ESTANQUEIDADE","sub":"Posto de combustível","valor":600.0},{"tipo":"VENDA DE PEÇAS","sub":"Peças soldáveis","valor":823.8}]' where id=174 and coalesce(servicos_itens,'')='[{"tipo":"ESTANQUEIDADE","valor":600},{"tipo":"PAGAMENTO PELO MATERIAL UTILIZADO","valor":823.8}]';
update public.ordens_servico set servico='TESTE DE ESTANQUEIDADE › Outras empresas / rede de gás' where id=175 and coalesce(servico,'')='ESTANQUEIDADE';
update public.ordens_servico set servico='VENDA DE PEÇAS › Outras peças e materiais' where id=176 and coalesce(servico,'')='OUTRO';
update public.ordens_servico set servico='VENDA DE PEÇAS › Outras peças e materiais' where id=177 and coalesce(servico,'')='VENDAS DE MATERIAL';
update public.ordens_servico set servicos_itens='[{"tipo":"LAUDO","sub":"NR 13 – Caldeiras, vasos de pressão e compressores","valor":1908.39},{"tipo":"TESTE DE ESTANQUEIDADE","sub":"Outras empresas / rede de gás","valor":800.0}]' where id=178 and coalesce(servicos_itens,'')='[{"tipo":"LAUDO TÉCNICO","valor":1908.39},{"tipo":"ESTANQUEIDADE","valor":800}]';
update public.ordens_servico set servicos_itens='[{"tipo":"MANUTENÇÃO","sub":"Manutenção de equipamento","valor":300},{"tipo":"VENDA DE PEÇAS","sub":"Outras peças e materiais","valor":920}]' where id=179 and coalesce(servicos_itens,'')='[{"tipo":"MANUTENÇÃO CORRETIVA","valor":300},{"tipo":"PAGAMENTO PELO MATERIAL UTILIZADO","valor":920}]';
update public.ordens_servico set servicos_itens='[{"tipo":"LAUDO","sub":"Atestado de classe / conformidade","valor":5800.0},{"tipo":"TESTE DE ESTANQUEIDADE","sub":"Posto de combustível","valor":1200.0}]' where id=180 and coalesce(servicos_itens,'')='[{"tipo":"LAUDO TÉCNICO","valor":5800},{"tipo":"ESTANQUEIDADE","valor":1200}]';
update public.ordens_servico set servico='RESPONSABILIDADE TÉCNICA › Avulsa' where id=181 and coalesce(servico,'')='ART';
update public.ordens_servico set servico='LAUDO › VOC / passivo ambiental' where id=182 and coalesce(servico,'')='LAUDO TÉCNICO';
update public.ordens_servico set servico='LAUDO › NR 13 – Caldeiras, vasos de pressão e compressores' where id=183 and coalesce(servico,'')='NR 13';
update public.ordens_servico set servico='LAUDO › NR 13 – Caldeiras, vasos de pressão e compressores' where id=184 and coalesce(servico,'')='NR 13';
update public.ordens_servico set servico='LAUDO › NR 13 – Caldeiras, vasos de pressão e compressores' where id=185 and coalesce(servico,'')='NR 13';
update public.ordens_servico set servico='LAUDO › Integridade de tanque' where id=186 and coalesce(servico,'')='INTEGRIDADE';
update public.ordens_servico set servico='LAUDO › Integridade de tanque' where id=187 and coalesce(servico,'')='INTEGRIDADE';
update public.ordens_servico set servico='LAUDO › NR 11 – Movimentação e armazenagem' where id=188 and coalesce(servico,'')='NR 11';
update public.ordens_servico set servicos_itens='[{"tipo":"OBRA","sub":"Obra de reforma / instalação","valor":4200.0},{"tipo":"VENDA DE PEÇAS","sub":"Peças soldáveis","valor":4880.5}]' where id=189 and coalesce(servicos_itens,'')='[{"tipo":"OBRA","valor":4200},{"tipo":"PAGAMENTO PELO MATERIAL UTILIZADO","valor":4880.5}]';
update public.ordens_servico set servico='VENDA DE PEÇAS › Outras peças e materiais' where id=190 and coalesce(servico,'')='VENDAS DE MATERIAL';
update public.ordens_servico set servico='LAUDO › NR 11 – Movimentação e armazenagem' where id=191 and coalesce(servico,'')='NR 11';
update public.ordens_servico set servico='LAUDO › NR 11 – Movimentação e armazenagem' where id=192 and coalesce(servico,'')='NR 11';
update public.ordens_servico set servico='LAUDO › Acústico' where id=193 and coalesce(servico,'')='LAUDO TÉCNICO';
update public.ordens_servico set servico='LAUDO › NR 13 – Caldeiras, vasos de pressão e compressores' where id=194 and coalesce(servico,'')='LAUDO TÉCNICO';
update public.ordens_servico set servicos_itens='[{"tipo":"VENDA DE PEÇAS","sub":"Peças soldáveis","valor":850.0},{"tipo":"OBRA","sub":"Obra de reforma / instalação","valor":500.0}]' where id=195 and coalesce(servicos_itens,'')='[{"tipo":"PAGAMENTO PELO MATERIAL UTILIZADO","valor":850},{"tipo":"OBRA","valor":500}]';
update public.ordens_servico set servicos_itens='[{"tipo":"OBRA","sub":"Obra de reforma / instalação","valor":1200.0},{"tipo":"OUTRO","valor":478.4},{"tipo":"VENDA DE PEÇAS","sub":"Peças soldáveis","valor":6980.0}]' where id=196 and coalesce(servicos_itens,'')='[{"tipo":"OBRA","valor":1200},{"tipo":"OUTRO","valor":478.4},{"tipo":"PAGAMENTO PELO MATERIAL UTILIZADO","valor":6980}]';
update public.ordens_servico set servico='LAUDO › Arqueação de tanque' where id=198 and coalesce(servico,'')='Serviço de arqueação volumétrica de tanques e elaboração de tabelas de calibraçã';
update public.ordens_servico set servicos_itens='[{"tipo":"INSTALAÇÃO","sub":"Bomba","valor":300},{"tipo":"VENDA DE PEÇAS","sub":"Outras peças e materiais","valor":300}]' where id=199 and coalesce(servicos_itens,'')='[{"tipo":"OBRA","valor":300},{"tipo":"PAGAMENTO PELO MATERIAL UTILIZADO","valor":300}]';
update public.ordens_servico set servico='LAUDO › NR 13 – Caldeiras, vasos de pressão e compressores' where id=200 and coalesce(servico,'')='LAUDO TÉCNICO';
update public.ordens_servico set servico='LAUDO › NR 13 – Caldeiras, vasos de pressão e compressores' where id=201 and coalesce(servico,'')='LAUDO TÉCNICO';
update public.ordens_servico set servico='LAUDO › VOC / passivo ambiental' where id=202 and coalesce(servico,'')='LAUDO TÉCNICO';
update public.ordens_servico set servico='LAUDO › VOC / passivo ambiental' where id=203 and coalesce(servico,'')='LAUDO TÉCNICO';
update public.ordens_servico set servicos_itens='[{"tipo":"INSTALAÇÃO","sub":"Tanque","valor":1600},{"tipo":"LAUDO","sub":"Atestado de classe / conformidade","valor":2500},{"tipo":"VENDA DE PEÇAS","sub":"Outras peças e materiais","valor":4200}]' where id=204 and coalesce(servicos_itens,'')='';
update public.ordens_servico set servico='LAUDO › NR 11 – Movimentação e armazenagem' where id=206 and coalesce(servico,'')='LAUDO TÉCNICO';

-- 6) Auditoria: marca como 'OK' as divergências já decididas (parcelas classificadas pelo serviço
--    principal, ART embutida no valor da estanqueidade, e vínculos antigos de antes de junho)
insert into public.auditoria_ignorados (chave) select 'catUnica:1112' where not exists (select 1 from public.auditoria_ignorados where chave='catUnica:1112');
insert into public.auditoria_ignorados (chave) select 'catUnica:1078' where not exists (select 1 from public.auditoria_ignorados where chave='catUnica:1078');
insert into public.auditoria_ignorados (chave) select 'catUnica:1074' where not exists (select 1 from public.auditoria_ignorados where chave='catUnica:1074');
insert into public.auditoria_ignorados (chave) select 'catUnica:994' where not exists (select 1 from public.auditoria_ignorados where chave='catUnica:994');
insert into public.auditoria_ignorados (chave) select 'catUnica:1021' where not exists (select 1 from public.auditoria_ignorados where chave='catUnica:1021');
insert into public.auditoria_ignorados (chave) select 'catUnica:279' where not exists (select 1 from public.auditoria_ignorados where chave='catUnica:279');
insert into public.auditoria_ignorados (chave) select 'catUnica:170' where not exists (select 1 from public.auditoria_ignorados where chave='catUnica:170');
insert into public.auditoria_ignorados (chave) select 'catUnica:108' where not exists (select 1 from public.auditoria_ignorados where chave='catUnica:108');
insert into public.auditoria_ignorados (chave) select 'catUnica:303' where not exists (select 1 from public.auditoria_ignorados where chave='catUnica:303');
insert into public.auditoria_ignorados (chave) select 'catUnica:474' where not exists (select 1 from public.auditoria_ignorados where chave='catUnica:474');
insert into public.auditoria_ignorados (chave) select 'catUnica:989' where not exists (select 1 from public.auditoria_ignorados where chave='catUnica:989');
insert into public.auditoria_ignorados (chave) select 'catUnica:990' where not exists (select 1 from public.auditoria_ignorados where chave='catUnica:990');
insert into public.auditoria_ignorados (chave) select 'catUnica:922' where not exists (select 1 from public.auditoria_ignorados where chave='catUnica:922');

-- 7) Conferência: o total das receitas antigas (ids até 1146) deve dar 1.012.556,07
--    (1.012.559,57 do backup menos os R$ 3,50 do SICOOB, que viraram despesa)
select round(sum(valor)::numeric,2) as total_receitas, count(*) as linhas,
       count(*) filter (where subcategoria is not null) as com_subcategoria
from public.fluxo_caixa where tipo='RECEITA' and (id<=1146 or observacao like '%migração de categorias%');

commit;
