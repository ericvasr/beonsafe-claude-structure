# SETUP — do zero até a primeira sessão

Um comando faz a instalação inteira, guiada:

```bash
git clone https://github.com/ericvasr/beonsafe-claude-structure
cd beonsafe-claude-structure
./install.sh
```

O instalador pergunta o seu nome, sugere onde ficam projetos e vaults, e apresenta cada
agente, skill e hook **antes** de instalar — dizendo o que a peça passa a fazer sozinha
na sua máquina. Você pode recusar qualquer bloco e continuar.

Prefere ver antes de escrever?

```bash
./install.sh --dry-run       # mostra tudo, não toca em nada
./install.sh --yes           # aceita os padrões, sem perguntas (CI, máquina nova)
./install.sh --force         # sobrescreve arquivos que você editou
```

Sem terminal interativo — `curl | bash`, pipeline de CI — ele assume `--yes` sozinho, em
vez de travar esperando uma resposta que nunca vem.

---

## O que ele faz, na ordem

| Etapa | O que acontece |
|---|---|
| 1 · Pré-requisitos | Confere `jq`, `git`, `claude`. Sem `jq` ele para: o merge de settings depende dele. |
| 2 · Quem é você | Pergunta o nome. Vira `OWNER_NAME` no `settings.json` e substitui o placeholder do `CLAUDE.md`. |
| 3 · Pasta de projetos | Sugere `~/Projects`, cria se você quiser. |
| 4 · Vaults | Cria `conhecimento-pessoal` e `conhecimento-empresa` com a estrutura completa e o `.wikiconfig.json` de cada um. |
| 5 · Backup | Copia `agents/ skills/ commands/ hooks/ policies/ docs/ wiki/ examples/`, `settings.json` e `CLAUDE.md` para `~/.claude/backups/install-<timestamp>/`. Mantém os 5 mais recentes. |
| 6 · Agentes | Cinco famílias, uma pergunta cada, com a lista do que entra. |
| 7 · Skills, commands e hooks | Um a um. Os hooks vêm com o gatilho declarado, porque rodam sem você pedir. |
| 8 · Validação | `bash -n` em cada hook, `+x` conferido, `jq empty` em cada JSON, contagem final. |

Nada é destruído. Arquivo que você editou é **preservado com aviso**, não sobrescrito —
só `--force` passa por cima.

---

## Antes: as dependências de terceiros

Este repo não redistribui código de terceiro. As skills e plugins externos que o setup
usa são instalados da fonte oficial de cada um, sob a licença de cada um — a lista
completa, com origem e licença, está em [`DEPENDENCIES.md`](DEPENDENCIES.md).

O mínimo para o blueprint funcionar como desenhado:

```
/plugin marketplace add anthropics/claude-plugins-official
/plugin install superpowers
/plugin install playwright
```

O resto é opcional e você pode adicionar depois.

---

## Depois: os dois arquivos que ainda estão genéricos

O instalador não tem como adivinhar isso, e sem eles os agentes recomendam no vazio.

**`~/.claude/CLAUDE.md`** — conduz toda sessão, em qualquer diretório. Preencha o
contexto: qual é a sua stack, o que roda em produção, quais regras de trabalho valem
sempre. Se você já tinha um, o template ficou ao lado como `CLAUDE.md.blueprint`.

**`~/.claude/examples/products.json`** — os cinco agentes de operação leem esse arquivo
antes de medir produção. Enquanto ele tiver os produtos de exemplo (Atlas e Farol), eles
medem um portfólio que não é o seu.

---

## Verificar que está em vigor

Config declarada não é config em vigor. Hook registrado no `settings.json` pode nunca
disparar, e a evidência disso é comportamento, não linha de arquivo.

Abra uma **sessão nova** — hook só carrega no start — e confira:

```
/doctor      diagnóstico do ambiente
/agents      os agentes que o Claude enxerga
/status      o que está carregado nesta sessão
/config      modelo, tema, permissões
```

Depois, pelo terminal:

```bash
# os hooks estão registrados?
jq -r '.hooks | to_entries[] | "\(.key): \(.value[].hooks[].command)"' ~/.claude/settings.json

# eles estão executáveis?
ls -l ~/.claude/hooks/*.sh

# eles rodaram?
tail -5 ~/.claude/logs/*.jsonl 2>/dev/null
```

A statusline é o sinal mais rápido: se ela não aparece, o merge de `settings.json` não
pegou.

---

## Quando o hook não dispara

| Sintoma | Causa e conserto |
|---|---|
| Statusline ausente | `jq '.statusLine' ~/.claude/settings.json` vazio → rode `./install.sh --force` |
| Hook registrado que nunca roda | Falta `+x`. Hook sem bit de execução falha em **silêncio**: `chmod +x ~/.claude/hooks/*.sh` |
| Mudança no `settings.json` sem efeito | O `env` do settings vaza para o processo vivo e não sai ao reverter o arquivo. Teste em **sessão nova**, ou com `env -u VAR` |
| Librarian não pede síntese | `LIBRARIAN_MIN_CHANGES` alto, ou o hook de `Stop` não registrado |
| `/ingerir` escreve no vault errado | `.wikiconfig.json` ausente na raiz do vault, ou com `id` trocado |
| Guard de voz não bloqueia nada | `OWNER_NAME` vazio. Sem o nome ele pula a checagem de terceira pessoa de propósito — chutar daria falso positivo |

Desligar temporariamente, quando um gate atrapalhar:

```bash
CODE_REVIEW_GATE=0     # não pede review no fim da sessão
REVIEW_VOICE_GUARD=0   # não intercepta gh pr comment
LIBRARIAN_AUTOINGEST=0 # não força a síntese
```

---

## Desinstalar

O backup do instalador é o caminho de volta:

```bash
ls ~/.claude/backups/
rm -rf ~/.claude/agents ~/.claude/skills ~/.claude/commands ~/.claude/hooks
cp -a ~/.claude/backups/install-<timestamp>/* ~/.claude/
```

Os vaults ficam onde estão — são seus, e o instalador nunca os apaga.
