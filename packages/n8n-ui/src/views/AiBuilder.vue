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
