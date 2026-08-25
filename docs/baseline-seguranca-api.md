# Baseline de segurança de API e sessão

Vale para **toda API escrita sob esta configuração ou revisar**, em qualquer produto. Não é
checklist de auditoria — é premissa de escrita: cada item abaixo é decidido **antes**
do primeiro endpoint, porque todos eles custam minutos no início e viram migração,
invalidação de sessão em massa ou incidente depois.

Ordem de leitura para quem implementa: §1 primeiro, sempre. É a única que não tem
mitigação retroativa barata.

---

## 1. Injeção — resolvida na escrita, nunca depois

**Invariante:** nenhuma string de entrada participa da construção de uma query.
Sempre query parametrizada / prepared statement / binding do ORM.

Não vale "eu escapo": escape é opt-in e a primeira query escrita com pressa não tem.
Parametrização é a única forma que falha fechada por construção.

- Identificador que precisa ser dinâmico (nome de tabela, coluna, direção de `ORDER BY`)
  **não é parametrizável** — resolva por lista fechada (`allowlist`), nunca por
  interpolação.
- Vale igual para NoSQL (operador vindo do cliente: `{"$ne": null}` como senha),
  para shell (`exec` com argumento do usuário) e para LDAP.
- Mesma regra na camada de LLM: saída de modelo que vira SQL ou shell é injeção com
  outro nome (OWASP LLM05).

**Como verifico:** grep por concatenação em query (`+ req.`, template string com
`${`, f-string com variável de request) e por `raw`/`query(` sem array de parâmetros.

## 2. Rate limit e lockout — em todos os escopos

**Invariante:** todo endpoint tem limite. Ausência de limite é decisão, e precisa ser
declarada por escrito, não acontecer por omissão.

Escopos que precisam de contador **separado** — limitar só por IP não protege nada
atrás de NAT ou CDN:

| Escopo | Por quê |
|---|---|
| por IP | ataque distribuído barato |
| por conta / e-mail | força bruta focada num alvo, de muitos IPs |
| por token / API key | cliente legítimo em loop |
| global no endpoint caro | proteger o banco, não o usuário |

**Lockout** em autenticação: bloqueio progressivo (atraso exponencial) em vez de
bloqueio duro, senão o lockout vira o próprio DoS — quem souber o e-mail derruba a
conta. Desbloqueio por tempo, e o contador zera **só em login bem-sucedido**.

Endpoints que sempre precisam de limite próprio, mais estrito: login, refresh de token,
recuperação de senha, verificação de código, upload, busca, qualquer coisa que gere
e-mail ou SMS.

## 3. Enumeração de usuário

**Invariante:** resposta idêntica para "não existe" e "existe com credencial errada" —
mesmo corpo, mesmo status, **mesmo tempo**.

Os três vazamentos, na ordem em que são esquecidos:

1. **Mensagem** — "e-mail não cadastrado" vs "senha incorreta". Use uma só.
2. **Status/código** — 404 num caso e 401 no outro.
3. **Tempo** — o caminho "usuário não existe" retorna antes porque pula o hash. Faça o
   hash mesmo assim, contra um hash dummy, ou normalize o tempo de resposta.

Vale também em cadastro ("e-mail já em uso") e em recuperação de senha — que deve
responder o mesmo texto sempre, e mandar e-mail só se existir.

## 4. Token e sessão

**Invariante:** token nunca trafega em URL, e logout invalida do lado do servidor.

- **Nunca em query string.** URL vai para log de acesso, histórico do navegador,
  `Referer` de recurso externo, e para o print que o usuário manda no chat. Token vai
  em header `Authorization` ou cookie `HttpOnly`; nunca em `GET /x?token=`.
- **Logout invalida de verdade.** JWT stateless não é revogável por definição — se o
  produto precisa de logout (precisa), existe estado do lado do servidor: lista de
  revogação por `jti`, versão de sessão no usuário, ou sessão opaca em store. Apagar
  o token só do cliente é logout de fachada.
- **Invalidar em massa** quando: troca de senha, troca de e-mail, mudança de papel,
  suspeita de comprometimento. Campo `token_version` no usuário resolve os quatro com
  um incremento.
- **Expiração curta + refresh rotativo.** Refresh usado duas vezes é sinal de roubo:
  invalide a família inteira.
- Cookie: `HttpOnly`, `Secure`, `SameSite=Lax` no mínimo, `__Host-` quando possível.

## 5. CORS

**Invariante:** allowlist explícita de origens. `*` só é aceitável em API pública
sem credencial e sem dado por usuário.

- `Access-Control-Allow-Origin: *` **junto com** `Allow-Credentials: true` é rejeitado
  pelo navegador — quem "resolve" isso refletindo o `Origin` recebido criou um wildcard
  com credencial, que é pior que o erro original.
