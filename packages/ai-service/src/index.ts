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
