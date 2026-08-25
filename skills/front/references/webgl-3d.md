# WebGL & 3D — Three.js, R3F, and the asset problem

Load in Phase 3 when the direction calls for depth, and in Phase 4 to build it. `motion-libs.md` covers 2D motion; this covers the moment the page stops being flat.

**Prime rule:** 3D falha por **asset**, não por código. Uma cena de 40 linhas com um modelo feito por artista lê como produto. Uma cena de 400 linhas com geometria esculpida à mão lê como brinquedo. Decida o asset antes de escrever a primeira linha.

---

## 0. O gate que vem antes de tudo

Lição aprendida tentando esculpir um mascote animal em código:

> Não dá para esculpir um modelo realista via código à mão. É ofício de artista 3D. Front frontal facetado lê como coruja; low-poly lê como toy.

Portanto, para qualquer forma orgânica (animal, rosto, personagem, mascote), há **três caminhos legítimos** e um proibido:

| Caminho | Quando | Cuidado |
|---|---|---|
| **Asset de artista** (Sketchfab, Poly Haven, Quaternius) | forma orgânica ou reconhecível | **licença primeiro** — ver abaixo |
| **IA text-to-3D** (Meshy, Tripo, Rodin) | precisa de algo específico que não existe pronto | topologia costuma vir suja; sempre decimar e re-verificar |
| **Geometria primitiva composta** | formas **abstratas**: grid, partículas, cristal, terreno, formas arquitetônicas | é aqui que código à mão funciona bem |
| ❌ **Esculpir forma orgânica em código** | nunca | consome horas e entrega algo que qualquer um rejeita na hora |

**Licença de asset 3D é mais restritiva que licença de código:**
- `CC0` → livre.
- `CC-BY` → liberado, **exige crédito visível** no produto.
- `CC-BY-NC`, `CC-BY-SA`, `CC-BY-NC-SA` → **BLOCK**. NC proíbe uso comercial; SA é viral e contaminaria o produto.
- "Repo público" e "sem arquivo de licença" **não liberam** — é todos-os-direitos-reservados por padrão.
- Download do Sketchfab exige login mesmo em CC-BY. Guarde o arquivo de licença junto do asset, no repo.

Registre o veredito em `~/.claude/logs/license-audit.jsonl` e não re-audite o que já tem veredito.

---

## 1. Escolher a camada

| Camada | Use quando | Custo |
|---|---|---|
| **CSS 3D** (`transform-style: preserve-3d`, `perspective`) | card flip, cubo, parallax de camadas, tilt | 0 KB |
| **Canvas 2D** | partículas, ruído, campo de pontos — sem iluminação | 0 KB |
| **Three.js puro** | cena única, controle total, projeto sem React | ~160 KB gz |
| **React Three Fiber + drei** | React, cena declarativa, várias cenas, estado compartilhado | ~200 KB gz |

`three` é grande. Antes de assumi-lo, pergunte se o efeito desejado não é CSS 3D com `perspective` — em hero de landing, com frequência é.

---

## 2. Cena mínima que já parece boa

O que separa "parece render de tutorial" de "parece produto" é **luz e material**, não polígono.

```js
import * as THREE from 'three';

const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
renderer.setPixelRatio(Math.min(devicePixelRatio, 2));   // >2 é desperdício invisível
renderer.toneMapping = THREE.ACESFilmicToneMapping;      // sem isso o highlight estoura
renderer.toneMappingExposure = 1.05;

const scene = new THREE.Scene();
const camera = new THREE.PerspectiveCamera(35, 1, 0.1, 100);  // 35mm lê cinematográfico; 75 distorce
camera.position.set(0, 0.6, 4);

// Iluminação de 3 pontos: key + fill + rim. É isso que dá volume.
const key  = new THREE.DirectionalLight(0xffffff, 2.4); key.position.set(3, 4, 2);
const fill = new THREE.DirectionalLight(0xbcd4ff, 0.5); fill.position.set(-3, 0, 2);
const rim  = new THREE.DirectionalLight(0xffd9a8, 1.6); rim.position.set(0, 2, -4);
scene.add(key, fill, rim);
key.castShadow = true;
key.shadow.mapSize.set(1024, 1024);   // 2048+ raramente vale o custo
```

Regras de material:
- `MeshStandardMaterial` como padrão. `MeshBasicMaterial` ignora luz e por isso sempre lê como flat/fake.
- Reflexo precisa de **environment map**. Sem `scene.environment`, metal parece plástico cinza. Um HDRI pequeno (1k) já resolve — `RoomEnvironment` do próprio Three custa zero download.
- `roughness` 0.2–0.6 é a faixa crível para a maioria das superfícies. `0` é espelho e denuncia cena de teste.
- Sombra é o que assenta o objeto no espaço. Sem sombra o objeto flutua, e o olho percebe mesmo sem saber nomear.

---

## 3. R3F — o padrão em React

