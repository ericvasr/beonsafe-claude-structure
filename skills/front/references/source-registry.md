# Source registry — onde olhar, e o que a licença de cada fonte exige

Load in Phase 2 (Discover). `SKILL.md` §Phase 2 lista galerias para *julgar qualidade*;
este arquivo lista fontes de **implementação** e traz, para cada uma, o link direto da
licença e a obrigação que ela cria.

**Este arquivo não barra nada.** Ele reúne a evidência — onde a licença está escrita e o
que ela exige — para que a decisão seja tomada por quem carrega o risco. Restrição de
licença é decisão de organização, não de skill: cada empresa tem uma tolerância, e essa
tolerância mora na política interna dela, nunca aqui.

O que a skill deve fazer, sempre: **dizer de onde veio e apontar o link**. Uma linha na
entrega, com a fonte e a licença, resolve o problema real — que é conteúdo entrar sem
ninguém saber a origem.

---

## 1. Como usar uma fonte — três modalidades, três exposições

| Modalidade | Exposição | Obrigação real |
|---|---|---|
| **Inspiração** — ver o efeito, reimplementar com código próprio | ~zero. Aparência e interação de UI não são cobertas por licença de software | nenhuma |
| **Dependência npm** | baixa e auditável. A licença viaja no pacote; `license-checker` audita | manter a dep declarada |
| **Copy-paste do componente** | máxima. Você assume a licença do trecho | **preservar o aviso de copyright** — é a única obrigação da MIT e a mais violada por copy-paste de UI kit |

Regra prática: **prefira dependência a cópia**, e cópia sempre com
`THIRD-PARTY-NOTICES.md` no produto. Onde a licença restringe uso comercial, a rota de
menor obrigação é inspiração.

---

## 2. Registries de componente e efeito

Datas de verificação em 2026-07-26. Projeto relicencia — **abra o link antes de usar**,
porque esta tabela envelhece e a fonte não avisa.

