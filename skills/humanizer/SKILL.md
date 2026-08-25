---
name: humanizer
description: Use ao ESCREVER ou REVISAR prosa que vai ser lida por outra pessoa — copy de produto e landing page, README, documentação, changelog, release notes, post de blog, thread, e-mail, pitch, proposta comercial, descrição de app store, texto de onboarding, mensagem de erro voltada ao usuário. Remove o registro de texto gerado por IA: frases de encaixe, tricolon inflado, paralelismo mecânico, superlativo vazio, hedge, travessão decorativo, "não é apenas X, é Y", e o fecho que resume o que já foi dito. Também acione quando o pedido mencionar: humanizar, soa como IA, parece ChatGPT, tirar o cheiro de IA, deixar natural, revisar o texto, melhorar a copy, tom de voz, reescrever, texto robotizado, AI slop na escrita, editar prosa. NÃO use para: conversa de terminal com quem opera (isso é do caveman), commit e PR, código ou comentário de código, nome de variável, e nada que a skill `front` já cobra como slop visual.
license: MIT
version: 1.0.0
---

# /humanizer — prosa que não denuncia a máquina

Você não está "melhorando o texto". Está removendo um **registro** específico e reconhecível: o jeito que um modelo escreve quando escreve confortável. Esse registro tem assinatura, e a assinatura é o que faz um leitor pensar "isso foi a IA que escreveu" antes de julgar o conteúdo.

**Regra primária:** texto humano tem **ritmo irregular** e **compromisso**. Texto de IA tem ritmo uniforme e hedge. Se todas as frases têm o mesmo tamanho, ou se nenhuma afirma nada que possa estar errado, o problema é esse — não o vocabulário.

---

## 1. Escopo — onde esta skill vale e onde não

| Vale | Não vale |
|---|---|
| Copy de produto, landing, hero, CTA | Conversa de terminal → **caveman** |
| README, doc, changelog, release notes | Commit e PR → **caveman-commit** |
| Post, thread, newsletter | Código, comentário, identificador |
| E-mail, pitch, proposta | Slop **visual** → skill **front** |
| Onboarding, texto de erro para usuário | Texto jurídico/normativo onde a forma é obrigatória |

**Precedência com o caveman:** caveman comprime a conversa **no terminal**. Humanizer trabalha o que você **publica para outros**. Nunca aplique caveman ao entregável de prosa — o resultado fica telegráfico onde deveria ter voz. Se os dois parecerem aplicáveis, pergunte: quem vai ler isso? Se não é você, é humanizer.

---

## 2. As 12 assinaturas — o que apagar

**1. Frase de encaixe.** "Vale notar que", "é importante destacar", "no cenário atual", "em um mundo cada vez mais", "quando se trata de". Corte inteiro. Nenhuma delas carrega informação.

**2. O tricolon inflado.** Três itens paralelos de igual peso, sempre três, sempre no mesmo formato: "rápido, seguro e escalável". Humano escreve dois, ou quatro, ou um só com força. Se três é o número certo, quebre o paralelismo: "rápido, seguro, e — o que ninguém promete — depurável".

**3. "Não é apenas X, é Y."** Também: "mais que X, é Y", "não se trata de X, mas de Y". A construção mais marcada de todas. Escolha o que você quer dizer e diga.

**4. Superlativo sem medida.** "Revolucionário", "poderoso", "sem esforço", "de ponta", "incomparável", "robusto". Substitua por número, comparação ou nada: não "performance poderosa", mas "responde em 40 ms".

**5. Hedge empilhado.** "Pode potencialmente ajudar a talvez melhorar". Um hedge é honestidade; três é medo. Assuma a afirmação ou corte a frase.

**6. Travessão decorativo.** Um travessão por parágrafo longo, no máximo. IA usa travessão como respiração automática — vira tique visível. Ponto, vírgula e dois-pontos existem.

**7. O fecho que resume.** "Em resumo", "no fim do dia", "ao final", e o parágrafo final que repete os três pontos anteriores. Se o texto foi claro, o resumo insulta; se não foi, o resumo não salva. Termine na frase mais forte.

**8. Paralelismo mecânico.** Toda seção com a mesma estrutura, todo bullet começando com verbo no mesmo tempo, todo parágrafo com três frases. Estrutura visível demais lê como formulário.

**9. Voz passiva de fuga.** "Foram identificados problemas" → "achamos três bugs". Passiva esconde quem age; em copy de produto isso é sempre pior.

**10. Emoji como pontuação.** ✨ 🚀 🎯 no meio de frase séria. Não é caloroso, é ruído. (Bullet com emoji em README é convenção aceita; emoji no meio de frase não.)

**11. Definição não pedida.** "APIs, ou interfaces de programação de aplicações, permitem…". Se o leitor precisa da definição, ele não é o leitor. Escreva para quem você quer.

