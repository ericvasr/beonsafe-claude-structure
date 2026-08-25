# Procedência

`skills/front/` é uma composição. A orquestração, a árvore de decisão e a maior parte dos
arquivos de referência são escritos do zero; uma parte do conteúdo consolida conceitos de
quatro projetos de terceiros, todos com licença permissiva confirmada. Este arquivo diz o
que veio de onde.

Auditoria de licença em 2026-08-25: SPDX resolvido pelo campo `license` da API do GitHub e
conferido contra o `LICENSE` de cada repositório.

## Licença desta composição

MIT (ver `../../LICENSE`). As condições das licenças de origem continuam valendo sobre as
partes derivadas de cada fonte, conforme descrito abaixo.

## Nenhuma cópia literal

Comparação linha a linha contra o upstream das quatro fontes não encontrou nenhuma linha
idêntica. O conteúdo derivado é reescrito — e no caso do huashu-design, também traduzido
do chinês. Ainda assim a atribuição é dada integralmente, porque derivação de conceito e
de estrutura existe.

A medição tem um ponto cego que vale nomear: comparação de linhas não detecta paráfrase
próxima nem tradução. Como o huashu é escrito em chinês, o zero ali estava garantido pela
língua, não pela originalidade — e tradução é obra derivada. Por isso a atribuição é dada
do mesmo jeito.

---

## 1. pbakaus/impeccable — Apache-2.0

```
Copyright 2025 Paul Bakaus

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

Origem: https://github.com/pbakaus/impeccable
Cópia integral da licença: [`../../licenses/Apache-2.0.txt`](../../licenses/Apache-2.0.txt)

**Onde entra:** `references/impeccable-commands.md` (paleta de 23 comandos),
`references/anti-patterns.md` (regras determinísticas),
`references/playwright-verification.md` (rubrica 5D).

**Declaração de modificação (Apache-2.0 §4-b):** esses arquivos são modificados em
relação à obra original. Os comandos foram recortados, reescritos e reorganizados como
templates de workflow; nenhum texto do original foi copiado.

**Avisos do NOTICE original (Apache-2.0 §4-d).** O impeccable distribui um `NOTICE.md`
cujo conteúdo é reproduzido aqui:

```
# Third-Party Notices

This project includes content derived from third-party work, used under the
terms of its original license.

## Platform Design Skills

The `skill/reference/ios.md` and `skill/reference/android.md` platform
reference files are distilled from ehmo's `platform-design-skills` (Apple
Human Interface Guidelines and Material Design 3 rules), rewritten in
Impeccable's voice.

**Original work:** https://github.com/ehmo/platform-design-skills
**Original license:** MIT
**Author:** ehmo
```

Os arquivos `ios.md` e `android.md` não são usados nesta composição; o aviso é reproduzido
por completude.

"Impeccable" é nome do projeto de origem e aparece aqui em uso descritivo. A Apache-2.0 §6
não concede direito de marca, e nenhum endosso é sugerido.

---

## 2. Leonxlnx/taste-skill — MIT

```
MIT License

Copyright (c) 2026 Leonxlnx

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

Origem: https://github.com/Leonxlnx/taste-skill

**Onde entra:** `references/taste-dials.md` (dials paramétricos DESIGN_VARIANCE /
MOTION_INTENSITY / VISUAL_DENSITY), `references/motion-pipeline.md` (doutrina de
micro-interação perpétua), `references/anti-patterns.md` (padrões proibidos).

---

## 3. alchaincyf/huashu-design — MIT

```
MIT License

Copyright (c) 2026 alchaincyf (花叔 · 花生)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

Origem: https://github.com/alchaincyf/huashu-design

**Onde entra:** `references/design-philosophies.md` (biblioteca de escolas de design),
`references/brand-asset-protocol.md` (Core Asset Protocol v1.1),
`references/motion-pipeline.md` (stage + sprite + interpolate, pipeline de BGM/SFX),
`references/anti-patterns.md` (lista anti-AI-slop).

O material de origem é escrito em chinês. O conteúdo aqui é traduzido, comprimido e
reescrito.

---

## 4. nextlevelbuilder/ui-ux-pro-max-skill — MIT

```
MIT License

Copyright (c) 2024 Next Level Builder

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

Origem: https://github.com/nextlevelbuilder/ui-ux-pro-max-skill

**Onde entra:** `references/ui-styles-catalog.md` (mapeamento estilo × produto),
`references/color-system.md` (paletas curadas), `references/typography-system.md`
(pareamentos tipográficos), `references/anti-patterns.md` (anti-padrões por indústria).

---

## Conteúdo autoral

Escritos do zero, sem derivação das fontes acima: `SKILL.md`,
`references/execution-patterns.md`, `references/page-architecture.md`,
`references/webgl-3d.md`, `references/motion-libs.md`,
`references/extract-design-system.md`, `references/interaction-craft.md`,
`references/ux-interaction.md`, `references/penpot-integration.md`,
`references/source-registry.md`, `references/repertorio.md`,
`references/workflow-templates.md`.

Agregado: cerca de 72% autoral, 28% derivado em conceito, 0% em expressão literal.

## Ferramentas citadas, não redistribuídas

`references/playwright-verification.md` e `references/penpot-integration.md` descrevem
como acionar Playwright e Penpot. Nenhum código dessas ferramentas é incluído aqui.

`references/source-registry.md` e `references/webgl-3d.md` listam fontes de componente e
de asset com uma avaliação de licença de cada uma, para decidir se podem ser usadas. São
avaliações factuais sobre projetos de terceiros, feitas na data indicada em cada tabela, e
não incluem código nenhum dessas fontes. Não são parecer jurídico — confira a licença na
origem antes de usar qualquer uma, porque projeto relicencia e a tabela envelhece.
