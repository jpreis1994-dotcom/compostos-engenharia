-- Migração: categorias e subcategorias de DESPESA (Compostos) — 13/11/2026
-- Lançamentos com classificação 'pendente' NÃO são alterados.
begin;
create table if not exists bkp_20261113b_fluxo_caixa as select * from public.fluxo_caixa;
create table if not exists bkp_20261113b_contas_pagar as select * from public.contas_pagar;
create table if not exists bkp_20261113b_cartao_itens as select * from public.cartao_itens;
alter table public.bkp_20261113b_fluxo_caixa enable row level security;
alter table public.bkp_20261113b_contas_pagar enable row level security;
alter table public.bkp_20261113b_cartao_itens enable row level security;
alter table public.contas_pagar add column if not exists subcategoria text;
alter table public.cartao_itens add column if not exists subcategoria text;
create table if not exists public.despesa_categorias (
  id bigint generated always as identity primary key,
  categoria text not null,
  subcategoria text,
  ativo boolean not null default true,
  ordem integer not null default 0,
  created_at timestamptz not null default now()
);
alter table public.despesa_categorias enable row level security;
drop policy if exists "Permitir tudo autenticado" on public.despesa_categorias;
create policy "Permitir tudo autenticado" on public.despesa_categorias for all to authenticated using (true) with check (true);
insert into public.despesa_categorias (categoria, subcategoria, ordem) select * from (values
  ('FUNCIONÁRIO', 'Wemerson', 10),
  ('FUNCIONÁRIO', 'Flávio', 20),
  ('FUNCIONÁRIO', 'João', 30),
  ('FUNCIONÁRIO', 'João Pedro', 40),
  ('FUNCIONÁRIO', 'Lucas', 50),
  ('FUNCIONÁRIO', 'Felipe', 60),
  ('FUNCIONÁRIO', 'Outros funcionários', 70),
  ('FUNCIONÁRIO', 'Avulso diarista', 80),
  ('FUNCIONÁRIO', 'Encargos e benefícios', 90),
  ('IMPOSTOS', NULL, 100),
  ('IMPOSTOS', 'Simples Nacional', 110),
  ('IMPOSTOS', 'INSS sobre pró-labore', 120),
  ('IMPOSTOS', 'Diferencial de alíquota (DIFAL)', 130),
  ('IMPOSTOS', 'Multas e juros', 140),
  ('CREA', 'ART', 150),
  ('CREA', 'Anuidade', 160),
  ('DESLOCAMENTO', 'Alimentação', 170),
  ('DESLOCAMENTO', 'Hospedagem', 180),
  ('VEÍCULOS', 'Combustível', 190),
  ('VEÍCULOS', 'Documento', 200),
  ('VEÍCULOS', 'Manutenção', 210),
  ('VEÍCULOS', 'Sem parar', 220),
  ('VEÍCULOS', 'Seguro', 230),
  ('VEÍCULOS', 'Financiamento', 240),
  ('ESTOQUE', 'Compra de peças estoque', 250),
  ('ESTOQUE', 'Compra de peças para revenda (direto)', 260),
  ('ESTOQUE', 'Material e insumos de obra', 270),
  ('TERCEIRIZAÇÃO DE MÃO DE OBRA', 'Empresa terceira', 280),
  ('TERCEIRIZAÇÃO DE MÃO DE OBRA', 'Profissional autônomo', 290),
  ('CERTIFICAÇÃO EMPRESA E EQUIPAMENTOS', 'Certificação empresa', 300),
  ('CERTIFICAÇÃO EMPRESA E EQUIPAMENTOS', 'Certificação equipamentos', 310),
  ('TARIFAS BANCÁRIAS', 'Taxa de boleto', 320),
  ('TARIFAS BANCÁRIAS', 'Custo de conta', 330),
  ('ROYALTES', 'Med e test', 340),
  ('ROYALTES', 'MCA Tecnologia', 350),
  ('FERRAMENTAS E EQUIPAMENTOS', 'Compra', 360),
  ('FERRAMENTAS E EQUIPAMENTOS', 'Aluguel', 370),
  ('FERRAMENTAS E EQUIPAMENTOS', 'Manutenção', 380),
  ('SERVIÇOS ADMINISTRATIVOS', 'Contabilidade', 390),
  ('SERVIÇOS ADMINISTRATIVOS', 'Consultoria financeira', 400),
  ('SERVIÇOS ADMINISTRATIVOS', 'Software e certificado digital', 410),
  ('SERVIÇOS ADMINISTRATIVOS', 'Aluguel de espaço', 420),
  ('COMERCIAL', 'Comissões pagas', 430),
  ('COMERCIAL', 'Marketing', 440),
  ('FRETE', NULL, 450),
  ('CARTÃO DE CRÉDITO', 'Fatura não detalhada', 460),
  ('OUTRAS DESPESAS', 'A identificar', 470),
  ('RETIRADAS (PROPRIETÁRIO)', NULL, 480)
) v(c,s,o) where not exists (select 1 from public.despesa_categorias);

