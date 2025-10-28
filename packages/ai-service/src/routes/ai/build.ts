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