**12. Especificidade zero.** "Diversas empresas", "muitos usuários", "significativa melhoria". Substantivo vago é onde a IA se esconde. Número, nome, caso.

---

## 3. O que colocar no lugar

Apagar assinatura não gera voz. Voz vem de quatro coisas:

**Ritmo irregular.** Alterne. Frase de 4 palavras depois de uma de 25. Um fragmento. Leia em voz alta — se soar como metrônomo, quebre.

**Compromisso.** Diga algo que possa estar errado. "Acho que Postgres é a escolha certa aqui e vou defender isso" é humano; "Postgres pode ser uma boa opção dependendo do contexto" é ninguém. Opinião com risco é a assinatura mais humana que existe.

**Detalhe que só quem viveu tem.** Não "melhoramos a performance", mas "o dashboard levava 8 s para carregar e o time tinha desistido de usar". O detalhe específico é impossível de falsificar e é o que convence.

**Uma imperfeição deliberada.** Um aparte. Uma frase que começa com "E". Uma admissão do que não sabe. Perfeição de forma é o que denuncia — não erro de gramática (esse continua proibido), mas ausência total de textura.

---

## 4. Português brasileiro — as assinaturas locais

Tradução literal do registro inglês é o tell mais comum em pt-BR:

- **"Nós"** explícito onde o português dispensa: "Nós construímos" → "Construímos".
- **Gerundismo de futuro:** "vamos estar enviando" → "enviamos" / "vamos enviar".
- **"Você pode ser capaz de"** — calque de *you may be able to*. Em português: "dá para", "você consegue".
- **"Isso permite que você"** repetido em toda feature. Alterne, ou diga direto o que a pessoa faz.
- **"Solução"** como muleta para tudo. Nomeie a coisa: é um app, um script, um relatório?
- **"Poderoso", "robusto", "sem esforço"** soam mais artificiais em pt-BR que em inglês.
- **Formalidade errada:** "Prezado usuário", "Atenciosamente" em produto digital. Registro de ofício em UI é IA imitando formalidade.
- **Ordem rígida sujeito-verbo-objeto** em todas as frases. O português admite muito mais inversão — use.

---

## 5. Fluxo

**Escrevendo do zero:**
1. **Quem lê, e o que essa pessoa faz depois de ler?** Sem isso, o texto vira genérico por construção.
2. Escreva a frase mais forte primeiro. Ela costuma ser a abertura, e quase nunca é a que a IA escreveria primeiro.
3. Escreva o resto sem se policiar.
4. Aplique a §2 como passe de corte, e a §3 como passe de acréscimo.
5. **Leia em voz alta.** É o teste que pega tudo o que checklist não pega.

**Revisando texto existente:**
1. Marque cada assinatura da §2 com a numeração — não reescreva ainda.
2. Corte o que não carrega informação (costuma ser 20–30% do volume).
3. Onde havia hedge, decida: afirmar ou remover.
4. Onde havia vago, insira o específico — se não souber o dado, **pergunte**, não invente. Inventar número é pior que ser vago.
5. Quebre o ritmo uniforme.
6. Releia checando se **o significado sobreviveu**. Humanizar não é cortar conteúdo.

Ao entregar, diga em uma linha **o que mudou e por quê** (ex.: "cortei 3 tricolons e 2 hedges; troquei 'performance poderosa' por '40 ms'"), para quem lê poder discordar do critério, não só do resultado.

---

## 6. Limites honestos

- **Não invente fato, número, depoimento ou nome de cliente.** Copy convincente com dado falso é fraude, não redação. Falta dado → placeholder marcado e uma pergunta.
- **Não humanize texto que precisa de forma rígida:** contrato, política de privacidade, norma fiscal, mensagem de compliance.
- **Não confunda com "informal".** Um texto pode ser humano e formal. Registro é escolha do contexto; a assinatura de IA é defeito em qualquer registro.
- **Não existe detector confiável.** O objetivo é texto **bom**, que como efeito colateral não soa a máquina. Se você está escrevendo para enganar um detector em vez de para o leitor, o alvo está errado.

---

## Quick gate

- [ ] Nenhuma frase de encaixe, nenhum "não é apenas X, é Y"
- [ ] Nenhum tricolon reflexo; paralelismo quebrado ao menos uma vez
- [ ] Superlativo trocado por número, comparação ou nada
- [ ] Um hedge no máximo por parágrafo; o resto assumido ou cortado
- [ ] No máximo um travessão por parágrafo longo
- [ ] Sem parágrafo-resumo no fim; termina na frase mais forte
- [ ] Ritmo irregular — comprimentos variam, lido em voz alta
- [ ] Ao menos uma afirmação com risco e um detalhe específico e verificável
- [ ] pt-BR: sem gerundismo, sem "nós" redundante, sem calque de inglês
- [ ] Nenhum dado inventado; lacuna marcada como pergunta