```jsx
import { Canvas } from '@react-three/fiber';
import { Environment, useGLTF, OrbitControls, Preload } from '@react-three/drei';
import { Suspense } from 'react';

function Modelo() {
  const { scene } = useGLTF('/modelos/objeto.glb');   // preload automático via drei
  return <primitive object={scene} />;
}

export default function Cena({ interativo = false }) {
  return (
    <Canvas
      dpr={[1, 2]}
      camera={{ fov: 35, position: [0, 0.6, 4] }}
      gl={{ antialias: true, alpha: true }}
      frameloop={interativo ? 'always' : 'demand'}   // 'demand' = só renderiza quando muda
    >
      <Suspense fallback={null}>
        <Modelo />
        <Environment preset="city" />
        <Preload all />
      </Suspense>
      {interativo && <OrbitControls enablePan={false} makeDefault />}
    </Canvas>
  );
}
```

- `frameloop="demand"` é a otimização mais subestimada: cena estática deixa de queimar GPU e bateria em loop infinito.
- `useGLTF.preload('/modelos/objeto.glb')` fora do componente evita o pop-in.
- `<Suspense fallback={null}>` sempre — sem ele o modelo carregando derruba a árvore.
- Não use `OrbitControls` em hero de marketing. Convida o usuário a girar o objeto até achar o ângulo feio.

---

## 4. Pipeline de asset — não sirva `.glb` cru

```bash
# 1. Comprimir geometria e textura (reduz 60–90% na prática)
npx gltf-transform optimize entrada.glb saida.glb --texture-compress webp

# 2. Draco quando a geometria é o peso dominante
npx gltf-transform draco entrada.glb saida.glb

# 3. Inspecionar antes de aceitar
npx gltf-transform inspect saida.glb   # contagem de vértices, textura, materiais
```

Orçamento para web:
| Alvo | Vértices | Peso do arquivo | Texturas |
|---|---|---|---|
| Hero de landing | < 150k | < 2 MB | 1–2 × 1024² |
| Objeto secundário | < 50k | < 500 KB | 1 × 512² |
| Cena inteira | < 500k | < 5 MB | atlas |

Se o `.glb` do artista tem 40 MB, ele não está pronto para web — otimize, não sirva.

---

## 5. Progressive enhancement e acessibilidade

3D é a parte da página com mais chance de não funcionar. Trate isso como estado, não como exceção (`ux-interaction.md`: os cinco estados valem aqui também).

- **Sem WebGL** → poster estático. Detecte antes de montar o canvas, não no `catch`.
- **`prefers-reduced-motion`** → cena parada em pose escolhida. Nada de auto-rotate, nada de scroll-scrub.
- **`navigator.hardwareConcurrency <= 4` ou `deviceMemory` baixo** → poster ou versão sem sombra/env map.
- **Mobile** → considere não carregar. 200 KB de lib + 2 MB de asset em 4G é hostil. `matchMedia('(min-width: 1024px)')` como gate é uma decisão legítima.
- **Loading** → o modelo demora; skeleton ou poster com blur, nunca canvas preto (que lê como quebrado).
- **Semântica** → o canvas não é conteúdo. Informação real fica em HTML ao lado; `aria-hidden="true"` no canvas decorativo, ou `role="img"` + `aria-label` quando ele É o conteúdo.
- **Cleanup** → em SPA, `renderer.dispose()`, `geometry.dispose()`, `material.dispose()` e `texture.dispose()` no unmount. Sem isso, trocar de rota algumas vezes esgota a memória de GPU.

---

## 6. Verificação obrigatória — screenshot, não imaginação

Regra dura, vinda de erro real: **nunca declare uma cena 3D pronta sem ter olhado o screenshot renderizado.** Geometria em código não diz nada sobre como a forma lê. Use o fluxo de `playwright-verification.md` e responda:

- A forma é reconhecível **de imediato**, sem legenda?
- Lê como produto ou como low-poly de asset store grátis?
- A silhueta funciona no ângulo escolhido? (o teste onde o lobo virou coruja)
- Há sombra assentando o objeto, ou ele flutua?
- Aguenta o Stranger Test (`SKILL.md` Fase 5) ou é "qualquer cena 3D de qualquer site"?

Reprovou em qualquer uma → o problema é asset ou luz, quase nunca código.

---

## Quick gate (Phase 5 add-on)

- [ ] Veredito de licença do asset registrado; NC/SA rejeitados; crédito de CC-BY presente
- [ ] Forma orgânica veio de artista ou IA — não esculpida em código
- [ ] Luz de 3 pontos + `scene.environment` + sombra; nada de `MeshBasicMaterial` em superfície real
- [ ] `.glb` otimizado (`gltf-transform`), dentro do orçamento de vértices e peso
- [ ] `dpr` limitado a 2; `frameloop="demand"` em cena estática
- [ ] Fallback sem WebGL, `prefers-reduced-motion` e decisão explícita sobre mobile
- [ ] `dispose()` de renderer/geometry/material/texture no unmount
- [ ] **Screenshot conferido** — a forma lê, tem sombra, passa o Stranger Test
