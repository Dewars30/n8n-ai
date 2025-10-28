import OpenAI from 'openai';
import { Pool } from 'pg';
import { toSql } from 'pgvector/pg'; // 👈 helper

const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });
const pool = new Pool({ connectionString: process.env.DATABASE_URL || 'postgres://postgres:postgres@localhost:5432/n8n_ai' });

const TOP_50 = [
  'n8n-nodes-base.stripe','n8n-nodes-base.slack','n8n-nodes-base.gmail',
  'n8n-nodes-base.discord','n8n-nodes-base.notion','n8n-nodes-base.airtable',
  'n8n-nodes-base.hubspot','n8n-nodes-base.twilio','n8n-nodes-base.telegram',
  'n8n-nodes-base.googleCalendar','n8n-nodes-base.googleDrive','n8n-nodes-base.googleSheets',
  'n8n-nodes-base.microsoftOutlook','n8n-nodes-base.microsoftTeams','n8n-nodes-base.trello',
  'n8n-nodes-base.asana','n8n-nodes-base.salesforce','n8n-nodes-base.shopify',
  'n8n-nodes-base.woocommerce','n8n-nodes-base.wordpress','n8n-nodes-base.webhook',
  'n8n-nodes-base.httpRequest','n8n-nodes-base.function','n8n-nodes-base.wait',
  'n8n-nodes-base.if','n8n-nodes-base.set','n8n-nodes-base.noOp','n8n-nodes-base.emailSend',
  'n8n-nodes-base.sms','n8n-nodes-base.twitter','n8n-nodes-base.facebookGraphApi',
  'n8n-nodes-base.typeform','n8n-nodes-base.pipedrive','n8n-nodes-base.zohoCrm',
  'n8n-nodes-base.sendgrid','n8n-nodes-base.mailchimp','n8n-nodes-base.stripeTrigger',
  'n8n-nodes-base.slackTrigger','n8n-nodes-base.rssFeedRead','n8n-nodes-base.htmlExtract',
  'n8n-nodes-base.dateTime','n8n-nodes-base.crypto'
];

async function ensureTable() {
  await pool.query(`CREATE EXTENSION IF NOT EXISTS vector;
    CREATE TABLE IF NOT EXISTS nodes_embedding (
      id TEXT PRIMARY KEY, name TEXT NOT NULL, description TEXT, embedding vector(1536)
    );`);
}

async function seed() {
  await ensureTable();
  for (const id of TOP_50) {
    const desc = `${id} community node for n8n`;
    const { data } = await openai.embeddings.create({ model: 'text-embedding-3-small', input: desc });
    const vector = data[0].embedding;
    // use pgvector's toSql helper → casts to Vector type
    await pool.query(
      `INSERT INTO nodes_embedding (id, name, description, embedding)
       VALUES ($1, $2, $3, $4) ON CONFLICT (id) DO UPDATE SET embedding=$4`,
      [id, id, desc, toSql(vector)]
    );
  }
  const { rows } = await pool.query('SELECT COUNT(*) as c FROM nodes_embedding');
  console.log('✅ Seeded', rows[0].c, 'nodes');
  await pool.end();
}
seed().catch((e) => { console.error(e); process.exit(1); });
