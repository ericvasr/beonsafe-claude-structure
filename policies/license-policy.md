---
titulo: "Política de Licenças de Software"
tipo: policy
status: draft-v0
dono: <o responsável por segurança nesta organização>
criado: 2026-06-17
fonte-canonica: este arquivo (provisório em ~/.claude/policies/ — migrar p/ repo de governança quando existir)
aplica-se-a: todo código de terceiros clonado, instalado ou incorporado em qualquer produto/serviço da empresa
---

# Política de Licenças

> **Este arquivo é um template de política — dela, da sua organização.** Os vereditos
> abaixo (`APPROVE`, `BLOCK`, `REVIEW`) são a escolha de uma organização com um perfil de
> risco específico: produto proprietário, distribuído comercialmente. **Não é o
> comportamento da ferramenta.**
>
> O `security-auditor` e as skills **não interrompem trabalho**. Eles entregam a
> **evidência**: qual é a licença, o **link direto** de onde ela está escrita, e o que ela
> exige deste uso em particular. Quem decide aceitar ou recusar uma restrição é quem
> carrega o risco do produto — e essa decisão vive nesta política, que é sua para editar.
>
> Ajuste a tabela ao seu caso. Uma consultoria que só entrega código para o cliente tem
> tolerância diferente de um SaaS que roda o código próprio, e as duas diferem de um
> projeto interno que nunca é distribuído.

## Premissa fundadora

**Premissa deste template, que você deve trocar pela sua:** tudo que a organização produz converge
para um produto principal, que é distribuído e operado **comercialmente**, possivelmente como SaaS.
É o perfil mais restritivo, e por isso serve de ponto de partida. Sob essa premissa, a pergunta
nunca é só *"qual a licença?"* — é
***"esta licença permite EMBUTIR este código num produto proprietário comercial?"***

Por isso a classificação tem **dois eixos**, não um:

| Eixo | Valores |
|------|---------|
| Licença (SPDX) | a licença detectada no repo/dependência |
| **Modo de uso** | `EMBUTIDO` (linkado/incorporado no produto principal — **default**) · `FERRAMENTA` (processo externo isolado, sem linkar, sem distribuir) |

O veredito do gate = **função dos dois**. Uma GPL pode ser *ferramenta de build* aceitável
e ao mesmo tempo *biblioteca embutida* proibida. O default é sempre `EMBUTIDO` (o caso
mais restritivo) — só cai para `FERRAMENTA` com declaração explícita e justificada.

---

## Veredito por tier (modo `EMBUTIDO` = default)

### ✅ APROVADO — Permissivas
Uso comercial e modificação sem amarras. Embutir à vontade. Manter aviso de copyright/NOTICE.

| Licença | SPDX | Nota |
|---|---|---|
| Apache 2.0 | `Apache-2.0` | **Preferida** — permissiva + concessão de patentes (proteção p/ empresa) |
| MIT | `MIT` | Só manter aviso de copyright |
| BSD 2/3-Clause | `BSD-2-Clause`, `BSD-3-Clause` | Similar à MIT |
| ISC | `ISC` | Similar à MIT |
| Boost | `BSL-1.0` | **Permissiva** (Boost Software License). ⚠️ NÃO confundir com `BUSL-1.1` (Business Source — RECUSADA) |
| Domínio público | `0BSD`, `CC0-1.0`, `Unlicense`, `Zlib` | Sem amarras práticas |

### ✅ APROVADO COM CONDIÇÕES — Copyleft fraco
Pode embutir em produto proprietário **se respeitar a fronteira**: manter a lib em
arquivos/módulos separados, preferir *dynamic linking*, e publicar **apenas** as
modificações feitas na própria lib (não no resto do produto).

| Licença | SPDX | Condição |
|---|---|---|
| MPL 2.0 | `MPL-2.0` | Copyleft **por arquivo** — combinar com proprietário em arquivos separados |
| LGPL 2.1 / 3.0 | `LGPL-2.1-only`, `LGPL-2.1-or-later`, `LGPL-3.0-only`, `LGPL-3.0-or-later` | Copyleft **de biblioteca** — dynamic link; mudanças na lib ficam abertas |

> Verdict técnico: `APPROVE_WITH_CONDITIONS`. O gate libera mas **anexa o checklist de fronteira**
> e marca p/ revisão de arquitetura (não bloqueia).

### 🟥 CONDICIONAL — Copyleft forte e de rede (BLOQUEADO se `EMBUTIDO`)
Embutir/linkar dentro do produto principal **obriga abrir todo o código** — incompatível com produto
proprietário. **Bloqueio no default.** Liberado **apenas** como `FERRAMENTA` (processo
externo, à parte, sem linkar e sem distribuir junto), e ainda assim caso a caso.

| Licença | SPDX | EMBUTIDO | FERRAMENTA |
|---|---|---|---|
| GPL 2.0 / 3.0 | `GPL-2.0-only`, `GPL-2.0-or-later`, `GPL-3.0-only`, `GPL-3.0-or-later` | 🟥 BLOCK | ⚠️ REVIEW (ok como ferramenta à parte) |
| AGPL 3.0 | `AGPL-3.0-only`, `AGPL-3.0-or-later` | 🟥 BLOCK | 🟥 BLOCK se modificada+servida em rede; REVIEW se não-modificada e isolada |
| EPL, CDDL, EUPL | `EPL-2.0`, `CDDL-1.0`, `EUPL-1.2` | ⚠️ REVIEW | ⚠️ REVIEW |