-- Fluxo de caixa: despesas
update public.fluxo_caixa set categoria='IMPOSTOS', subcategoria=NULL where id=82 and tipo='DESPESA' and valor=66.44 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CARTÃO DE CRÉDITO', subcategoria='Fatura não detalhada' where id=83 and tipo='DESPESA' and valor=3585.01 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='João' where id=85 and tipo='DESPESA' and valor=84.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Lucas' where id=86 and tipo='DESPESA' and valor=6500.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CARTÃO DE CRÉDITO', subcategoria='Fatura não detalhada' where id=97 and tipo='DESPESA' and valor=5216.96 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='VEÍCULOS', subcategoria='Financiamento' where id=98 and tipo='DESPESA' and valor=1897.88 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='VEÍCULOS', subcategoria='Seguro' where id=99 and tipo='DESPESA' and valor=196.19 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='VEÍCULOS', subcategoria='Seguro' where id=100 and tipo='DESPESA' and valor=126.82 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Compra de peças para revenda (direto)' where id=102 and tipo='DESPESA' and valor=3123.94 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='SERVIÇOS ADMINISTRATIVOS', subcategoria='Contabilidade' where id=104 and tipo='DESPESA' and valor=421.06 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=106 and tipo='DESPESA' and valor=216.78 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ROYALTES', subcategoria='Med e test' where id=107 and tipo='DESPESA' and valor=3282.5 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Compra de peças para revenda (direto)' where id=110 and tipo='DESPESA' and valor=4000.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='IMPOSTOS', subcategoria=NULL where id=112 and tipo='DESPESA' and valor=508.16 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='IMPOSTOS', subcategoria=NULL where id=116 and tipo='DESPESA' and valor=145.92 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Compra de peças para revenda (direto)' where id=117 and tipo='DESPESA' and valor=1800.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='João' where id=118 and tipo='DESPESA' and valor=200.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=119 and tipo='DESPESA' and valor=108.39 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='IMPOSTOS', subcategoria=NULL where id=120 and tipo='DESPESA' and valor=2856.31 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Compra de peças para revenda (direto)' where id=122 and tipo='DESPESA' and valor=3185.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='IMPOSTOS', subcategoria=NULL where id=123 and tipo='DESPESA' and valor=104.13 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='IMPOSTOS', subcategoria=NULL where id=124 and tipo='DESPESA' and valor=167.51 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='IMPOSTOS', subcategoria=NULL where id=125 and tipo='DESPESA' and valor=174.47 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='IMPOSTOS', subcategoria=NULL where id=126 and tipo='DESPESA' and valor=63.31 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='IMPOSTOS', subcategoria=NULL where id=128 and tipo='DESPESA' and valor=177.79 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='João' where id=129 and tipo='DESPESA' and valor=1800.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Compra de peças para revenda (direto)' where id=130 and tipo='DESPESA' and valor=66.04 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Compra de peças para revenda (direto)' where id=131 and tipo='DESPESA' and valor=1140.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ROYALTES', subcategoria='Med e test' where id=132 and tipo='DESPESA' and valor=352.7 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CARTÃO DE CRÉDITO', subcategoria='Fatura não detalhada' where id=133 and tipo='DESPESA' and valor=60.44 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CARTÃO DE CRÉDITO', subcategoria='Fatura não detalhada' where id=134 and tipo='DESPESA' and valor=2619.44 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=137 and tipo='DESPESA' and valor=108.39 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Compra de peças para revenda (direto)' where id=141 and tipo='DESPESA' and valor=1500.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CARTÃO DE CRÉDITO', subcategoria='Fatura não detalhada' where id=142 and tipo='DESPESA' and valor=39.95 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Compra de peças estoque' where id=143 and tipo='DESPESA' and valor=700.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CARTÃO DE CRÉDITO', subcategoria='Fatura não detalhada' where id=144 and tipo='DESPESA' and valor=5450.63 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Lucas' where id=145 and tipo='DESPESA' and valor=1800.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=146 and tipo='DESPESA' and valor=108.39 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='VEÍCULOS', subcategoria='Financiamento' where id=150 and tipo='DESPESA' and valor=1880.62 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Lucas' where id=152 and tipo='DESPESA' and valor=5800.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='SERVIÇOS ADMINISTRATIVOS', subcategoria='Contabilidade' where id=153 and tipo='DESPESA' and valor=462.83 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=156 and tipo='DESPESA' and valor=108.39 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=158 and tipo='DESPESA' and valor=1500.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=159 and tipo='DESPESA' and valor=1050.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ROYALTES', subcategoria='Med e test' where id=161 and tipo='DESPESA' and valor=577.72 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='João' where id=162 and tipo='DESPESA' and valor=150.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=163 and tipo='DESPESA' and valor=450.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CARTÃO DE CRÉDITO', subcategoria='Fatura não detalhada' where id=164 and tipo='DESPESA' and valor=1263.51 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=165 and tipo='DESPESA' and valor=108.39 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Compra de peças para revenda (direto)' where id=167 and tipo='DESPESA' and valor=554.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=169 and tipo='DESPESA' and valor=100.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=171 and tipo='DESPESA' and valor=108.39 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='IMPOSTOS', subcategoria=NULL where id=172 and tipo='DESPESA' and valor=161.66 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=173 and tipo='DESPESA' and valor=900.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=174 and tipo='DESPESA' and valor=108.39 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=179 and tipo='DESPESA' and valor=1550.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=180 and tipo='DESPESA' and valor=500.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='João' where id=181 and tipo='DESPESA' and valor=350.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=185 and tipo='DESPESA' and valor=108.39 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CARTÃO DE CRÉDITO', subcategoria='Fatura não detalhada' where id=186 and tipo='DESPESA' and valor=3630.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=188 and tipo='DESPESA' and valor=108.39 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Material e insumos de obra' where id=189 and tipo='DESPESA' and valor=28.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='João' where id=191 and tipo='DESPESA' and valor=1500.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='SERVIÇOS ADMINISTRATIVOS', subcategoria='Contabilidade' where id=193 and tipo='DESPESA' and valor=435.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=194 and tipo='DESPESA' and valor=1075.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='IMPOSTOS', subcategoria='Multas e juros' where id=196 and tipo='DESPESA' and valor=156.18 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='VEÍCULOS', subcategoria='Seguro' where id=197 and tipo='DESPESA' and valor=126.82 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Lucas' where id=198 and tipo='DESPESA' and valor=6500.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='VEÍCULOS', subcategoria='Financiamento' where id=199 and tipo='DESPESA' and valor=1863.35 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CARTÃO DE CRÉDITO', subcategoria='Fatura não detalhada' where id=202 and tipo='DESPESA' and valor=6136.85 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='VEÍCULOS', subcategoria='Seguro' where id=203 and tipo='DESPESA' and valor=196.19 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=206 and tipo='DESPESA' and valor=1000.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='João' where id=207 and tipo='DESPESA' and valor=200.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='João' where id=208 and tipo='DESPESA' and valor=5461.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='João' where id=209 and tipo='DESPESA' and valor=1039.78 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='João' where id=211 and tipo='DESPESA' and valor=777.78 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=212 and tipo='DESPESA' and valor=108.39 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ROYALTES', subcategoria='Med e test' where id=213 and tipo='DESPESA' and valor=4516.72 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=216 and tipo='DESPESA' and valor=130.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CARTÃO DE CRÉDITO', subcategoria='Fatura não detalhada' where id=220 and tipo='DESPESA' and valor=100.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=222 and tipo='DESPESA' and valor=650.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='IMPOSTOS', subcategoria='Multas e juros' where id=223 and tipo='DESPESA' and valor=104.13 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=225 and tipo='DESPESA' and valor=541.95 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Compra de peças para revenda (direto)' where id=227 and tipo='DESPESA' and valor=1600.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=229 and tipo='DESPESA' and valor=390.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Compra de peças para revenda (direto)' where id=230 and tipo='DESPESA' and valor=95.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=231 and tipo='DESPESA' and valor=117.42 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CARTÃO DE CRÉDITO', subcategoria='Fatura não detalhada' where id=232 and tipo='DESPESA' and valor=5330.71 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FERRAMENTAS E EQUIPAMENTOS', subcategoria='Aluguel' where id=233 and tipo='DESPESA' and valor=8766.5 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=234 and tipo='DESPESA' and valor=4300.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Compra de peças para revenda (direto)' where id=235 and tipo='DESPESA' and valor=13237.09 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=236 and tipo='DESPESA' and valor=260.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Lucas' where id=237 and tipo='DESPESA' and valor=6500.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=238 and tipo='DESPESA' and valor=1100.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FERRAMENTAS E EQUIPAMENTOS', subcategoria='Compra' where id=239 and tipo='DESPESA' and valor=497.5 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='VEÍCULOS', subcategoria='Financiamento' where id=242 and tipo='DESPESA' and valor=1846.08 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Material e insumos de obra' where id=244 and tipo='DESPESA' and valor=1000.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=246 and tipo='DESPESA' and valor=216.78 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=248 and tipo='DESPESA' and valor=850.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CARTÃO DE CRÉDITO', subcategoria='Fatura não detalhada' where id=249 and tipo='DESPESA' and valor=100.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='VEÍCULOS', subcategoria='Seguro' where id=250 and tipo='DESPESA' and valor=219.73 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=251 and tipo='DESPESA' and valor=390.35 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=254 and tipo='DESPESA' and valor=300.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=255 and tipo='DESPESA' and valor=108.39 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=256 and tipo='DESPESA' and valor=799.62 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=259 and tipo='DESPESA' and valor=150.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=260 and tipo='DESPESA' and valor=360.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Compra de peças para revenda (direto)' where id=261 and tipo='DESPESA' and valor=3000.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=263 and tipo='DESPESA' and valor=108.39 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='IMPOSTOS', subcategoria=NULL where id=264 and tipo='DESPESA' and valor=47.76 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='IMPOSTOS', subcategoria=NULL where id=265 and tipo='DESPESA' and valor=247.75 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='SERVIÇOS ADMINISTRATIVOS', subcategoria='Contabilidade' where id=266 and tipo='DESPESA' and valor=468.05 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=267 and tipo='DESPESA' and valor=325.17 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Encargos e benefícios' where id=272 and tipo='DESPESA' and valor=100.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=270 and tipo='DESPESA' and valor=117.42 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FERRAMENTAS E EQUIPAMENTOS', subcategoria='Compra' where id=271 and tipo='DESPESA' and valor=2361.54 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Compra de peças para revenda (direto)' where id=276 and tipo='DESPESA' and valor=3180.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=277 and tipo='DESPESA' and valor=108.39 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Compra de peças para revenda (direto)' where id=278 and tipo='DESPESA' and valor=1228.8 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=280 and tipo='DESPESA' and valor=108.39 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Lucas' where id=281 and tipo='DESPESA' and valor=6500.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Outros funcionários' where id=282 and tipo='DESPESA' and valor=1450.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CARTÃO DE CRÉDITO', subcategoria='Fatura não detalhada' where id=283 and tipo='DESPESA' and valor=7206.37 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Compra de peças para revenda (direto)' where id=285 and tipo='DESPESA' and valor=2142.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Compra de peças para revenda (direto)' where id=286 and tipo='DESPESA' and valor=1856.93 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Compra de peças para revenda (direto)' where id=287 and tipo='DESPESA' and valor=408.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='VEÍCULOS', subcategoria='Sem parar' where id=288 and tipo='DESPESA' and valor=253.13 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='IMPOSTOS', subcategoria=NULL where id=290 and tipo='DESPESA' and valor=1489.78 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='IMPOSTOS', subcategoria=NULL where id=291 and tipo='DESPESA' and valor=4069.88 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='SERVIÇOS ADMINISTRATIVOS', subcategoria='Contabilidade' where id=293 and tipo='DESPESA' and valor=461.96 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='VEÍCULOS', subcategoria='Financiamento' where id=295 and tipo='DESPESA' and valor=1828.82 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=296 and tipo='DESPESA' and valor=108.39 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=297 and tipo='DESPESA' and valor=130.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Compra de peças para revenda (direto)' where id=299 and tipo='DESPESA' and valor=12426.18 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=304 and tipo='DESPESA' and valor=450.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=306 and tipo='DESPESA' and valor=650.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Outros funcionários' where id=307 and tipo='DESPESA' and valor=150.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=309 and tipo='DESPESA' and valor=960.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ROYALTES', subcategoria='Med e test' where id=310 and tipo='DESPESA' and valor=472.68 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='IMPOSTOS', subcategoria=NULL where id=312 and tipo='DESPESA' and valor=2659.31 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Compra de peças para revenda (direto)' where id=314 and tipo='DESPESA' and valor=1640.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=315 and tipo='DESPESA' and valor=600.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Outros funcionários' where id=316 and tipo='DESPESA' and valor=100.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=317 and tipo='DESPESA' and valor=650.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=318 and tipo='DESPESA' and valor=700.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FRETE', subcategoria=NULL where id=325 and tipo='DESPESA' and valor=140.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Material e insumos de obra' where id=327 and tipo='DESPESA' and valor=899.99 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Material e insumos de obra' where id=328 and tipo='DESPESA' and valor=810.91 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='IMPOSTOS', subcategoria='Diferencial de alíquota (DIFAL)' where id=332 and tipo='DESPESA' and valor=9438.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=334 and tipo='DESPESA' and valor=600.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TERCEIRIZAÇÃO DE MÃO DE OBRA', subcategoria='Profissional autônomo' where id=335 and tipo='DESPESA' and valor=800.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Material e insumos de obra' where id=336 and tipo='DESPESA' and valor=820.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Material e insumos de obra' where id=337 and tipo='DESPESA' and valor=164.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Material e insumos de obra' where id=338 and tipo='DESPESA' and valor=150.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='COMERCIAL', subcategoria='Marketing' where id=339 and tipo='DESPESA' and valor=278.91 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Outros funcionários' where id=340 and tipo='DESPESA' and valor=1750.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CARTÃO DE CRÉDITO', subcategoria='Fatura não detalhada' where id=342 and tipo='DESPESA' and valor=2206.16 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='SERVIÇOS ADMINISTRATIVOS', subcategoria='Software e certificado digital' where id=343 and tipo='DESPESA' and valor=118.4 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Lucas' where id=344 and tipo='DESPESA' and valor=6500.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='Anuidade' where id=345 and tipo='DESPESA' and valor=117.42 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=346 and tipo='DESPESA' and valor=108.39 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='João Pedro' where id=347 and tipo='DESPESA' and valor=700.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='SERVIÇOS ADMINISTRATIVOS', subcategoria='Aluguel de espaço' where id=348 and tipo='DESPESA' and valor=300.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FERRAMENTAS E EQUIPAMENTOS', subcategoria='Manutenção' where id=350 and tipo='DESPESA' and valor=905.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='VEÍCULOS', subcategoria='Financiamento' where id=351 and tipo='DESPESA' and valor=1811.55 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Compra de peças para revenda (direto)' where id=352 and tipo='DESPESA' and valor=1150.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='VEÍCULOS', subcategoria='Sem parar' where id=353 and tipo='DESPESA' and valor=250.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=354 and tipo='DESPESA' and valor=108.39 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CERTIFICAÇÃO EMPRESA E EQUIPAMENTOS', subcategoria='Certificação empresa' where id=356 and tipo='DESPESA' and valor=1000.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CERTIFICAÇÃO EMPRESA E EQUIPAMENTOS', subcategoria='Certificação empresa' where id=357 and tipo='DESPESA' and valor=1000.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FERRAMENTAS E EQUIPAMENTOS', subcategoria='Compra' where id=358 and tipo='DESPESA' and valor=470.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=349 and tipo='DESPESA' and valor=520.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Compra de peças para revenda (direto)' where id=359 and tipo='DESPESA' and valor=12426.18 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=360 and tipo='DESPESA' and valor=108.39 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Taxa de boleto' where id=361 and tipo='DESPESA' and valor=6.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=365 and tipo='DESPESA' and valor=108.39 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Taxa de boleto' where id=366 and tipo='DESPESA' and valor=0.5 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=369 and tipo='DESPESA' and valor=108.39 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Flávio' where id=396 and tipo='DESPESA' and valor=150.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='DESLOCAMENTO', subcategoria='Alimentação' where id=376 and tipo='DESPESA' and valor=180.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Outros funcionários' where id=377 and tipo='DESPESA' and valor=800.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=378 and tipo='DESPESA' and valor=108.39 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Taxa de boleto' where id=382 and tipo='DESPESA' and valor=14.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Lucas' where id=386 and tipo='DESPESA' and valor=250.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FRETE', subcategoria=NULL where id=387 and tipo='DESPESA' and valor=544.34 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='OUTRAS DESPESAS', subcategoria='A identificar' where id=388 and tipo='DESPESA' and valor=35.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=389 and tipo='DESPESA' and valor=108.39 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=390 and tipo='DESPESA' and valor=108.39 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Flávio' where id=394 and tipo='DESPESA' and valor=100.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='IMPOSTOS', subcategoria='Simples Nacional' where id=381 and tipo='DESPESA' and valor=281.36 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Compra de peças para revenda (direto)' where id=392 and tipo='DESPESA' and valor=810.91 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Flávio' where id=393 and tipo='DESPESA' and valor=560.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Flávio' where id=395 and tipo='DESPESA' and valor=20.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=397 and tipo='DESPESA' and valor=150.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=399 and tipo='DESPESA' and valor=108.39 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=400 and tipo='DESPESA' and valor=50.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=401 and tipo='DESPESA' and valor=462.33 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=402 and tipo='DESPESA' and valor=366.46 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=403 and tipo='DESPESA' and valor=265.44 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ROYALTES', subcategoria='MCA Tecnologia' where id=404 and tipo='DESPESA' and valor=1974.36 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Compra de peças para revenda (direto)' where id=408 and tipo='DESPESA' and valor=12000.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='IMPOSTOS', subcategoria='Diferencial de alíquota (DIFAL)' where id=409 and tipo='DESPESA' and valor=1250.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=410 and tipo='DESPESA' and valor=2500.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Compra de peças para revenda (direto)' where id=412 and tipo='DESPESA' and valor=974.09 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=413 and tipo='DESPESA' and valor=2307.75 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Compra de peças para revenda (direto)' where id=414 and tipo='DESPESA' and valor=1310.1 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Material e insumos de obra' where id=415 and tipo='DESPESA' and valor=655.05 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=416 and tipo='DESPESA' and valor=130.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Custo de conta' where id=417 and tipo='DESPESA' and valor=60.44 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Custo de conta' where id=419 and tipo='DESPESA' and valor=3.7 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=421 and tipo='DESPESA' and valor=380.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Taxa de boleto' where id=423 and tipo='DESPESA' and valor=3.5 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FERRAMENTAS E EQUIPAMENTOS', subcategoria='Compra' where id=424 and tipo='DESPESA' and valor=2377.06 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Compra de peças para revenda (direto)' where id=425 and tipo='DESPESA' and valor=4102.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Compra de peças para revenda (direto)' where id=426 and tipo='DESPESA' and valor=779.39 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Flávio' where id=427 and tipo='DESPESA' and valor=520.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=428 and tipo='DESPESA' and valor=150.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='Anuidade' where id=430 and tipo='DESPESA' and valor=117.42 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Material e insumos de obra' where id=431 and tipo='DESPESA' and valor=3180.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CARTÃO DE CRÉDITO', subcategoria='Fatura não detalhada' where id=432 and tipo='DESPESA' and valor=5234.15 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=433 and tipo='DESPESA' and valor=180.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=434 and tipo='DESPESA' and valor=93.24 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=435 and tipo='DESPESA' and valor=108.39 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Lucas' where id=438 and tipo='DESPESA' and valor=6000.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=440 and tipo='DESPESA' and valor=2314.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Flávio' where id=442 and tipo='DESPESA' and valor=50.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=443 and tipo='DESPESA' and valor=50.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='João Pedro' where id=444 and tipo='DESPESA' and valor=700.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='SERVIÇOS ADMINISTRATIVOS', subcategoria='Software e certificado digital' where id=445 and tipo='DESPESA' and valor=140.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='SERVIÇOS ADMINISTRATIVOS', subcategoria='Contabilidade' where id=450 and tipo='DESPESA' and valor=461.67 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Taxa de boleto' where id=451 and tipo='DESPESA' and valor=1.75 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Compra de peças para revenda (direto)' where id=452 and tipo='DESPESA' and valor=13898.3 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Compra de peças para revenda (direto)' where id=453 and tipo='DESPESA' and valor=8326.7 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=454 and tipo='DESPESA' and valor=108.39 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=455 and tipo='DESPESA' and valor=985.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Taxa de boleto' where id=456 and tipo='DESPESA' and valor=1.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TERCEIRIZAÇÃO DE MÃO DE OBRA', subcategoria='Profissional autônomo' where id=457 and tipo='DESPESA' and valor=1500.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TERCEIRIZAÇÃO DE MÃO DE OBRA', subcategoria='Profissional autônomo' where id=458 and tipo='DESPESA' and valor=250.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=459 and tipo='DESPESA' and valor=743.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='VEÍCULOS', subcategoria='Financiamento' where id=460 and tipo='DESPESA' and valor=1794.28 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=461 and tipo='DESPESA' and valor=150.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Flávio' where id=462 and tipo='DESPESA' and valor=650.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Material e insumos de obra' where id=463 and tipo='DESPESA' and valor=500.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Taxa de boleto' where id=467 and tipo='DESPESA' and valor=3.5 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Material e insumos de obra' where id=468 and tipo='DESPESA' and valor=12426.18 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CARTÃO DE CRÉDITO', subcategoria='Fatura não detalhada' where id=469 and tipo='DESPESA' and valor=3032.03 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Flávio' where id=470 and tipo='DESPESA' and valor=80.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=472 and tipo='DESPESA' and valor=10.6 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Taxa de boleto' where id=477 and tipo='DESPESA' and valor=5.25 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Flávio' where id=478 and tipo='DESPESA' and valor=30.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=479 and tipo='DESPESA' and valor=8000.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ROYALTES', subcategoria='MCA Tecnologia' where id=481 and tipo='DESPESA' and valor=971.62 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Material e insumos de obra' where id=483 and tipo='DESPESA' and valor=960.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=484 and tipo='DESPESA' and valor=108.39 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=485 and tipo='DESPESA' and valor=108.39 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Flávio' where id=486 and tipo='DESPESA' and valor=70.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=487 and tipo='DESPESA' and valor=108.39 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=491 and tipo='DESPESA' and valor=900.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Flávio' where id=493 and tipo='DESPESA' and valor=400.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='IMPOSTOS', subcategoria='Simples Nacional' where id=494 and tipo='DESPESA' and valor=8202.22 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=495 and tipo='DESPESA' and valor=150.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=496 and tipo='DESPESA' and valor=500.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=497 and tipo='DESPESA' and valor=100.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Felipe' where id=499 and tipo='DESPESA' and valor=375.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=500 and tipo='DESPESA' and valor=232.05 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=501 and tipo='DESPESA' and valor=678.58 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=502 and tipo='DESPESA' and valor=1347.7 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=503 and tipo='DESPESA' and valor=108.39 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TERCEIRIZAÇÃO DE MÃO DE OBRA', subcategoria='Profissional autônomo' where id=515 and tipo='DESPESA' and valor=650.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Flávio' where id=518 and tipo='DESPESA' and valor=100.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=519 and tipo='DESPESA' and valor=500.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=520 and tipo='DESPESA' and valor=541.95 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=521 and tipo='DESPESA' and valor=238.18 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=522 and tipo='DESPESA' and valor=43.35 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Compra de peças para revenda (direto)' where id=523 and tipo='DESPESA' and valor=3184.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Flávio' where id=524 and tipo='DESPESA' and valor=50.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Taxa de boleto' where id=526 and tipo='DESPESA' and valor=3.5 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FRETE', subcategoria=NULL where id=527 and tipo='DESPESA' and valor=40.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=530 and tipo='DESPESA' and valor=108.39 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=531 and tipo='DESPESA' and valor=108.39 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Flávio' where id=532 and tipo='DESPESA' and valor=370.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Taxa de boleto' where id=534 and tipo='DESPESA' and valor=3.5 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Compra de peças para revenda (direto)' where id=535 and tipo='DESPESA' and valor=810.91 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=536 and tipo='DESPESA' and valor=962.5 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=537 and tipo='DESPESA' and valor=50.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=538 and tipo='DESPESA' and valor=108.39 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Compra de peças para revenda (direto)' where id=569 and tipo='DESPESA' and valor=250.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=571 and tipo='DESPESA' and valor=2250.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=599 and tipo='DESPESA' and valor=150.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='DESLOCAMENTO', subcategoria='Alimentação' where id=600 and tipo='DESPESA' and valor=89.9 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=601 and tipo='DESPESA' and valor=150.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Flávio' where id=609 and tipo='DESPESA' and valor=260.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=610 and tipo='DESPESA' and valor=108.39 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Taxa de boleto' where id=613 and tipo='DESPESA' and valor=3.5 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Flávio' where id=618 and tipo='DESPESA' and valor=50.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=619 and tipo='DESPESA' and valor=330.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Taxa de boleto' where id=622 and tipo='DESPESA' and valor=7.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Felipe' where id=623 and tipo='DESPESA' and valor=150.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=624 and tipo='DESPESA' and valor=1000.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=625 and tipo='DESPESA' and valor=1500.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Flávio' where id=627 and tipo='DESPESA' and valor=340.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=628 and tipo='DESPESA' and valor=450.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Taxa de boleto' where id=629 and tipo='DESPESA' and valor=0.8 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Taxa de boleto' where id=631 and tipo='DESPESA' and valor=0.14 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CARTÃO DE CRÉDITO', subcategoria='Fatura não detalhada' where id=632 and tipo='DESPESA' and valor=2253.78 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Compra de peças para revenda (direto)' where id=633 and tipo='DESPESA' and valor=173.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='DESLOCAMENTO', subcategoria='Alimentação' where id=634 and tipo='DESPESA' and valor=119.6 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FRETE', subcategoria=NULL where id=635 and tipo='DESPESA' and valor=300.72 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=636 and tipo='DESPESA' and valor=108.39 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Custo de conta' where id=637 and tipo='DESPESA' and valor=60.44 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='Anuidade' where id=638 and tipo='DESPESA' and valor=117.42 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Material e insumos de obra' where id=639 and tipo='DESPESA' and valor=1080.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='VEÍCULOS', subcategoria='Manutenção' where id=642 and tipo='DESPESA' and valor=500.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TERCEIRIZAÇÃO DE MÃO DE OBRA', subcategoria='Profissional autônomo' where id=652 and tipo='DESPESA' and valor=560.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=653 and tipo='DESPESA' and valor=211.19 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='VEÍCULOS', subcategoria='Combustível' where id=657 and tipo='DESPESA' and valor=547.04 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='DESLOCAMENTO', subcategoria='Alimentação' where id=658 and tipo='DESPESA' and valor=180.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='VEÍCULOS', subcategoria='Combustível' where id=659 and tipo='DESPESA' and valor=200.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='OUTRAS DESPESAS', subcategoria='A identificar' where id=660 and tipo='DESPESA' and valor=8.5 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='DESLOCAMENTO', subcategoria='Alimentação' where id=661 and tipo='DESPESA' and valor=30.36 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='DESLOCAMENTO', subcategoria='Alimentação' where id=662 and tipo='DESPESA' and valor=25.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='VEÍCULOS', subcategoria='Combustível' where id=663 and tipo='DESPESA' and valor=329.98 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='DESLOCAMENTO', subcategoria='Hospedagem' where id=664 and tipo='DESPESA' and valor=110.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='DESLOCAMENTO', subcategoria='Alimentação' where id=665 and tipo='DESPESA' and valor=30.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='VEÍCULOS', subcategoria='Combustível' where id=666 and tipo='DESPESA' and valor=61.98 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='DESLOCAMENTO', subcategoria='Alimentação' where id=667 and tipo='DESPESA' and valor=14.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='OUTRAS DESPESAS', subcategoria='A identificar' where id=668 and tipo='DESPESA' and valor=18.9 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='VEÍCULOS', subcategoria='Combustível' where id=669 and tipo='DESPESA' and valor=14.99 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='OUTRAS DESPESAS', subcategoria='A identificar' where id=670 and tipo='DESPESA' and valor=20.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='OUTRAS DESPESAS', subcategoria='A identificar' where id=671 and tipo='DESPESA' and valor=12.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='DESLOCAMENTO', subcategoria='Alimentação' where id=672 and tipo='DESPESA' and valor=19.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='DESLOCAMENTO', subcategoria='Alimentação' where id=673 and tipo='DESPESA' and valor=7.5 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='VEÍCULOS', subcategoria='Combustível' where id=674 and tipo='DESPESA' and valor=211.18 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='VEÍCULOS', subcategoria='Combustível' where id=675 and tipo='DESPESA' and valor=526.82 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='DESLOCAMENTO', subcategoria='Alimentação' where id=676 and tipo='DESPESA' and valor=37.34 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='DESLOCAMENTO', subcategoria='Alimentação' where id=677 and tipo='DESPESA' and valor=200.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='OUTRAS DESPESAS', subcategoria='A identificar' where id=678 and tipo='DESPESA' and valor=14.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Material e insumos de obra' where id=679 and tipo='DESPESA' and valor=8.9 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='DESLOCAMENTO', subcategoria='Alimentação' where id=680 and tipo='DESPESA' and valor=60.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='VEÍCULOS', subcategoria='Combustível' where id=681 and tipo='DESPESA' and valor=287.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='VEÍCULOS', subcategoria='Combustível' where id=682 and tipo='DESPESA' and valor=100.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='OUTRAS DESPESAS', subcategoria='A identificar' where id=683 and tipo='DESPESA' and valor=130.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='DESLOCAMENTO', subcategoria='Alimentação' where id=684 and tipo='DESPESA' and valor=58.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='DESLOCAMENTO', subcategoria='Alimentação' where id=685 and tipo='DESPESA' and valor=22.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='DESLOCAMENTO', subcategoria='Alimentação' where id=686 and tipo='DESPESA' and valor=34.21 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='OUTRAS DESPESAS', subcategoria='A identificar' where id=687 and tipo='DESPESA' and valor=60.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='DESLOCAMENTO', subcategoria='Alimentação' where id=688 and tipo='DESPESA' and valor=72.8 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='DESLOCAMENTO', subcategoria='Alimentação' where id=689 and tipo='DESPESA' and valor=65.75 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='OUTRAS DESPESAS', subcategoria='A identificar' where id=690 and tipo='DESPESA' and valor=19.8 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Material e insumos de obra' where id=691 and tipo='DESPESA' and valor=11.9 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='OUTRAS DESPESAS', subcategoria='A identificar' where id=692 and tipo='DESPESA' and valor=72.5 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='VEÍCULOS', subcategoria='Combustível' where id=693 and tipo='DESPESA' and valor=512.88 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='DESLOCAMENTO', subcategoria='Alimentação' where id=694 and tipo='DESPESA' and valor=22.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='DESLOCAMENTO', subcategoria='Alimentação' where id=695 and tipo='DESPESA' and valor=38.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='VEÍCULOS', subcategoria='Combustível' where id=696 and tipo='DESPESA' and valor=336.22 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='OUTRAS DESPESAS', subcategoria='A identificar' where id=697 and tipo='DESPESA' and valor=23.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='DESLOCAMENTO', subcategoria='Alimentação' where id=698 and tipo='DESPESA' and valor=75.8 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='DESLOCAMENTO', subcategoria='Alimentação' where id=699 and tipo='DESPESA' and valor=97.53 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='OUTRAS DESPESAS', subcategoria='A identificar' where id=700 and tipo='DESPESA' and valor=50.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='DESLOCAMENTO', subcategoria='Alimentação' where id=701 and tipo='DESPESA' and valor=17.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='VEÍCULOS', subcategoria='Combustível' where id=702 and tipo='DESPESA' and valor=100.02 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='DESLOCAMENTO', subcategoria='Alimentação' where id=703 and tipo='DESPESA' and valor=31.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='DESLOCAMENTO', subcategoria='Alimentação' where id=704 and tipo='DESPESA' and valor=57.99 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='OUTRAS DESPESAS', subcategoria='A identificar' where id=705 and tipo='DESPESA' and valor=89.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='VEÍCULOS', subcategoria='Combustível' where id=706 and tipo='DESPESA' and valor=263.03 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='VEÍCULOS', subcategoria='Combustível' where id=707 and tipo='DESPESA' and valor=100.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='DESLOCAMENTO', subcategoria='Alimentação' where id=708 and tipo='DESPESA' and valor=65.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='VEÍCULOS', subcategoria='Combustível' where id=709 and tipo='DESPESA' and valor=489.37 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='DESLOCAMENTO', subcategoria='Alimentação' where id=710 and tipo='DESPESA' and valor=26.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='DESLOCAMENTO', subcategoria='Alimentação' where id=711 and tipo='DESPESA' and valor=27.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='DESLOCAMENTO', subcategoria='Alimentação' where id=712 and tipo='DESPESA' and valor=46.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='DESLOCAMENTO', subcategoria='Alimentação' where id=713 and tipo='DESPESA' and valor=39.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='DESLOCAMENTO', subcategoria='Alimentação' where id=714 and tipo='DESPESA' and valor=45.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='DESLOCAMENTO', subcategoria='Alimentação' where id=715 and tipo='DESPESA' and valor=22.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='VEÍCULOS', subcategoria='Combustível' where id=716 and tipo='DESPESA' and valor=459.18 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='DESLOCAMENTO', subcategoria='Alimentação' where id=717 and tipo='DESPESA' and valor=36.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='OUTRAS DESPESAS', subcategoria='A identificar' where id=718 and tipo='DESPESA' and valor=100.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='OUTRAS DESPESAS', subcategoria='A identificar' where id=719 and tipo='DESPESA' and valor=16.33 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='DESLOCAMENTO', subcategoria='Alimentação' where id=720 and tipo='DESPESA' and valor=33.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='DESLOCAMENTO', subcategoria='Alimentação' where id=721 and tipo='DESPESA' and valor=12.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='DESLOCAMENTO', subcategoria='Alimentação' where id=722 and tipo='DESPESA' and valor=43.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='DESLOCAMENTO', subcategoria='Alimentação' where id=723 and tipo='DESPESA' and valor=79.8 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='VEÍCULOS', subcategoria='Combustível' where id=724 and tipo='DESPESA' and valor=301.05 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='DESLOCAMENTO', subcategoria='Alimentação' where id=725 and tipo='DESPESA' and valor=24.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='OUTRAS DESPESAS', subcategoria='A identificar' where id=726 and tipo='DESPESA' and valor=260.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Lucas' where id=727 and tipo='DESPESA' and valor=6000.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Flávio' where id=630 and tipo='DESPESA' and valor=300.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=729 and tipo='DESPESA' and valor=750.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=730 and tipo='DESPESA' and valor=280.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=731 and tipo='DESPESA' and valor=260.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=732 and tipo='DESPESA' and valor=1200.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=733 and tipo='DESPESA' and valor=1500.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=734 and tipo='DESPESA' and valor=750.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='João Pedro' where id=735 and tipo='DESPESA' and valor=700.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=736 and tipo='DESPESA' and valor=400.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=737 and tipo='DESPESA' and valor=450.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='VEÍCULOS', subcategoria='Financiamento' where id=738 and tipo='DESPESA' and valor=1777.02 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=739 and tipo='DESPESA' and valor=234.91 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=740 and tipo='DESPESA' and valor=108.39 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=743 and tipo='DESPESA' and valor=50.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=746 and tipo='DESPESA' and valor=108.39 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Taxa de boleto' where id=748 and tipo='DESPESA' and valor=3.5 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='SERVIÇOS ADMINISTRATIVOS', subcategoria='Contabilidade' where id=749 and tipo='DESPESA' and valor=462.55 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Material e insumos de obra' where id=750 and tipo='DESPESA' and valor=12426.2 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=751 and tipo='DESPESA' and valor=1850.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=752 and tipo='DESPESA' and valor=141.02 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=753 and tipo='DESPESA' and valor=128.04 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=754 and tipo='DESPESA' and valor=183.65 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=758 and tipo='DESPESA' and valor=4214.97 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=759 and tipo='DESPESA' and valor=5005.67 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Flávio' where id=760 and tipo='DESPESA' and valor=50.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Taxa de boleto' where id=762 and tipo='DESPESA' and valor=1.75 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Compra de peças para revenda (direto)' where id=763 and tipo='DESPESA' and valor=480.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=765 and tipo='DESPESA' and valor=151.73 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=768 and tipo='DESPESA' and valor=500.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Material e insumos de obra' where id=769 and tipo='DESPESA' and valor=575.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TERCEIRIZAÇÃO DE MÃO DE OBRA', subcategoria='Profissional autônomo' where id=771 and tipo='DESPESA' and valor=500.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TERCEIRIZAÇÃO DE MÃO DE OBRA', subcategoria='Profissional autônomo' where id=776 and tipo='DESPESA' and valor=30750.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=777 and tipo='DESPESA' and valor=520.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=778 and tipo='DESPESA' and valor=1400.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=779 and tipo='DESPESA' and valor=1500.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Flávio' where id=780 and tipo='DESPESA' and valor=660.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=781 and tipo='DESPESA' and valor=150.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=783 and tipo='DESPESA' and valor=30000.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=784 and tipo='DESPESA' and valor=150.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ROYALTES', subcategoria='MCA Tecnologia' where id=785 and tipo='DESPESA' and valor=6433.7 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Flávio' where id=786 and tipo='DESPESA' and valor=50.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='VEÍCULOS', subcategoria='Sem parar' where id=787 and tipo='DESPESA' and valor=250.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=788 and tipo='DESPESA' and valor=250.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=789 and tipo='DESPESA' and valor=155.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=790 and tipo='DESPESA' and valor=108.39 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='IMPOSTOS', subcategoria='Simples Nacional' where id=791 and tipo='DESPESA' and valor=7392.88 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='IMPOSTOS', subcategoria='Simples Nacional' where id=794 and tipo='DESPESA' and valor=-7392.88 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Taxa de boleto' where id=796 and tipo='DESPESA' and valor=3.5 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Taxa de boleto' where id=826 and tipo='DESPESA' and valor=4.72 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=797 and tipo='DESPESA' and valor=750.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Flávio' where id=798 and tipo='DESPESA' and valor=650.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Wemerson' where id=799 and tipo='DESPESA' and valor=260.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=805 and tipo='DESPESA' and valor=130.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Wemerson' where id=806 and tipo='DESPESA' and valor=130.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Flávio' where id=807 and tipo='DESPESA' and valor=130.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='DESLOCAMENTO', subcategoria='Alimentação' where id=808 and tipo='DESPESA' and valor=20.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=809 and tipo='DESPESA' and valor=240.72 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Flávio' where id=810 and tipo='DESPESA' and valor=80.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=811 and tipo='DESPESA' and valor=216.78 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Lucas' where id=813 and tipo='DESPESA' and valor=400.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FERRAMENTAS E EQUIPAMENTOS', subcategoria='Manutenção' where id=814 and tipo='DESPESA' and valor=80.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=818 and tipo='DESPESA' and valor=216.78 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Taxa de boleto' where id=819 and tipo='DESPESA' and valor=59.9 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Taxa de boleto' where id=820 and tipo='DESPESA' and valor=2.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Material e insumos de obra' where id=821 and tipo='DESPESA' and valor=810.89 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Taxa de boleto' where id=825 and tipo='DESPESA' and valor=7.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=827 and tipo='DESPESA' and valor=90.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=830 and tipo='DESPESA' and valor=50.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Taxa de boleto' where id=831 and tipo='DESPESA' and valor=2.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Felipe' where id=832 and tipo='DESPESA' and valor=85.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Wemerson' where id=836 and tipo='DESPESA' and valor=100.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Flávio' where id=838 and tipo='DESPESA' and valor=50.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=839 and tipo='DESPESA' and valor=50.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Wemerson' where id=842 and tipo='DESPESA' and valor=550.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Flávio' where id=843 and tipo='DESPESA' and valor=320.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=844 and tipo='DESPESA' and valor=150.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Taxa de boleto' where id=846 and tipo='DESPESA' and valor=3.5 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=849 and tipo='DESPESA' and valor=90.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='COMERCIAL', subcategoria='Comissões pagas' where id=847 and tipo='DESPESA' and valor=2000.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=848 and tipo='DESPESA' and valor=130.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=850 and tipo='DESPESA' and valor=500.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Taxa de boleto' where id=851 and tipo='DESPESA' and valor=1.1 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Custo de conta' where id=855 and tipo='DESPESA' and valor=60.44 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Taxa de boleto' where id=860 and tipo='DESPESA' and valor=11.48 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CARTÃO DE CRÉDITO', subcategoria='Fatura não detalhada' where id=862 and tipo='DESPESA' and valor=2572.88 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Wemerson' where id=863 and tipo='DESPESA' and valor=100.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=865 and tipo='DESPESA' and valor=510.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=866 and tipo='DESPESA' and valor=900.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=867 and tipo='DESPESA' and valor=450.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Lucas' where id=868 and tipo='DESPESA' and valor=5600.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Wemerson' where id=869 and tipo='DESPESA' and valor=550.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=870 and tipo='DESPESA' and valor=450.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Wemerson' where id=875 and tipo='DESPESA' and valor=15.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CARTÃO DE CRÉDITO', subcategoria='Fatura não detalhada' where id=876 and tipo='DESPESA' and valor=10989.82 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=877 and tipo='DESPESA' and valor=300.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=878 and tipo='DESPESA' and valor=180.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=880 and tipo='DESPESA' and valor=180.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=881 and tipo='DESPESA' and valor=150.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=882 and tipo='DESPESA' and valor=300.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=883 and tipo='DESPESA' and valor=56.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='João Pedro' where id=884 and tipo='DESPESA' and valor=818.01 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=887 and tipo='DESPESA' and valor=40.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Taxa de boleto' where id=890 and tipo='DESPESA' and valor=8.75 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='VEÍCULOS', subcategoria='Financiamento' where id=892 and tipo='DESPESA' and valor=1759.75 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Material e insumos de obra' where id=893 and tipo='DESPESA' and valor=100.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='OUTRAS DESPESAS', subcategoria='A identificar' where id=894 and tipo='DESPESA' and valor=40.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Felipe' where id=895 and tipo='DESPESA' and valor=175.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=896 and tipo='DESPESA' and valor=1500.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=897 and tipo='DESPESA' and valor=350.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=898 and tipo='DESPESA' and valor=6094.69 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=899 and tipo='DESPESA' and valor=350.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=901 and tipo='DESPESA' and valor=1500.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=903 and tipo='DESPESA' and valor=150.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Wemerson' where id=904 and tipo='DESPESA' and valor=420.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=905 and tipo='DESPESA' and valor=1600.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Taxa de boleto' where id=907 and tipo='DESPESA' and valor=3.5 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Wemerson' where id=908 and tipo='DESPESA' and valor=20.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Wemerson' where id=909 and tipo='DESPESA' and valor=250.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=910 and tipo='DESPESA' and valor=217.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=911 and tipo='DESPESA' and valor=108.39 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=912 and tipo='DESPESA' and valor=108.39 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='IMPOSTOS', subcategoria='Simples Nacional' where id=913 and tipo='DESPESA' and valor=8076.72 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='OUTRAS DESPESAS', subcategoria='A identificar' where id=914 and tipo='DESPESA' and valor=240.47 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=915 and tipo='DESPESA' and valor=2539.68 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=916 and tipo='DESPESA' and valor=1709.93 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CERTIFICAÇÃO EMPRESA E EQUIPAMENTOS', subcategoria='Certificação empresa' where id=917 and tipo='DESPESA' and valor=1300.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=918 and tipo='DESPESA' and valor=150.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TERCEIRIZAÇÃO DE MÃO DE OBRA', subcategoria='Profissional autônomo' where id=919 and tipo='DESPESA' and valor=200.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='DESLOCAMENTO', subcategoria='Hospedagem' where id=926 and tipo='DESPESA' and valor=180.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TERCEIRIZAÇÃO DE MÃO DE OBRA', subcategoria='Profissional autônomo' where id=927 and tipo='DESPESA' and valor=2000.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=928 and tipo='DESPESA' and valor=4178.2 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=931 and tipo='DESPESA' and valor=314.8 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='VEÍCULOS', subcategoria='Sem parar' where id=932 and tipo='DESPESA' and valor=311.8 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=933 and tipo='DESPESA' and valor=450.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=934 and tipo='DESPESA' and valor=150.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=935 and tipo='DESPESA' and valor=782.23 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=936 and tipo='DESPESA' and valor=108.39 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=937 and tipo='DESPESA' and valor=340.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Compra de peças para revenda (direto)' where id=938 and tipo='DESPESA' and valor=977.15 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=939 and tipo='DESPESA' and valor=170.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=940 and tipo='DESPESA' and valor=100.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='IMPOSTOS', subcategoria='Simples Nacional' where id=941 and tipo='DESPESA' and valor=2201.26 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=942 and tipo='DESPESA' and valor=70.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=943 and tipo='DESPESA' and valor=133.16 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=944 and tipo='DESPESA' and valor=112.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Taxa de boleto' where id=946 and tipo='DESPESA' and valor=3.5 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Wemerson' where id=948 and tipo='DESPESA' and valor=30.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Taxa de boleto' where id=950 and tipo='DESPESA' and valor=3.5 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Felipe' where id=952 and tipo='DESPESA' and valor=140.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Wemerson' where id=953 and tipo='DESPESA' and valor=650.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=954 and tipo='DESPESA' and valor=2500.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=955 and tipo='DESPESA' and valor=150.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Wemerson' where id=956 and tipo='DESPESA' and valor=100.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=957 and tipo='DESPESA' and valor=50.5 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Taxa de boleto' where id=961 and tipo='DESPESA' and valor=10.5 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=962 and tipo='DESPESA' and valor=1000.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Material e insumos de obra' where id=963 and tipo='DESPESA' and valor=1600.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=964 and tipo='DESPESA' and valor=650.34 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Taxa de boleto' where id=965 and tipo='DESPESA' and valor=1.47 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Material e insumos de obra' where id=951 and tipo='DESPESA' and valor=525.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='OUTRAS DESPESAS', subcategoria='A identificar' where id=967 and tipo='DESPESA' and valor=1000.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='SERVIÇOS ADMINISTRATIVOS', subcategoria='Contabilidade' where id=968 and tipo='DESPESA' and valor=1196.25 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=969 and tipo='DESPESA' and valor=300.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Custo de conta' where id=970 and tipo='DESPESA' and valor=60.44 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Taxa de boleto' where id=973 and tipo='DESPESA' and valor=7.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Taxa de boleto' where id=991 and tipo='DESPESA' and valor=2.8 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=966 and tipo='DESPESA' and valor=2650.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=993 and tipo='DESPESA' and valor=150.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=996 and tipo='DESPESA' and valor=389.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=997 and tipo='DESPESA' and valor=271.57 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=998 and tipo='DESPESA' and valor=360.97 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=999 and tipo='DESPESA' and valor=418.14 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=1000 and tipo='DESPESA' and valor=464.06 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=1001 and tipo='DESPESA' and valor=331.47 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Wemerson' where id=1002 and tipo='DESPESA' and valor=500.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CARTÃO DE CRÉDITO', subcategoria='Fatura não detalhada' where id=1003 and tipo='DESPESA' and valor=1828.86 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Lucas' where id=1004 and tipo='DESPESA' and valor=6000.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=1006 and tipo='DESPESA' and valor=1000.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=1007 and tipo='DESPESA' and valor=391.5 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=1008 and tipo='DESPESA' and valor=218.26 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=1009 and tipo='DESPESA' and valor=809.5 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Wemerson' where id=1012 and tipo='DESPESA' and valor=200.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=1013 and tipo='DESPESA' and valor=108.39 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Taxa de boleto' where id=1014 and tipo='DESPESA' and valor=1.5 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='SERVIÇOS ADMINISTRATIVOS', subcategoria='Software e certificado digital' where id=1015 and tipo='DESPESA' and valor=214.44 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TERCEIRIZAÇÃO DE MÃO DE OBRA', subcategoria='Profissional autônomo' where id=1016 and tipo='DESPESA' and valor=360.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Taxa de boleto' where id=1019 and tipo='DESPESA' and valor=3.5 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=1020 and tipo='DESPESA' and valor=300.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=1022 and tipo='DESPESA' and valor=1380.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=1023 and tipo='DESPESA' and valor=300.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=1024 and tipo='DESPESA' and valor=400.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TERCEIRIZAÇÃO DE MÃO DE OBRA', subcategoria='Empresa terceira' where id=1025 and tipo='DESPESA' and valor=2000.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=1026 and tipo='DESPESA' and valor=300.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CARTÃO DE CRÉDITO', subcategoria='Fatura não detalhada' where id=1027 and tipo='DESPESA' and valor=10746.89 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=1028 and tipo='DESPESA' and valor=300.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Wemerson' where id=1029 and tipo='DESPESA' and valor=700.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='VEÍCULOS', subcategoria='Financiamento' where id=1030 and tipo='DESPESA' and valor=1742.48 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=1032 and tipo='DESPESA' and valor=153.5 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='VEÍCULOS', subcategoria='Seguro' where id=1035 and tipo='DESPESA' and valor=233.86 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=1036 and tipo='DESPESA' and valor=30.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='João Pedro' where id=1037 and tipo='DESPESA' and valor=700.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=1042 and tipo='DESPESA' and valor=200.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=1045 and tipo='DESPESA' and valor=4478.1 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=1046 and tipo='DESPESA' and valor=1850.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=1047 and tipo='DESPESA' and valor=150.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Wemerson' where id=1048 and tipo='DESPESA' and valor=100.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Taxa de boleto' where id=1050 and tipo='DESPESA' and valor=3.5 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ROYALTES', subcategoria='MCA Tecnologia' where id=1051 and tipo='DESPESA' and valor=1355.16 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Wemerson' where id=1054 and tipo='DESPESA' and valor=500.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TERCEIRIZAÇÃO DE MÃO DE OBRA', subcategoria='Profissional autônomo' where id=1044 and tipo='DESPESA' and valor=1000.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Encargos e benefícios' where id=1057 and tipo='DESPESA' and valor=55.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Wemerson' where id=1058 and tipo='DESPESA' and valor=50.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Taxa de boleto' where id=1060 and tipo='DESPESA' and valor=3.5 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='IMPOSTOS', subcategoria=NULL where id=1061 and tipo='DESPESA' and valor=364.02 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=1062 and tipo='DESPESA' and valor=200.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=1064 and tipo='DESPESA' and valor=1960.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Compra de peças para revenda (direto)' where id=1065 and tipo='DESPESA' and valor=4110.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Compra de peças para revenda (direto)' where id=1066 and tipo='DESPESA' and valor=700.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Taxa de boleto' where id=1067 and tipo='DESPESA' and valor=1.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=1070 and tipo='DESPESA' and valor=300.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=1071 and tipo='DESPESA' and valor=1250.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Wemerson' where id=1072 and tipo='DESPESA' and valor=650.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Taxa de boleto' where id=1075 and tipo='DESPESA' and valor=3.5 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Wemerson' where id=1073 and tipo='DESPESA' and valor=50.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=1076 and tipo='DESPESA' and valor=150.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=1077 and tipo='DESPESA' and valor=108.39 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=1079 and tipo='DESPESA' and valor=50.5 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=1080 and tipo='DESPESA' and valor=2472.3 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=1081 and tipo='DESPESA' and valor=158.9 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=1082 and tipo='DESPESA' and valor=155.61 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=1083 and tipo='DESPESA' and valor=100.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Taxa de boleto' where id=1085 and tipo='DESPESA' and valor=4.5 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Felipe' where id=1086 and tipo='DESPESA' and valor=35.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='VEÍCULOS', subcategoria='Manutenção' where id=1089 and tipo='DESPESA' and valor=400.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=1091 and tipo='DESPESA' and valor=150.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Compra de peças estoque' where id=1092 and tipo='DESPESA' and valor=1300.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Taxa de boleto' where id=1095 and tipo='DESPESA' and valor=7.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=1096 and tipo='DESPESA' and valor=100.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Wemerson' where id=1097 and tipo='DESPESA' and valor=1000.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=1098 and tipo='DESPESA' and valor=1500.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=1101 and tipo='DESPESA' and valor=177.79 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=1102 and tipo='DESPESA' and valor=797.97 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Taxa de boleto' where id=1103 and tipo='DESPESA' and valor=3.9 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Taxa de boleto' where id=1104 and tipo='DESPESA' and valor=1.95 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=1105 and tipo='DESPESA' and valor=2532.24 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=1106 and tipo='DESPESA' and valor=94.05 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=1107 and tipo='DESPESA' and valor=108.39 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=1108 and tipo='DESPESA' and valor=3900.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='ESTOQUE', subcategoria='Compra de peças estoque' where id=1109 and tipo='DESPESA' and valor=465.6 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=1110 and tipo='DESPESA' and valor=600.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Custo de conta' where id=1111 and tipo='DESPESA' and valor=60.44 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Taxa de boleto' where id=1114 and tipo='DESPESA' and valor=7.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Taxa de boleto' where id=1123 and tipo='DESPESA' and valor=3.42 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Wemerson' where id=1117 and tipo='DESPESA' and valor=136.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Lucas' where id=1118 and tipo='DESPESA' and valor=6000.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Wemerson' where id=1120 and tipo='DESPESA' and valor=65.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='João Pedro' where id=1121 and tipo='DESPESA' and valor=700.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='OUTRAS DESPESAS', subcategoria='A identificar' where id=1115 and tipo='DESPESA' and valor=1000.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CARTÃO DE CRÉDITO', subcategoria='Fatura não detalhada' where id=1125 and tipo='DESPESA' and valor=9988.88 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Wemerson' where id=1133 and tipo='DESPESA' and valor=600.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=1134 and tipo='DESPESA' and valor=750.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=1135 and tipo='DESPESA' and valor=150.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Taxa de boleto' where id=1136 and tipo='DESPESA' and valor=1.75 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='VEÍCULOS', subcategoria='Financiamento' where id=1137 and tipo='DESPESA' and valor=1725.21 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='VEÍCULOS', subcategoria='Financiamento' where id=1138 and tipo='DESPESA' and valor=1725.21 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=1139 and tipo='DESPESA' and valor=108.39 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='RETIRADAS (PROPRIETÁRIO)', subcategoria=NULL where id=1140 and tipo='DESPESA' and valor=1850.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=1141 and tipo='DESPESA' and valor=200.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='CREA', subcategoria='ART' where id=1142 and tipo='DESPESA' and valor=108.39 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Wemerson' where id=1145 and tipo='DESPESA' and valor=35.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='FUNCIONÁRIO', subcategoria='Avulso diarista' where id=1146 and tipo='DESPESA' and valor=100.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Custo de conta' where id=341 and tipo='DESPESA' and valor=60.44 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Taxa de boleto' where id=757 and tipo='DESPESA' and valor=4.0 and coalesce(classificacao,'')<>'pendente';
update public.fluxo_caixa set categoria='TARIFAS BANCÁRIAS', subcategoria='Taxa de boleto' where id=333 and tipo='DESPESA' and valor=3.5 and coalesce(classificacao,'')<>'pendente';