- Refletir `Origin` sem validar contra a allowlist é o bug mais comum, e é equivalente
  a não ter CORS.
- Validar a origem **inteira**, com igualdade: `startsWith` deixa passar
  `https://meusite.com.evil.tld`.
- CORS não é autorização. Ele protege o navegador de terceiros, não a API de um `curl`.
  Toda regra de acesso precisa existir no servidor de qualquer forma.

## 6. A API devolve mais do que devia

**Invariante:** a resposta é montada por lista do que **entra**, nunca por remoção do
que sai.

- Serializar o objeto do banco inteiro e deletar campos é frágil: o campo novo da
  próxima migration entra na resposta sozinho. Monte um DTO explícito.
- Vazamentos clássicos: hash de senha, token de reset, `internal_notes`, e-mail de
  outra pessoa em lista, `stack trace` em erro de produção, IDs sequenciais que
  permitem varrer a base.
- Erro de produção devolve mensagem genérica e um id de correlação; o detalhe vai
  para o log, não para o cliente.
- Endpoint de listagem: paginação obrigatória e teto de página. Sem teto,
  `?limit=999999` é exfiltração com status 200.

## 7. Criptografia

**Invariante:** biblioteca padrão da plataforma, algoritmo atual, chave fora do código.

- Senha: `argon2id` (preferido) ou `bcrypt`. **Nunca** SHA-* puro, com ou sem salt.
- Comparação de segredo com função de tempo constante (`hmac.compare_digest`,
  `crypto.timingSafeEqual`) — `==` vaza o prefixo correto pelo tempo.
- Em trânsito: TLS obrigatório, inclusive entre serviços internos. "É rede interna"
  não é modelo de ameaça, é esperança.
- Em repouso: cifrar o que é PII e segredo de terceiro. Chave em KMS ou variável de
  ambiente, com rotação declarada.
- Nunca invente esquema. Sem AES-ECB, sem IV fixo, sem cifra caseira.

## 8. SLI, SLO e error budget

**Invariante:** quatro SLIs por produto, mensuráveis com o que já existe, com orçamento
de erro e consequência declarada.

Sem isso, "criar alerta" não tem critério e todo alerta vira ruído — e ruído é a razão
pela qual um alerta real passa despercebido. O SLO é o que transforma a pergunta de
"está parado?" em "está fora do orçamento?".

**Padrão fixado, igual em todos os produtos** — porque uniformidade é o que permite
compará-los na mesma tabela:

| # | SLI | Fonte | Meta | Orçamento em 28d |
|---|---|---|---|---|
| 1 | Disponibilidade | `probe_success`, `/healthz`, `systemctl is-active` | 99,5% | 3h 21min |
| 2 | **Frescor** | `agora − max(ts)` por caminho de coleta | 95% das janelas | 33,6h fora de cadência |
| 3 | Latência | p95 de `probe_duration` ou duração de request | p95 < 1s | — |
| 4 | Taxa de erro | 5xx/total ou jobs falhados/total | < 1% | 1% das requisições |

Janela: **28 dias deslizantes**, não mês-calendário — a virada de mês zera orçamento
por acidente de calendário, não por melhora real.

**Consequência: orçamento estourado congela trabalho novo naquele produto** até
recuperar. Correção que restaura o SLI e trabalho de confiabilidade seguem liberados.
Congelamento é por produto, não global. SLO sem consequência declarada é enfeite.

O **Frescor** é o que fecha a lacuna que causou três ingests mortos: disponibilidade
de 99,5% com a tabela parada há 60 dias é um estado possível, e foi o estado real —
três `/healthz` respondendo 200.

Produto sem métrica não sai da tabela: o SLI vira `POR CONSTRUIR` explícito, com a
fonte mais barata de habilitar ao lado. Omitir é como um produto fica sem ninguém
olhando.

Quem acompanha: agente `slo-keeper`.

---

## Como isso é cobrado

- **Ao escrever API:** `dev-fullstack` trata os itens 1 a 7 como premissa de desenho,
  não como revisão posterior. Item 1 nunca é adiado.
- **Ao revisar:** `security-auditor` percorre esta baseline além do OWASP Top 10 e do
  OWASP LLM Top 10, e classifica ausência de item como achado — **ausência de limite,
  de CORS ou de invalidação de sessão é achado, não é "não implementado ainda"**.
- **Ao desenhar observabilidade:** `infra-sre` cobra o item 8 antes de propor alerta.

Item ausente com justificativa escrita é decisão. Item ausente em silêncio é dívida
que ninguém sabe que tem.