> AGPL é o pior caso p/ SaaS: modificar e oferecer como serviço online obriga publicar o
> código. Para um produto operado como serviço, tratar AGPL como quase-RECUSADA.

### ⛔ RECUSADO — Ferem as premissas (BLOQUEIO DURO, qualquer modo)
Não clonar, não instalar, não embutir. Override só com aprovação explícita do responsável (ver abaixo).

| Categoria | Exemplos / SPDX |
|---|---|
| Source-available restritiva | `SSPL-1.0`, `BUSL-1.1` (Business Source — uso limitado/atrasado), `Commons-Clause` (proíbe vender) |
| Non-commercial / research-only | `CC-BY-NC-4.0`, `CC-BY-NC-SA-4.0`, `CC-BY-ND-4.0`, qualquer "research only" |
| Licenças de modelo com restrição | teto de escala/usuários, restrição de mercado, OpenRAIL/RAIL com restrição de campo de uso, Llama/Gemma-style com limites |
| Fechado / proprietário | closed weights, APIs proprietárias de terceiros, "all rights reserved", **sem arquivo de licença** |

### ❓ DESCONHECIDO / DUPLA / NÃO-RECONHECIDA — fail-closed
SPDX vazio, licença dupla conflitante, `LICENSE` ausente ou não-reconhecida pelo detector
→ **tratar como BLOQUEIO** até classificação manual (`REVIEW`). Nunca liberar por omissão.

---

## Mapa SPDX → tier (machine-readable, fonte de verdade do gate)

```yaml
permissive:        # verdict EMBUTIDO = APPROVE
  - Apache-2.0      # preferida
  - MIT
  - BSD-2-Clause
  - BSD-3-Clause
  - ISC
  - BSL-1.0         # Boost (NÃO é Business Source)
  - 0BSD
  - CC0-1.0
  - Unlicense
  - Zlib
weak_copyleft:     # verdict EMBUTIDO = APPROVE_WITH_CONDITIONS
  - MPL-2.0
  - LGPL-2.1-only
  - LGPL-2.1-or-later
  - LGPL-3.0-only
  - LGPL-3.0-or-later
strong_copyleft:   # verdict EMBUTIDO = BLOCK ; FERRAMENTA = REVIEW
  - GPL-2.0-only
  - GPL-2.0-or-later
  - GPL-3.0-only
  - GPL-3.0-or-later
  - EPL-2.0
  - CDDL-1.0
  - EUPL-1.2
network_copyleft:  # verdict EMBUTIDO = BLOCK ; FERRAMENTA = BLOCK-if-modified-served / REVIEW
  - AGPL-3.0-only
  - AGPL-3.0-or-later
refused:           # verdict = BLOCK (hard, qualquer modo)
  - SSPL-1.0
  - BUSL-1.1
  - Commons-Clause
  - CC-BY-NC-4.0
  - CC-BY-NC-SA-4.0
  - CC-BY-ND-4.0
  # + heurística textual: "non-commercial", "research only", "no resale",
  #   "may not be used to compete", limites de escala/mercado, RAIL com restrição de uso
unknown:           # verdict = BLOCK pendente REVIEW (fail-closed)
  - NOASSERTION
  - null
```

---

## Fluxo do gate (antes de clonar/varrer)

1. **Pré-clone:** resolver SPDX **sem baixar o repo** via `gh api repos/<owner>/<repo> --jq .license.spdx_id`.
2. **SPDX vazio/`NOASSERTION`:** fetch raso só de `LICENSE*`/`COPYING*`/`README*` (sparse/`--depth 1`) e inspecionar; rodar heurística textual de RECUSADAS.
3. **Classificar** (licença × modo de uso, default `EMBUTIDO`) → verdict.
4. **Verdict:**
   - `APPROVE` → segue p/ scan de conteúdo.
   - `APPROVE_WITH_CONDITIONS` → segue + anexa checklist de fronteira (isolar lib, dynamic link, publicar só mods da lib).
   - `REVIEW` → **pausa**, exige decisão registrada.
   - `BLOCK` → **aborta clone/scan**, exit≠0, registra em log de auditoria.
5. **Nunca** varrer conteúdo de repo `BLOCK` sem override.

## Override (quando bloqueia)

- Aprovação **explícita do responsável**, registrada em `~/.claude/logs/license-audit.jsonl`
  (repo, SPDX, modo, verdict original, quem aprovou, justificativa, timestamp).
- Allowlist por repo em `policies/license-allowlist.json` (exceções versionadas, com motivo).
- Override não some o registro — exceção fica auditável.

## Escopo (a definir)

- [x] Clone de repos GitHub (`/graphify <url>`, `git clone`, etc.)
- [ ] Dependências de pacote (`pip`/`npm`/`uv`/`cargo`) — supply chain. **Decisão pendente.**
- [ ] Licenças de **modelo** (HuggingFace/Ollama) — relevante para quem embute LLM no produto. **Decisão pendente.**
