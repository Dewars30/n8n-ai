Here’s the **living PRD** (identical to the one we wrote for Coder) dropped straight into your existing `~/n8n-ai` folder.
Save it as `docs/PRD.md`; VS Code will auto-preview it on open, and both Jules & Claude will index it when you ask “show me the spec”.

---

## docs/PRD.md

```markdown
# n8n-ai – Product Requirements Document

`Rev 1.4` | Author: @Dewars30 | Dev-Container path: `/workspace/n8n-ai/docs/PRD.md`

## 1. Purpose

Give non-technical ops teams an AI co-pilot that:

- turns plain English into production-ready n8n workflows,
- self-heals broken integrations, and
- deploys either in our cloud or their own VPC.

Revenue goal: **$14.5 k MRR** within 90 days.

## 2. Target Personas

| Persona                   | Pain                                                     | How we solve                                     |
| ------------------------- | -------------------------------------------------------- | ------------------------------------------------ |
| Agency Ops (Sarah, 29)    | 6 h/week rebuilding client Zaps after APIs change        | 1-sentence prompt → workflow + auto-patch        |
| SaaS Founder (Miguel, 34) | Needs HIPAA-compliant automation; Zapier can’t self-host | 1-click Docker image inside their own cluster    |
| MSP Owner (Lisa, 41)      | Wants white-label iPaaS to charge clients $299/mo        | Embed n8n-ai, logo & URL rebrand, 30 % rev-share |

## 3. Core User Stories

1. US-1: Prompt → Workflow
   As Sarah, I type:
   “When a new Stripe payment > $500 happens, create a HubSpot deal, notify Slack #sales, and wait 2 days → send a personalised thank-you email unless refund.”
   → AI returns a 4-node workflow; I click “Add to canvas”.

2. US-2: One-click Heal
   Miguel receives “401 Unauthorized” on Monday.
   n8n-ai shows: “HubSpot password grant expired → Patch: switch to OAuth2 refresh token”.
   Miguel clicks “Apply & Re-run”; error gone.

3. US-3: Deploy Anywhere
   Lisa opens her VS Code Dev-Container → “Reopen in Container” → workspace boots with n8n-ai, PostgreSQL, SSO already wired.

## 4. Functional Requirements

| ID   | Requirement             | Acceptance Criteria                                                                       |
| ---- | ----------------------- | ----------------------------------------------------------------------------------------- |
| FR-1 | Natural-language parser | ≥ 80 % of Beta cohort sentences compile to valid workflow on first try                    |
| FR-2 | Node catalog coverage   | Top 50 community nodes (Stripe, Slack, Notion, HubSpot, Discord, Airtable, Google Sheets) |
| FR-3 | Confidence score        | UI shows ≥ 90 % confidence bar before user clicks “Add”                                   |
| FR-4 | Self-heal accuracy      | ≥ 70 % of documented HTTP 4xx/5xx errors resolved by first suggestion                     |
| FR-5 | VPC deploy              | `docker-compose up -d` starts full stack in < 2 min on 2 vCPU / 4 GB RAM                  |
| FR-6 | Multi-tenant cloud      | Hard tenant isolation via PostgreSQL row-level security                                   |
| FR-7 | Usage-based billing     | Stripe metered → Pro $29, Team $99, Enterprise $2 k/y (min 25 seats)                      |

## 5. Non-Functional Requirements

| ID    | Requirement    | Metric                                                             |
| ----- | -------------- | ------------------------------------------------------------------ |
| NFR-1 | Latency        | Prompt → workflow JSON ≤ 4 s (p95)                                 |
| NFR-2 | Availability   | 99.9 % monthly (cloud)                                             |
| NFR-3 | Security       | SOC-2 Type I by Week 12; GDPR DPA template                         |
| NFR-4 | Scalability    | 1 k concurrent workflows per tenant; horizontal via Kubernetes HPA |
| NFR-5 | Upstream merge | ≤ 30 min conflict resolution when n8n releases new minor           |

## 6. Tech Architecture (Dev-Container Edition)
```

┌-------------┐ HTTPS ┌----------------┐
│ Browser │◄------------►│ n8n Vue UI │
└-----┬-------┘ └-----┬----------┘
│ │ WebSocket
│ ▼
│ ┌----------------┐
│ │ AI Builder │ (new Vue route)
│ └-----┬----------┘
│ │ POST /api/ai/build
▼ ▼
┌-------------┐ gRPC ┌----------------┐
│ n8n backend │◄-----------►│ ai-service │ (Fastify)
└-------------┘ └-----┬----------┘
│ prompt
▼
┌----------------┐
│ OpenAI / │
│ Anthropic │
└-----┬----------┘
│ embed
▼
┌----------------┐
│ pgvector │ (node docs)
└----------------┘

```
- All stateless → scale via replicas.
- Dev-Container: `docker-compose` brings up postgres + redis automatically.

## 7. AI Prompt Pipeline
1. System: role, safety, output JSON schema.
2. Context: top-k (5) most similar node-descriptions from pgvector.
3. User ask.
4. Chain-of-thought → workflow JSON.
5. Validation: JSON-schema + circular-dependency check.
6. Confidence = softmax score from LLM log-probs.

## 8. UI Mock
![AI Builder](https://link-to-figma.png)
*Figma embed (live in Storybook port 6006)*

## 9. Milestones & Metrics
| Milestone | Date | Success Metric |
|-----------|------|----------------|
| α Alpha | W2 | 5 internal workflows generated |
| β Beta | W4 | 10 design-partner agencies, ≥ 80 % FR-1 |
| GA v1.0 | W7 | $1 k MRR, churn ≤ 4 % |
| SOC-2 scoped | W12 | Audit checklist 100 % complete |

## 10. Open Questions / Parking Lot
- Fine-tune vs. prompt-only? → Decision: prompt-only until 1 M workflows, then LoRA.
- On-prem license key enforce? → ADR-003 (time-boxed JWT).
- Multi-language prompts? → Phase-2 (ES, DE).

--------------------------------------------------
How this PRD is kept alive
--------------------------------------------------
- File lives in repo → mandatory PR approval if changed.
- Embedded in README → visible to every visitor.
- Jules & Claude index it when you ask “show me the spec”.
```

Save, commit, push:

```bash
cd ~/n8n-ai
mkdir -p docs
nano docs/PRD.md   # paste above
git add docs/PRD.md
git commit -m "docs: add living PRD"
git push
```

Jules & Claude will now surface it every time you type:
“show me the spec” / “what’s the next feature?” / “update FR-3”.
