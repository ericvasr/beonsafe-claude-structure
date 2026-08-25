# Extract a design system — from a live site, a codebase, or an image

Load in Phase 2/3 quando o design **já existe em algum lugar** e precisa virar sistema: rebuild de produto legado, "deixe igual ao site atual mas melhor", herdar a marca de um app existente, ou converter um mockup em código.

`brand-asset-protocol.md` extrai **marca** (logo, cor canônica, tipografia oficial). `penpot-integration.md` extrai tokens de **arquivo de design**. Este cobre os três casos que sobram: **site rodando**, **codebase existente**, e **imagem**.

**Prime rule:** extraia o **sistema**, não a amostra. Vinte cinzas diferentes na página não são vinte tokens — são uma escala de 6 com 14 acidentes. Seu trabalho é decidir qual é qual.

---

## 1. De um site rodando (Playwright)

Ferramentas em `playwright-verification.md`. O fluxo:

**Passo 1 — colher os valores computados, não o CSS-fonte.** O CSS-fonte tem variável, cascata e morto; o computado é a verdade.

```js
// via browser_evaluate
() => {
  const seen = { color: {}, bg: {}, font: {}, size: {}, weight: {}, radius: {}, shadow: {}, space: {} };
  const bump = (b, v) => { if (v && v !== 'none' && v !== '0px' && !/rgba\(0, 0, 0, 0\)/.test(v)) b[v] = (b[v] || 0) + 1; };
  for (const el of document.querySelectorAll('body *')) {
    const s = getComputedStyle(el);
    bump(seen.color, s.color);
    bump(seen.bg, s.backgroundColor);
    bump(seen.font, s.fontFamily);
    bump(seen.size, s.fontSize);
    bump(seen.weight, s.fontWeight);
    bump(seen.radius, s.borderRadius);
    bump(seen.shadow, s.boxShadow);
    bump(seen.space, s.paddingTop); bump(seen.space, s.gap);
  }
  // ordenar por frequência: o topo é o sistema, a cauda é acidente
  return Object.fromEntries(Object.entries(seen).map(([k, v]) =>
    [k, Object.entries(v).sort((a, b) => b[1] - a[1]).slice(0, 14)]));
}
```

**Passo 2 — separar sistema de acidente.** Frequência é o sinal: um valor usado 200× é token; usado 1× é acidente ou caso especial. Colapse vizinhos (`#1a1a1a` e `#1b1b1b` são o mesmo token com um bug).

**Passo 3 — inferir a escala.** Ordene os espaçamentos e procure a base: múltiplos de 4 ou 8? Progressão geométrica na tipografia (1.2 / 1.25 / 1.333)? Se não houver escala nenhuma, **essa é a descoberta** — o sistema a construir é novo, e você está documentando o caos para substituí-lo.

**Passo 4 — converter cor para oklch.** Tokens em oklch (ver `color-system.md`), não em hex, para que lightness e chroma fiquem manipuláveis. Preserve o hex original como comentário para rastreabilidade.

**Passo 5 — capturar estado, não só repouso.** Hover, focus, active e disabled dos elementos-chave. Um DS sem estados é meia extração — e é aí que quase todo rebuild perde a identidade do original.

**Passo 6 — inventário de componente.** Screenshot em 1440/768/390 + lista dos padrões recorrentes (botão em N variantes, card, campo, nav, tabela). Isso é a fronteira de escopo do rebuild.

---

## 2. De uma codebase existente

```bash
# 1. A fonte da verdade já existe? Ache antes de inventar.
ls tailwind.config.* theme.* tokens.* design-system/ 2>/dev/null
grep -rl "createTheme\|styled-components\|@theme\|:root" src/ --include=*.{ts,tsx,css,js} | head

# 2. Variáveis CSS declaradas
grep -rhoP '^\s*--[a-z0-9-]+\s*:\s*\K[^;]+' src/ --include=*.css | sort | uniq -c | sort -rn | head -30

# 3. Valores hardcoded — a dívida do sistema
grep -rhoE '#[0-9a-fA-F]{3,8}' src/ --include=*.{css,tsx,ts} | sort | uniq -c | sort -rn | head -20
```

Leia nesta ordem: **config de tema → variáveis CSS → valores hardcoded**. A distância entre o primeiro e o terceiro é a dívida. Se há 40 hex hardcoded e 6 tokens, o sistema existe no papel e não na prática — reporte isso, é achado de arquitetura, não detalhe.

