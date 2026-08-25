---
name: threejs
description: Use ao construir, depurar ou otimizar cena 3D e WebGL com Three.js — partículas, campo de pontos, shader material, GLTF, câmera, luz, post-processing, InstancedMesh, dispose, queda de FPS, canvas em branco, cena que "não aparece". Também acione quando o pedido mencionar three.js, WebGL, shader, GLSL, vertex/fragment, r3f, react-three-fiber, drei, partículas 3D, modelo .glb, bloom, raycaster, ou quando alguém colar código de cena para revisar. NÃO use para animação 2D (isso é `motion` ou `gsap`), nem para decidir SE vale ter 3D na página (isso é `front`, references/webgl-3d.md, que tem o gate de asset e de licença).
license: MIT
version: 1.0.0
---

# /threejs — cena que roda, não demo que trava

Três coisas matam cena 3D na web, nesta ordem: **asset ruim**, **fill rate** e **falta de dispose**. Nenhuma delas é sobre saber a API. Quem sabe a API e ignora as três entrega algo que parece brinquedo, esquenta o celular e vaza memória ao trocar de rota.

**Antes de escrever a primeira linha**, dois gates que não são desta skill e vêm antes dela:

- Forma orgânica (animal, rosto, personagem, mascote) **não se esculpe em código**. Vem de artista ou de IA text-to-3D. Geometria primitiva composta — grid, partículas, cristal, terreno, formas arquitetônicas — é onde código à mão funciona. Regra e tabela de licença de asset: `front/references/webgl-3d.md` §0.
- `three` custa ~130–180 KB gzip. Se o efeito desejado é parallax, tilt ou card 3D, **CSS `transform-style: preserve-3d` faz de graça**.

---

## 1. O diagnóstico que quase ninguém faz: é fill ou é contagem?

Medido numa cena real de 45 mil partículas, em renderização por software:

| Partículas | FPS |
|---|---|
| 20.000 | 29,9 |
| 26.000 | 29,9 |
| 30.000 | 20,0 |
| 45.000 | 20,0 |

A página **sem** a cena rodava a 30,0. E o teste que decidiu tudo: **com um quarto dos pixels (720×450), 60 FPS travado com e sem a cena**.

Isso separa as duas causas possíveis, e elas pedem correções opostas:

```
Reduzir a resolução do canvas melhora muito?  → FILL RATE. Ataque tamanho de ponto,
                                                 overdraw, blending, post-processing.
Reduzir a CONTAGEM melhora, o tamanho não?    → VÉRTICE/DRAW. Ataque número de objetos,
                                                 instancing, merge de geometria.
```

No caso acima a resposta foi contagem: baixar o teto de `gl_PointSize` de 22px para 14px **não mudou nada**, tirar 4 mil partículas mudou 10 FPS. Eu tinha apostado no tamanho e estava errado — por isso se mede antes de otimizar.

Como medir, sem ferramenta externa:

```js
// FPS mediano por rAF, com e sem a cena, no mesmo viewport
const amostra = await new Promise(res => {
  const q = []; let last = performance.now(); let n = 0;
  const tick = now => { q.push(now - last); last = now; ++n < 300 ? requestAnimationFrame(tick) : res(q.slice(5)); };
  requestAnimationFrame(tick);
});
const ordenado = [...amostra].sort((a, b) => a - b);
console.log('fps', 1000 / ordenado[ordenado.length >> 1], 'p95', ordenado[Math.floor(ordenado.length * .95)]);
```

Depois repita com `canvas.style.display = 'none'`. A diferença é o custo real da cena, não a impressão.

**Headless não tem GPU.** Chrome headless roda SwiftShader (CPU): serve como **piso** e para comparação relativa, nunca como número de produção. Diga isso ao reportar, em vez de apresentar 20 FPS como se fosse o que o usuário vê.

---

## 2. Partículas: o que faz parecer poeira e não bolha

O erro comum é ponto grande com alfa alto. Lê como bolha, pesa e come fill rate. O peso visual vem do **acúmulo**: muitos pontos pequenos com `AdditiveBlending`.

