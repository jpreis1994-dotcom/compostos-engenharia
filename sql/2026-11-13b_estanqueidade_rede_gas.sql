-- Estanqueidade: "Outras empresas / rede de gás" vira "Outras empresas" e nasce a subcategoria "Rede de gás"
begin;
update public.receita_categorias set subcategoria='Outras empresas'
 where categoria='TESTE DE ESTANQUEIDADE' and subcategoria='Outras empresas / rede de gás';
insert into public.receita_categorias (categoria, subcategoria, servico, ordem)
 select 'TESTE DE ESTANQUEIDADE','Rede de gás',true,225
 where not exists (select 1 from public.receita_categorias where categoria='TESTE DE ESTANQUEIDADE' and subcategoria='Rede de gás');
update public.fluxo_caixa set subcategoria='Outras empresas'
 where categoria='TESTE DE ESTANQUEIDADE' and subcategoria='Outras empresas / rede de gás';
-- OS 248 (NKG Stockler): orçamento 051 "Teste de estanqueidade rede de gás"
update public.ordens_servico set servicos_itens=replace(servicos_itens,'"sub":"Outras empresas / rede de gás"','"sub":"Rede de gás"') where numero_os=248;
update public.ordens_servico set servicos_itens=replace(servicos_itens,'"sub":"Outras empresas / rede de gás"','"sub":"Outras empresas"')
 where servicos_itens like '%Outras empresas / rede de gás%';
update public.ordens_servico set servico=replace(servico,'Outras empresas / rede de gás','Outras empresas')
 where servico like '%Outras empresas / rede de gás%';
select (select count(*) from public.fluxo_caixa where subcategoria like 'Outras empresas%') fluxo_outras,
       (select count(*) from public.ordens_servico where servicos_itens like '%Rede de gás%') os_rede_gas,
       (select count(*) from public.ordens_servico where coalesce(servicos_itens,'')||coalesce(servico,'') like '%/ rede de gás%') sobrou;
commit;