| Fonte | O que tem | Licença | Onde está escrito | O que isso exige |
|---|---|---|---|---|
| [daisyui.com](https://daisyui.com) | componentes Tailwind semânticos, temas | MIT | [LICENSE](https://github.com/saadeghi/daisyui/blob/master/LICENSE) | aviso de copyright na cópia; dependência dispensa |
| [kokonutui.com](https://kokonutui.com) | componentes React/Tailwind com motion | MIT | [repo](https://github.com/kokonut-labs/kokonutui) | aviso de copyright na cópia |
| [bklit.com](https://bklit.com) | UI kit React | MIT | site/repo do projeto | aviso de copyright na cópia |
| [motion.dev](https://motion.dev) | a lib + exemplos | MIT (core) | [LICENSE.md](https://github.com/motiondivision/motion/blob/main/LICENSE.md) | Motion+ é produto comercial separado — confira o que você está usando |
| [animejs.com](https://animejs.com) | timeline JS leve | MIT | [LICENSE.md](https://github.com/juliangarnier/anime/blob/master/LICENSE.md) | aviso de copyright na cópia |
| [reactbits.dev](https://reactbits.dev) | efeitos React de alto impacto | MIT **+ Commons Clause** | [LICENSE](https://github.com/DavidHDev/react-bits/blob/main/LICENSE) | a cláusula restringe **vender** produto cujo valor derive substancialmente da funcionalidade do software, e restringe sublicenciar, redistribuir e portar os componentes. Uso interno e inspiração ficam fora do alcance dela. Leia a cláusula antes de embutir num produto que cobra |
| [originkit.dev](https://www.originkit.dev) | componentes via MCP | **não declarada** nos componentes; MCP é MIT | site do projeto | sem licença declarada, o default legal é all rights reserved — "Free" não é licença. A ferramenta MCP tem licença própria e é caso separado |
| [particles.casberry.in](https://particles.casberry.in) | gerador de partículas | **não declarada** (403 na verificação) | — | sem grant expresso, o output é presumido all rights reserved. Peça permissão ou reimplemente |
| [codepen.io](https://codepen.io) | pens soltos | varia **por pen** | rodapé do pen | pen público sai como MIT pelos termos do CodePen; pen privado, não. Confira o pen específico |
| [21st.dev](https://21st.dev) | registry de componentes + Magic MCP | não verificada | site do projeto | verifique antes. **Não confundir com `github.com/21-DOT-DEV`**, que é org Swift/cripto sem relação com design |

**Armadilha registrada:** `21-DOT-DEV/swift-berkeleydb` vendoriza BDB 4.8 = **Sleepycat**,
copyleft forte que exigiria abrir o código do produto inteiro. MIT no wrapper não vale
para o upstream que ele embute. E `BSL-1.0` (Boost, permissiva) **não é** `BUSL-1.1`
(Business Source, com restrição de uso em produção).

---

## 3. Galerias — julgar qualidade, nunca copiar

Sem coluna de licença porque não se tira código de lá: servem para calibrar o alvo na
Fase 2 e para nomear anti-referências.

- **Awwwards**, **Godly.website**, **Minimal.gallery**, **Land-book**, **Siteinspire**,
  **One Page Love** — direção e execução de landing.
- **Mobbin**, **Screensdesign** — padrões de produto real (registro Product, não Brand).
- **Refero**, **SaaS Landing Page** — convenções por categoria; útil sobretudo para saber
  o que **evitar** (a média da categoria é o inimigo, ver `SKILL.md` Stranger Test).

Use cada referência nomeando **o que você está pegando dela** — estrutura, estratégia de
cor, personalidade tipográfica, um detalhe memorável. "Gostei desse site" não é
referência.

---

## 4. Assets

| Tipo | Fontes | Licença típica | O que conferir |
|---|---|---|---|
| Ícones | Phosphor, Lucide, Radix Icons, Heroicons | MIT / ISC | nunca emoji como ícone de UI, ver `anti-patterns.md` |
| Tipografia | Google Fonts, Fontshare, Fontsource | OFL / Apache | se o **peso variável** está incluído |
| Foto | `picsum.photos/seed/<n>/<w>/<h>` para placeholder; asset real em produção | — | nunca hotlink de Unsplash |
| Modelo 3D | Poly Haven (CC0), Quaternius (CC0), Sketchfab (varia) | ver `webgl-3d.md` §0 | NC e SA mudam o que você pode entregar a cliente |
| HDRI | Poly Haven | CC0 | — |
| Som/BGM | ver `motion-pipeline.md` §D-F | varia | uso comercial explícito |

Fonte tipográfica é onde mais se erra: "grátis no Google Fonts" não implica que a versão
baixada de outro lugar tenha a mesma licença.

---

## 5. Fluxo na Fase 2

1. Buscar 3–5 referências **específicas** (site nomeado, não categoria) e anotar o que
   pegar de cada.
2. Nomear 3+ anti-referências explícitas.
3. Se for usar componente ou lib de terceiro: **abrir o link da licença nesta tabela** e
   anotar a obrigação. Fonte que não está aqui → `security-auditor` levanta a evidência.
4. Marca própria → `brand-asset-protocol.md` (cor sai do SVG do logo, nunca da memória).
5. Extrair DS de produto existente → `extract-design-system.md`.

---

## Quick gate

Não é aprovação — é a checagem de que a evidência está na mesa e viajou junto com a
entrega.

- [ ] Toda fonte de código usada tem **link da licença** anotado
- [ ] O que a licença exige está escrito ao lado, não subentendido
- [ ] Copy-paste levou o aviso de copyright para `THIRD-PARTY-NOTICES.md`
- [ ] Dependência preferida a cópia onde havia pacote npm
- [ ] Uso comercial conferido onde a licença o condiciona
- [ ] Referências nomeadas com "o que estou pegando", e 3+ anti-referências

Decisão de aceitar ou recusar uma licença é da organização que assume o risco, e o
registro dela vive na política interna — não neste arquivo, nem num repositório público.