```js
const mat = new THREE.ShaderMaterial({
  transparent: true,
  depthWrite: false,               // sem isto, additive briga com o z-buffer
  blending: THREE.AdditiveBlending,
  uniforms: { uTempo: { value: 0 } },
  vertexShader: /* glsl */`
    attribute float aSemente;
    uniform float uTempo;
    void main() {
      vec3 pos = position;
      vec4 mv = modelViewMatrix * vec4(pos, 1.0);
      gl_Position = projectionMatrix * mv;
      // TETO OBRIGATÓRIO: a partícula que passa raspando pela câmera tem
      // -mv.z perto de zero e o ponto explode para centenas de pixels.
      gl_PointSize = min(140.0 / -mv.z, 20.0);
    }`,
  fragmentShader: /* glsl */`
    void main() {
      float d = length(gl_PointCoord - 0.5);
      if (d > 0.5) discard;                       // sem isto o ponto é quadrado
      float halo   = smoothstep(0.5, 0.0, d) * 0.22;
      float nucleo = smoothstep(0.16, 0.0, d);    // núcleo duro + halo largo
      gl_FragColor = vec4(vec3(1.0) * (0.5 + nucleo), (halo + nucleo));
    }`,
});
```

Núcleo duro dentro de halo largo **no mesmo ponto** é o que imita bloom sem post-processing. `UnrealBloom` em full-res custa ~20 KB e um passe de tela inteira; quase nunca vale numa landing.

**Anime no vertex shader, não na CPU.** Um ciclo por partícula sai de `fract(aSemente + uTempo * velocidade)`: a semente entra na *fase*, então nada chega em levas sincronizadas e o wrap não guarda estado. Com isso, 26 mil partículas custam o mesmo trabalho de CPU que 2 mil — zero.

Detalhes que denunciam amadorismo:

- **Distribuição.** Ponto aleatório em disco precisa de `sqrt(random())` no raio; em volume, `cbrt`. Sem isso o miolo fica denso e a borda vazia.
- **Fade no nascimento e na morte.** Partícula que dá a volta sem fade pisca.
- **Oscilação senoidal no tempo faz a partícula ir e voltar.** Se o pedido é "sentido único", a direção tem que ser fixa por partícula (sorteada da semente), e a câmera não pode respirar em seno — o conjunto inteiro passa a parecer que vibra.

---

## 3. Cena que "não aparece": a lista de causas, em ordem de frequência

1. **Canvas com 0 de altura.** `height: auto` num canvas sem atributo resolve para 150px ou zero. Meça `canvas.getBoundingClientRect()` antes de culpar o WebGL.
2. **Câmera dentro do objeto**, ou `near`/`far` cortando a cena.
3. **`MeshStandardMaterial` sem luz e sem `scene.environment`** → preto. `MeshBasicMaterial` ignora luz e sempre lê flat.
4. **Escala.** Objeto de 0,01 unidade com câmera a 100. Cheque `new THREE.Box3().setFromObject(obj)`.
5. **Alfa/blending** com `depthWrite: true` escondendo tudo atrás.
6. **`renderer.setSize` nunca chamado** depois do primeiro layout.

---

## 4. Ciclo de vida: gate de entrada, pausa e dispose

```js
// Gate: 3D só para quem tem tela, máquina e vontade. Fora disso, o fallback
// estático (que já é o fundo da seção) permanece — não existe buraco.
const passa =
  matchMedia('(min-width: 64rem)').matches &&
  !matchMedia('(pointer: coarse)').matches &&              // `pointer: fine` reprova
  matchMedia('(prefers-reduced-motion: no-preference)').matches &&  // headless e TV reportam `none`
  (navigator.hardwareConcurrency ?? 8) >= 4 &&
  !!document.createElement('canvas').getContext('webgl2');

if (passa) {
  const iniciar = () => import('./cena').then(({ montar }) => montar(canvas));
  'requestIdleCallback' in window
    ? requestIdleCallback(iniciar, { timeout: 2500 })       // depois da primeira pintura: o herói é o LCP
    : addEventListener('load', () => setTimeout(iniciar, 400), { once: true });
}
```

