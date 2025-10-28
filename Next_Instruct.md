Below is copy-paste-ready Claude Desktop language that:

1. Moves the PRD into the correct location so you (and Jules) auto-index it
2. Creates the exact monorepo skeleton required by PRD Section 6
3. Sets up concurrent dev tasks so `task dev` starts both the Vue front-end and the Fastify AI service
4. Leaves placeholders for the first feature slice (prompt→workflow JSON endpoint)

---

## Send this **verbatim** to Claude Desktop

```
I need to execute the early-stage scaffolding for the n8n-ai project according to our PRD. Please run these commands and generate the missing files.
Start in /Users/td/n8n-ai.

Step 1 – restructure documentation
mkdir -p docs/adrs docs/api
mv n8n_ai_prd.md docs/PRD.md
git add docs && git commit -m "docs: reorganize per PRD Section 10"

Step 2 – create monorepo skeleton (matches PRD §6 architecture)
mkdir -p packages/{n8n-ui,ai-service,shared}/src

Step 3 – root workspace files
cat > pnpm-workspace.yaml <<'EOF'
packages:
  - 'packages/*'
EOF

Step 4 – shared package (types & utils)
cat > packages/shared/package.json <<'EOF'
{
  "name": "@n8n-ai/shared",
  "version": "0.1.0",
  "type": "module",
  "main": "./dist/index.js",
  "types": "./dist/index.d.ts",
  "scripts": {
    "build": "tsc",
    "dev": "tsc --watch",
    "lint": "eslint src --ext .ts"
  },
  "devDependencies": {
    "typescript": "^5.5.4",
    "@types/node": "^20.14.0"
  }
}
EOF
mkdir -p packages/shared/src
cat > packages/shared/src/index.ts <<'EOF'
export interface WorkflowNode {
  id: string;
  name: string;
  parameters: Record<string, any>;
  type: string;
  typeVersion: number;
  position: [number, number];
}
export interface Workflow {
  nodes: WorkflowNode[];
  connections: Record<string, any>;
}
EOF
cat > packages/shared/tsconfig.json <<'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "node",
    "outDir": "dist",
    "rootDir": "src",
    "strict": true,
    "declaration": true,
    "skipLibCheck": true
  },
  "include": ["src"]
}
EOF

Step 5 – ai-service (Fastify + OpenAI SDK)
cat > packages/ai-service/package.json <<'EOF'
{
  "name": "@n8n-ai/ai-service",
  "version": "0.1.0",
  "type": "module",
  "scripts": {
    "build": "tsc",
    "dev": "tsx watch src/index.ts",
    "lint": "eslint src --ext .ts"
  },
  "dependencies": {
    "fastify": "^4.28.0",
    "@fastify/cors": "^9.0.1",
    "@fastify/env": "^4.0.0",
    "openai": "^4.52.0",
    "pg": "^8.12.0",
    "pgvector": "^0.1.8",
    "zod": "^3.23.0",
    "@n8n-ai/shared": "workspace:*"
  },
  "devDependencies": {
    "typescript": "^5.5.4",
    "tsx": "^4.15.0",
    "@types/pg": "^8.11.0"
  }
}
EOF
mkdir -p packages/ai-service/src/{routes,services,schema}
cat > packages/ai-service/src/index.ts <<'EOF'
import Fastify from 'fastify';
import cors from '@fastify/cors';
import { buildRoute } from './routes/ai/build.js';

const fastify = Fastify({ logger: true });
await fastify.register(cors, { origin: true });

// health
fastify.get('/health', async () => ({ status: 'ok' }));

// AI routes
fastify.register(buildRoute, { prefix: '/api/ai' });

const PORT = process.env.PORT ? Number(process.env.PORT) : 8888;
try {
  await fastify.listen({ port: PORT, host: '0.0.0.0' });
  console.log(`AI service listening on ${PORT}`);
} catch (err) {
  fastify.log.error(err);
  process.exit(1);
}
EOF
cat > packages/ai-service/src/routes/ai/build.ts <<'EOF'
import { z } from 'zod';
import type { FastifyInstance } from 'fastify';
import { Workflow } from '@n8n-ai/shared';

const bodySchema = z.object({
  prompt: z.string().min(3),
  openAIKey: z.string().optional(), // BYOK
});

export async function buildRoute(fastify: FastifyInstance) {
  fastify.post('/build', async (req, reply) => {
    const { prompt, openAIKey } = bodySchema.parse(req.body);
    // TODO: implement LLM call + vector search + validation
    const workflow: Workflow = {
      nodes: [],
      connections: {},
    };
    return { workflow, confidence: 0.95 };
  });
}
EOF
cat > packages/ai-service/tsconfig.json <<'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "node",
    "outDir": "dist",
    "rootDir": "src",
    "strict": true,
    "skipLibCheck": true
  },
  "include": ["src"],
  "references": [{ "path": "../shared" }]
}
EOF

Step 6 – n8n-ui (Vue 3 + Vite + Pinia)
cat > packages/n8n-ui/package.json <<'EOF'
{
  "name": "@n8n-ai/n8n-ui",
  "version": "0.1.0",
  "type": "module",
  "scripts": {
    "dev": "vite --port 5678",
    "build": "vue-tsc && vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "vue": "^3.4.0",
    "vue-router": "^4.4.0",
    "pinia": "^2.1.7",
    "@n8n-ai/shared": "workspace:*"
  },
  "devDependencies": {
    "@vitejs/plugin-vue": "^5.0.0",
    "typescript": "^5.5.4",
    "vue-tsc": "^2.0.0",
    "vite": "^5.3.0"
  }
}
EOF
mkdir -p packages/n8n-ui/src/{components,routes,stores}
cat > packages/n8n-ui/src/main.ts <<'EOF'
import { createApp } from 'vue';
import { createPinia } from 'pinia';
import App from './App.vue';
import router from './router';
import './style.css';

createApp(App).use(createPinia()).use(router).mount('#app');
EOF
cat > packages/n8n-ui/src/App.vue <<'EOF'
<template>
  <div id="app">
    <nav>
      <RouterLink to="/">Home</RouterLink>
      <RouterLink to="/ai-builder">AI Builder</RouterLink>
    </nav>
    <RouterView />
  </div>
</template>
EOF
cat > packages/n8n-ui/src/router/index.ts <<'EOF'
import { createRouter, createWebHistory } from 'vue-router';
import Home from '../views/Home.vue';
import AiBuilder from '../views/AiBuilder.vue';

export default createRouter({
  history: createWebHistory(),
  routes: [
    { path: '/', component: Home },
    { path: '/ai-builder', component: AiBuilder },
  ],
});
EOF
mkdir -p packages/n8n-ui/src/views
cat > packages/n8n-ui/src/views/Home.vue <<'EOF'
<template><h1>n8n-ai dev preview</h1></template>
EOF
cat > packages/n8n-ui/src/views/AiBuilder.vue <<'EOF'
<template>
  <div class="ai-builder">
    <h2>AI Builder</h2>
    <textarea v-model="prompt" placeholder="Describe your workflow..."/>
    <button @click="build">Build Workflow</button>
    <pre>{{ result }}</pre>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
const prompt = ref('');
const result = ref('');
async function build() {
  const res = await fetch('http://localhost:8888/api/ai/build', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ prompt: prompt.value }),
  });
  result.value = JSON.stringify(await res.json(), null, 2);
}
</script>
EOF
cat > packages/n8n-ui/vite.config.ts <<'EOF'
import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';

export default defineConfig({
  plugins: [vue()],
  server: { port: 5678, host: '0.0.0.0' },
});
EOF
cat > packages/n8n-ui/tsconfig.json <<'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ESNext",
    "lib": ["ES2020", "DOM"],
    "moduleResolution": "node",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true
  },
  "include": ["src/**/*.ts", "src/**/*.d.ts", "src/**/*.tsx", "src/**/*.vue"]
}
EOF

Step 7 – root Taskfile (concurrent dev)
cat > Taskfile.yml <<'EOF'
version: '3'
tasks:
  init:
    cmds:
      - pnpm install
      - pnpm --filter shared build
      - docker compose up -d
  dev:
    cmds:
      - concurrently "pnpm --filter ai-service dev" "pnpm --filter n8n-ui dev"
  build:
    cmds:
      - pnpm -r build
  lint:
    cmds:
      - pnpm -r lint
EOF

Step 8 – install & verify
pnpm install
pnpm --filter shared build
task dev   # should start both services on :8888 and :5678

Step 9 – git snapshot
git add .
git commit -m "feat: scaffold monorepo per PRD §6"
git push origin main

After these steps:
- docs/PRD.md is the single source of truth
- pnpm workspace with three packages exists
- task dev launches both frontend (:5678) and backend (:8888)
- Placeholder AI Builder UI and /api/ai/build endpoint are ready for real LLM wiring
```

---

After the run you should see:

```
[0] ai-service:  AI service listening on 8888
[1] n8n-ui:     Vite server listening on 5678
```

Open http://localhost:5678 → click “AI Builder” → the button calls the real endpoint.
From here you can ask Claude Desktop:
“Wire the LLM call into packages/ai-service/src/routes/ai/build.ts using OpenAI gpt-4-turbo and the vector search we seeded earlier.”