Cuidado com o falso positivo mais comum: `tailwind.config.js` sem `theme.extend` customizado significa que o "sistema" é o default do Tailwind. Aí não há DS próprio a extrair — há um a criar.

---

## 3. De uma imagem (screenshot, mockup, foto de whiteboard)

Claude Code lê imagem nativamente: leia o arquivo e trabalhe do que está visível. O erro aqui é pular direto para o markup.

**Ordem obrigatória — estrutura antes de estilo:**

1. **Grid e layout.** Quantas colunas? Onde quebra? O que é container e o que é conteúdo? Erre isso e todo o resto fica torto.
2. **Hierarquia tipográfica.** Meça as **proporções** entre tamanhos, não os pixels absolutos — a imagem pode estar em qualquer escala. Se o título é 3× o corpo, a razão é o dado.
3. **Espaçamento.** Meça em unidades relativas ao ritmo, e infira a base (4/8 px).
4. **Cor.** Amostre e converta para oklch. **Nunca adivinhe de memória.** Se a imagem tem compressão, agrupe tons vizinhos.
5. **Tipografia.** Identifique a *categoria* (geométrica sem-serifa, grotesca, serifa de transição, mono) e escolha uma face real disponível. Chutar "é Inter" é o caminho do slop (ver `anti-patterns.md`).
6. **Estados ausentes.** A imagem mostra repouso. Hover, focus, loading, empty, error **não estão lá** e são obrigatórios de qualquer forma (`ux-interaction.md`).

Duas honestidades sobre imagem→código:
- **O que a imagem não mostra é metade do trabalho:** comportamento responsivo, motion, estados, acessibilidade. Entregar só o repouso pixel-perfect é entregar 50%.
- **Fidelidade pixel-perfect é frequentemente o alvo errado.** Se o mockup tem um problema (contraste ruim, hierarquia fraca, alvo de toque pequeno), copiar fielmente propaga o defeito. Aponte e proponha.

---

## 4. Saída — o formato do DS extraído

```markdown
## Design System extraído — [origem]

### Procedência
- Fonte: [URL / repo path / arquivo de imagem]
- Método: [computed styles via Playwright | leitura de config | amostragem de imagem]
- Confiança: alta (computado) | média (config + hardcoded) | baixa (imagem comprimida)

### Tokens
Cor:       [role → oklch(...)  /* hex original */]
Tipo:      display / body / mono + escala e razão detectada
Espaço:    base [4|8]px, escala [...]
Raio:      [...]
Sombra:    [...]

### Estados capturados
[elemento: default / hover / focus / active / disabled]

### Inventário de componente
[componente: variantes encontradas]

### Acidentes descartados
[valor: ocorrências — motivo de não ser token]

### Lacunas
[o que a origem não define e precisa de decisão: estados, dark mode, motion, breakpoints]
```

A seção **Lacunas** é a mais importante e a mais omitida. É o que diferencia "copiei o que vi" de "entendi o sistema e sei onde ele é omisso".

---

## 5. Depois de extrair — o DS não é a direção

Sistema extraído é **restrição**, não direção. Ele diz o que é consistente com o que já existe; não diz se o resultado é bom. Continue pela Fase 3 normal:

- O DS extraído entra como restrição no prompt de DNA (`SKILL.md` Fase 3 §5).
- O Stranger Test (Fase 5) continua valendo. Herdar um sistema genérico e reproduzi-lo fielmente entrega um resultado genérico — e aí a extração serviu para documentar o problema, não para justificá-lo.
- Se a origem é BLOCK de licença (ver `source-registry.md`), extrair **tokens** é diferente de copiar **código**: cor, escala e proporção não são protegidas por licença de software; o código do componente é.

---

## Quick gate

- [ ] Valores vieram de computed style / config real, não de leitura do CSS-fonte
- [ ] Sistema separado de acidente por frequência; vizinhos colapsados
- [ ] Escala base inferida (ou registrada a ausência dela como achado)
- [ ] Cor em oklch com hex original preservado
- [ ] Estados capturados, não só repouso
- [ ] Procedência e nível de confiança declarados
- [ ] Seção de Lacunas preenchida
- [ ] Licença checada quando a origem é de terceiro (token ≠ código)