Pausa quando sai de vista **e** quando a aba esconde — as duas coisas, com uma flag para não religar fora da viewport:

```js
let visivel = false;
const io = new IntersectionObserver(([e]) => {
  visivel = e.isIntersecting;
  visivel && !document.hidden ? ligar() : desligar();
});
document.addEventListener('visibilitychange', () => (document.hidden ? desligar() : visivel && ligar()));
```

Tempo próprio com delta limitado, senão voltar de uma pausa salta o ciclo inteiro:

```js
t += Math.min(relogio.getDelta(), 0.05);
```

Dispose de tudo o que aloca GPU, no unmount: `geometry`, `material`, cada `texture`, `renderer`, mais `IntersectionObserver`, `ResizeObserver` e os listeners. Em SPA, sem isso, trocar de rota algumas vezes esgota a memória de vídeo.

---

## 5. Cursor no plano da cena

Raycaster contra um plano é mais barato e mais estável que converter coordenadas na mão, e continua correto quando a câmera se move:

```js
const ndc = new THREE.Vector2(2, 2);        // fora da tela até o primeiro evento
const plano = new THREE.Plane(new THREE.Vector3(0, 0, 1), 0);
const raio = new THREE.Raycaster();
// por quadro:
raio.setFromCamera(ndc, camera);
if (raio.ray.intersectPlane(plano, alvo)) mat.uniforms.uMouse.value.copy(alvo);
forca += (alvoForca - forca) * 0.08;        // lerp: sem isto o campo reage em soco
```

No shader, a repulsão precisa de **teto**, senão a partícula sai voando quando o cursor passa em cima:

```glsl
float empurrao = uForca * 190.0 / (dist * dist + 30.0);
pos += normalize(vec3(d.xy, 0.3)) * min(empurrao, 11.0);
```

---

## 6. Objeto sólido: luz é o que separa produto de tutorial

```js
renderer.setPixelRatio(Math.min(devicePixelRatio, 2));   // >2 é desperdício invisível
renderer.toneMapping = THREE.ACESFilmicToneMapping;      // sem isso o highlight estoura
const camera = new THREE.PerspectiveCamera(35, 1, 0.1, 100);  // 35mm lê cinematográfico; 75 distorce
const key  = new THREE.DirectionalLight(0xffffff, 2.4); key.position.set(3, 4, 2);
const fill = new THREE.DirectionalLight(0xbcd4ff, 0.5); fill.position.set(-3, 0, 2);
const rim  = new THREE.DirectionalLight(0xffd9a8, 1.6); rim.position.set(0, 2, -4);
scene.environment = new THREE.PMREMGenerator(renderer)
  .fromScene(new RoomEnvironment()).texture;             // metal sem env map parece plástico cinza
```

`roughness` entre 0.2 e 0.6 é a faixa crível. Sombra é o que assenta o objeto: sem ela, ele flutua e o olho percebe sem saber nomear.

R3F: `frameloop="demand"` em cena estática é a otimização mais subestimada — para de queimar GPU em loop. E nada de `OrbitControls` em hero de marketing: convida o usuário a girar até achar o ângulo feio.

---

## 7. Verificação — screenshot, nunca imaginação

Geometria em código não diz nada sobre como a forma lê. Antes de dizer que terminou:

- [ ] Screenshot renderizado, olhado. A forma é reconhecível de imediato?
- [ ] Passa o Stranger Test, ou é "qualquer cena 3D de qualquer site"?
- [ ] FPS medido com e sem a cena, no mesmo viewport, com a natureza do renderer declarada
- [ ] Teto em `gl_PointSize`; `dpr` limitado a 2
- [ ] Gate de entrada, pausa fora da viewport, `dispose()` completo
- [ ] `prefers-reduced-motion` respeitado e fallback estático no lugar
- [ ] Console sem erro, sem 404 de asset

Reprovou no visual? O problema é asset ou luz. Quase nunca é código.
