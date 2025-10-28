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