-- Contas a pagar
update public.contas_pagar set categoria='VEÍCULOS', subcategoria='Financiamento' where categoria='FINANCIAMENTO CARRO';

-- Itens do cartão (todos de agosto, já fechados e lançados no fluxo)
update public.cartao_itens set
  subcategoria = case
    when categoria='ALIMENTAÇÃO E HOSPEDAGEM' and (descricao ilike '%hotel%' or descricao ilike '%pousada%') then 'Hospedagem'
    when categoria='ALIMENTAÇÃO E HOSPEDAGEM' then 'Alimentação'
    when categoria in ('COMBUSTÍVEL','DESLOCAMENTO') then 'Combustível'
    when categoria='COMPRA DE MATERIAL (INSUMOS)' then 'Material e insumos de obra'
    when categoria='DEMAIS GASTOS' then 'A identificar'
  end,
  categoria = case
    when categoria='ALIMENTAÇÃO E HOSPEDAGEM' then 'DESLOCAMENTO'
    when categoria in ('COMBUSTÍVEL','DESLOCAMENTO') then 'VEÍCULOS'
    when categoria='COMPRA DE MATERIAL (INSUMOS)' then 'ESTOQUE'
    when categoria='DEMAIS GASTOS' then 'OUTRAS DESPESAS'
  end
where categoria in ('ALIMENTAÇÃO E HOSPEDAGEM','COMBUSTÍVEL','DESLOCAMENTO','COMPRA DE MATERIAL (INSUMOS)','DEMAIS GASTOS');

-- Conferência: total das despesas antigas (ids até 1146) deve continuar R$ 712.297,69
select round(sum(valor)::numeric,2) total_despesas, count(*) linhas, count(*) filter (where subcategoria is not null) com_sub,
  (select count(*) from public.fluxo_caixa where tipo='DESPESA' and classificacao='pendente') pendentes_intactos,
  (select count(*) from public.cartao_itens where subcategoria is null) cartao_sem_sub
from public.fluxo_caixa where tipo='DESPESA' and id<=1146;
commit;
