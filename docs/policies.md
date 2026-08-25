# Políticas

> **O gate evidencia, não barra.** O `security-auditor` e as skills entregam a licença, o
> **link direto** de onde ela está escrita e o que ela exige daquele uso — e seguem. Quem
> decide aceitar ou recusar uma restrição é quem carrega o risco do produto, contra a
> política da organização. `policies/license-policy.md` é um **template** dessa política:
> os vereditos ali são a escolha de uma organização com produto proprietário distribuído
> comercialmente, e você deve editá-los para o seu perfil de risco.
>
> O modo de falha que isso previne não é usar código permissivo demais — é código de
> terceiro entrar sem ninguém saber de onde veio. Por isso a evidência viaja junto com a
> entrega.


## Gate de licença

Antes de clonar, instalar ou varrer qualquer código de terceiros — `git clone`, ingestão de URL externa (ex.: `/graphify <url>`), dependência nova — este setup exige passar pelo gate de licença definido em `policies/license-policy.md`, com classificação delegada ao agente `security-auditor` (ver `docs/agents.md`).

### Premissa fundadora

Tudo que a organização produz converge para o produto principal, distribuído comercialmente. Por isso a pergunta nunca é só "qual a licença?" — é "esta licença permite **embutir** este código num produto proprietário comercial?". A classificação usa dois eixos:

| Eixo | Valores |
|---|---|
| Licença (SPDX) | a licença detectada no repo/dependência |
| Modo de uso | `EMBUTIDO` (linkado/incorporado no produto — **default**) · `FERRAMENTA` (processo externo isolado, sem linkar, sem distribuir) |

O veredito é função dos dois eixos — a mesma licença pode ser aceitável como ferramenta de build e proibida como biblioteca embutida. O default é sempre o caso mais restritivo (`EMBUTIDO`).

### Tiers de veredito

- **APROVADO** (permissivas — Apache-2.0, MIT, BSD, ISC, Boost, domínio público): embutir à vontade, mantendo aviso de copyright.
- **APROVADO COM CONDIÇÕES** (copyleft fraco — MPL-2.0, LGPL): libera com checklist de fronteira (isolar em arquivos/módulos separados, preferir dynamic linking, publicar só as modificações da própria lib).
- **CONDICIONAL / BLOQUEADO se EMBUTIDO** (copyleft forte e de rede — GPL, AGPL, EPL, CDDL, EUPL): bloqueia no modo `EMBUTIDO`; pode liberar como `FERRAMENTA` caso a caso.
- **RECUSADO** (source-available restritiva, non-commercial, licenças de modelo com restrição de uso, fechado/proprietário): bloqueio duro em qualquer modo. Só sai com aprovação explícita e registrada.
- **DESCONHECIDO/DUPLA/NÃO-RECONHECIDA**: fail-closed — tratado como bloqueio até classificação manual. Nunca libera por omissão.

O mapa SPDX → tier machine-readable é a fonte de verdade do gate e vive no próprio `policies/license-policy.md`.

### Fluxo do gate

1. Resolver o SPDX sem baixar o repo (ex.: `gh api repos/<owner>/<repo> --jq .license.spdx_id`).
2. Se SPDX vazio/`NOASSERTION`: fetch raso de `LICENSE*`/`COPYING*`/`README*` e inspeção manual + heurística textual de licenças recusadas.
3. Classificar (licença × modo de uso) → veredito.
4. **Entregar a evidência**, sempre: a licença, o **link direto** de onde ela está escrita (o `LICENSE` no repositório, não a página de marketing), e o que ela exige daquele uso em particular. Registrar em log de auditoria.
5. A evidência **viaja junto com a entrega** — uma linha com fonte e licença, e um `THIRD-PARTY-NOTICES.md` quando houver cópia.

### A ferramenta evidencia; a política decide

O agente e as skills **não interrompem trabalho**. Eles não têm como saber o perfil de risco da sua organização, e um bloqueio automático baseado em premissa errada custa mais do que resolve: quem é barrado no fluxo aprende a contornar o gate, e aí a evidência para de ser produzida — que é a única coisa que o gate realmente entrega.

O veredito por tier de `policies/license-policy.md` continua sendo a referência, mas ele é a política **da organização**, não o comportamento da ferramenta. Aceitar ou recusar uma restrição é decisão de quem carrega o risco do produto, e o registro dessa decisão vive na política interna — nunca num repositório público.

O modo de falha que o gate previne não é usar código permissivo demais. É código de terceiro entrar sem ninguém saber de onde veio, e o time descobrir a obrigação no dia em que o produto é entregue a um cliente.

### Override e allowlist

- Override exige aprovação explícita do responsável, registrada em log de auditoria (repo, SPDX, modo, veredito original, quem aprovou, justificativa, timestamp).
- Exceções versionadas ficam em `policies/license-allowlist.json` — cada entrada documenta o repo, o SPDX, o modo, o veredito original que foi sobreposto, quem aprovou e o motivo.
- Um override nunca apaga o registro — a exceção permanece auditável.

### Veredito durável não é re-auditado

Se já existe um veredito registrado para o **mesmo alvo/versão** (na allowlist, num log de auditoria, ou em qualquer registro já documentado do projeto), esse veredito é reaproveitado — não se gasta uma nova rodada do gate para o mesmo caso. Só se re-audita quando:

- o alvo mudou de versão;
- o registro existente está ambíguo;
- há pedido explícito para reclassificar.

A regra geral é verificar a documentação/registro existente **antes** de re-executar qualquer processo já documentado.
