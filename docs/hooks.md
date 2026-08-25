# Hooks

Hook é diferente de skill e de command: roda **sozinho**, em toda sessão, em qualquer
diretório, sem ninguém pedir. Por isso o `install.sh` apresenta um a um com o gatilho
declarado antes de instalar.

| Hook | Evento | O que faz |
|---|---|---|
| `statusline.sh` | `statusLine` | Modelo, diretório e modo ativo na barra |
| `session-brief.sh` | `SessionStart` | Avisa se a wiki já tem página sobre este diretório, quais são e quais agentes têm memória gravada. **Silencioso** em diretório sem histórico |
| `code-review-gate.sh` | `SessionStart` + `Stop` | `--baseline` grava o marco zero; no `Stop` compara e pede o review de sessão que tocou código |
| `review-voice-guard.sh` | `PreToolUse` (`Bash`) | Intercepta `gh pr comment`, `gh pr review`, `gh issue comment` e os `create`; nega assinatura de IA e citação sua em terceira pessoa |
| `librarian-inbox.sh` | `PostToolUse` (`Write\|Edit`) | Enfileira o que mudou, para a síntese do fim de sessão |
| `librarian-session-end.sh` | `Stop` | Bloqueia o encerramento e força a síntese do aprendizado para a wiki |
| `wiki-detect.sh` | chamado pelos outros | Resolve qual vault vale a partir do diretório da sessão |
| `sync-configs.sh` | `SessionStart` | Sincroniza `settings.json` entre WSL e Windows. Só serve se você usa os dois |

## Três coisas que só aparecem operando

**Hook sem `+x` falha em silêncio.** O sintoma é "o gate nunca dispara", e ninguém liga
isso ao bit de execução. O instalador aplica `chmod +x` e valida com `bash -n`.

**Config declarada não é config em vigor.** Linha no `settings.json` não prova que o hook
rodou. A evidência é linha no log:

```bash
tail -20 ~/.claude/logs/review-voice-guard.jsonl
```

**O `env` do `settings.json` vaza para o processo vivo** e não sai ao reverter o arquivo.
Depois de mexer nele, teste com `env -u VAR` ou em sessão nova — senão você testa o
estado errado e conclui o oposto.

## Por que o gate tem teto de bloqueio

O `code-review-gate` bloqueia no máximo 2x por sessão, e o teto é o que o mantém vivo: o
librarian também bloqueia no mesmo `Stop`. Os dois pedidos chegam juntos, e se o outro
ganha a primeira rodada, o `stop_hook_active` calaria o gate para sempre — o review
sumiria da sessão inteira.

## Por que o gate olha o git, e não o `changes.jsonl`

O sinal do `code-review-gate` é o `git` de propósito. Em modo automático a edição sai por
`sed` e heredoc pelo Bash, e nada disso passa por `Write|Edit`. Gate ancorado em
`PostToolUse` ficaria cego exatamente nas sessões mais longas.

## Testar

O guard de voz tem teste próprio, porque a lógica dele tem faixas e fronteira de palavra:

```bash
~/.claude/hooks/test-review-voice-guard.sh
```

Ele cobre as duas faixas (negar assinatura, deixar passar citação técnica), a checagem de
terceira pessoa com e sem `OWNER_NAME`, e o escopo — `gh` mencionado dentro de uma string
não pode ser interceptado.

## Desligar quando atrapalhar

```bash
CODE_REVIEW_GATE=0        # não pede review no fim da sessão
CODE_REVIEW_MIN_FILES=N   # piso de arquivos para acionar
REVIEW_VOICE_GUARD=0      # não intercepta gh (ainda loga)
LIBRARIAN_AUTOINGEST=0    # não força a síntese
LIBRARIAN_MIN_CHANGES=N   # piso de mudanças para acionar
```
