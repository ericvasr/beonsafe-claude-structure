# Premissas dos agentes operacionais

Vale para **todo agente novo** criado daqui em diante, e para os operacionais
(`liveness-auditor`, `esteira-gate`, `release-conductor`, e os que vierem). Não é
estilo — é o que separa um agente que muda a operação de mais um que dá conselho.

O corpo de agentes de 2026-08-10 era forte em domínio e não tinha nenhum dono de
artefato operacional: todos os generalistas terminavam em "não implemente sem pedir —
analise e recomende". Correto para consultoria, e exatamente por que nada melhorava
sozinho. O padrão que funciona separa as três etapas em agentes distintos:
**scanner** (lê o estado real) → **architect** (produz o plano) → **applier** (aplica).

---

## 1. Medir vem antes de ler

A fonte primária é a produção, não o repositório, não o handoff, não a issue.

Ordem obrigatória: **produção medida → issues abertas → código.** O código explica
*por que* o medido é assim; ele não substitui a medição. Inverter essa ordem já
produziu documento errado o bastante para ser refeito do zero.

- `docker ps` e `docker inspect -f '{{.RestartCount}}'` antes de qualquer afirmação
  sobre estado de container.
- Por tabela: `count(*)` e `max(ts)`. **`count(*)`, nunca `pg_stat_user_tables`** —
  a estimativa do catálogo já reportou 13 registros onde havia 7.
- Catálogo do banco para o que se afirma sobre o banco (`pg_class.relrowsecurity`,
  `pg_policies`, `pg_roles`). Grep no código dá falso positivo — `rls` casa dentro
  de `URLs`.
- `git fetch` antes de comparar branches. Sem isso, "não mergeado" e "não promovido"
  viram a mesma coisa, e não são.
- Ler a entidade de autorização antes de afirmar papel. "Três admins plenos" virou
  "três papéis diferenciados por site" ao abrir a tabela de privilégios.
- Conferir o filtro antes de chamar volume de fila pendente. Uma fila com 4.525 alertas
  e `archived:false = 0` é histórico arquivado inteiro, não pendência nenhuma — o
  número grande engana quem não olha o filtro.

O padrão por trás de todos esses erros é um só: **inferir de fonte secundária com a
primária a um comando de distância.**

## 2. Ler produção sem estragar

- `PGOPTIONS='-c default_transaction_read_only=on'` em toda leitura de Postgres.
- **Nunca** `ssh host "PGPASSWORD='...' psql"` — a senha vai para o `argv` e qualquer
  `ps` na máquina a lê. Exportar no ambiente do lado de lá.
- Segredo nunca entra em relatório. Mascarar `SECRET`, senha, token, client secret.
- Se uma camada não pôde ser medida, o relatório diz isso. **Lacuna declarada vale
  mais que número inventado.**

## 3. Medir nunca muta

Todo agente operacional é **read-only**, e escreve **apenas** o próprio relatório.
Quando existir ação, ela mora num `-applier` separado, como o par
architect/applier. Um agente que mede e conserta na mesma passada não
tem como ser confiável nas duas coisas.

## 4. Caminho fixo de saída

`~/ops-reports/<agente>-<produto>-<AAAA-MM-DD>.md`

Sem caminho fixo os relatórios não compõem, e o operador termina lendo cinco
arquivos soltos sem conseguir comparar duas datas do mesmo produto.

## 5. Veredicto com evidência ao lado

Vocabulário fechado, um por achado:

| Veredicto | Significa |
|---|---|
| `PRONTO` | medido funcionando em produção agora |
| `PARCIAL` | funciona em parte, ou funciona sem cobrir o caso que importa |
| `NÃO ENTREGUE` | o código existe e a capacidade não chega ao usuário |
| `POR CONSTRUIR` | não existe |

Cada veredicto vem com **o comando que o sustenta e a saída dele**. Sem evidência ao
lado, é opinião — e opinião não sobrevive a "tem certeza?".

A categoria mais valiosa é `NÃO ENTREGUE`: código correto, container `healthy`,
capacidade que não chega. É a que nenhum dashboard mostra.

## 6. Data e hora da medição no cabeçalho

Todo relatório abre com quando foi medido e de onde. Relatório sem timestamp vira
verdade eterna em três dias, e é assim que um handoff de seis dias produz metade
dos veredictos errados.

## 7. Quando o agente deve ser acionado

Além do gatilho da `description`, estes agentes são o **desempate de sessão empacada**.
Se eu estiver há mais de duas trocas discutindo se algo funciona, sem medição na mesa,
o próximo passo não é mais uma hipótese — é acionar o agente que mede aquilo.

Sinais de que a sessão empacou e precisa de medição, não de raciocínio:
- duas hipóteses concorrentes e nenhuma evidência nova entre elas;
- alguém afirmando estado de produção a partir de repo, doc ou memória;
- "deve estar funcionando" / "provavelmente" sobre algo que tem comando de verificação;
- retomada de assunto que já foi discutido antes sem nada ter sido medido desde então.

## 8. Atribuição

Sem trailer de coautoria de IA em nada versionado. A autoria é de quem opera; o agente age em
meu nome e nunca se auto-nomeia em spec, commit ou relatório.
