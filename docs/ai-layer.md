# AI Layer Implementation

This document explains how the AI layer works in Nexsus GovSearch.

## Overview

The AI layer has two complementary parts:

1. **Rules-based scoring** (MVP) — deterministic, configurable, and auditable.
2. **Agentforce agents** (Phase 2 alignment) — conversational assistance, brief generation, and grounded Q&A.

Both operate on the same data model so scores and agent answers stay consistent.

## Rules-Based Scoring

### Components

| Component | Purpose |
|-----------|---------|
| `Company_Profile__c` | Singleton company profile (NAICS, PSC, set-asides, vehicles, target agencies) |
| `Fit_Rule__mdt` | Configurable criteria (Target Field, Operator, Value, Weight) |
| `PipelineScoutService` | Evaluates matches and writes scores + reasons |
| `Pipeline_Candidate__c.AI_Relevancy_Score__c` | 0–100 score |
| `Pipeline_Candidate__c.Strategic_Fit__c` | High / Medium / Low |
| `Pipeline_Candidate__c.Score_Reasons__c` | Plain-language match reasons (supports QUAL-06) |

### Scoring Flow

1. A Pipeline Candidate is created or updated (via callout, ingestion, or manual entry).
2. `PipelineScoutService.refreshScoresFor` is called.
3. The service loads the Company Profile and all Fit Rule custom metadata records.
4. For each candidate it awards points **only on actual matches**:
   - Primary / Secondary NAICS match against Company Profile
   - Target agency match
   - Fit Rule criteria (field + operator + value)
5. Match reasons are written to `Score_Reasons__c`.
6. The score is capped at 100 and Strategic Fit is derived from the score.
7. Results are logged to `Integration_Log__c`.

### Configuration

- Create one Company Profile record with Primary/Secondary NAICS, PSC, vehicles, and target agencies.
- Create Fit Rule custom metadata records with Target Field, Operator, Value, and Weight.
- Scoring can be triggered by:
  - Scheduled Apex
  - The Apex REST ingestion endpoint
  - `PipelineScoutCalloutService.syncAndScore()`
  - A button or Flow that calls `PipelineScoutService.refreshScores()`

## Agentforce Agents

Three Employee Agents are defined:

### 1. Pipeline Scout Agent
- Surfaces and ranks Pipeline Candidates by AI score.
- Answers questions such as “Show me high-score Army opportunities.”
- Can cite stored `Score_Reasons__c` when explaining a score.
- Can trigger scoring refresh and assist with promotion.
- Grounded on `Pipeline_Candidate__c` and (optionally) the Data Cloud DMO.

### 2. Opportunity Intelligence Agent
- Generates an AI-authored brief on an Opportunity.
- Explains incumbent position, competitive whitespace, and recommended prioritization.
- Can reference pWin, Weighted Value, Gate status, and Bid Recommendation.
- Grounded on the Opportunity, related Pipeline Candidates, Awards, and documents.
- Uses `OpportunityIntelligenceService` and prompt templates.

### 3. Research & Relationship Agent
- Identifies key government contacts and influencers.
- Supports competitive and partner analysis.
- Helps build call plans.
- Grounded on `Government_Contact__c`, `Agency_Hierarchy__c`, and `Award__c`.

### Agentforce Deployment Steps

1. Enable Agentforce in the org.
2. Create each agent in Agentforce Studio.
3. Define topics and subtopics that match the agent sketches.
4. Expose the relevant Apex methods as actions.
5. Configure grounding on the CRM objects (and Data Cloud DMO if used).
6. Assign least-privilege permission sets to the agent user.
7. Place the Agentforce panel on record pages and the Nexsus GovSearch app.
8. Test with sample utterances before go-live.

See `docs/agentforce/agent-sketches.md` for topic and utterance examples.

## Triage and Promotion (AI-Assisted Workflow)

Scoring feeds the triage process:

1. Analysts review scored candidates and their Score Reasons in the LWC dashboard or list view.
2. They set `Triage_Status__c` to Promote, Watch, or Dismiss.
3. Dismiss requires a reason (validation rule).
4. Promote triggers the `Promote_Pipeline_Candidate` Flow, which creates an Opportunity and links it back.
5. The Opportunity inherits the AI score and strategic fit.
6. Gate Reviews use an Approval Process; stage advance can be blocked until Gate 0 is approved.
7. Bid/No-Bid Scorecard produces a weighted recommendation.
8. The Opportunity Intelligence Agent can then generate a brief that references score reasons, gates, and the bid recommendation.

## Data Cloud Grounding (Optional)

When Data Cloud is used:
- SAM.gov and other feeds land in a Pipeline Candidate DMO.
- Qualified records sync to `Pipeline_Candidate__c`.
- Agents can be grounded on the DMO for broader context and on CRM records for transactional actions.
- Scoring still runs on the CRM records after sync.

## Governance and Compliance

- All scoring decisions are deterministic, criteria-based, and logged.
- Match reasons are stored for audit and for Agentforce explanations.
- Agentforce uses the Einstein Trust Layer (no customer data retained by model providers).
- AI outputs should be labeled and require user acceptance before being saved (per requirement AI-04).
- Field history tracking is enabled on Opportunity and pWin__c.

## Current Limitations and Roadmap

**Implemented**
- Criteria-based scoring against expanded Company Profile and Fit Rules
- Score reasons stored for explanations
- Agent sketches and Apex service stubs
- Triage and promote Flow
- Gate Review Approval Process and Bid Scorecard weighted recommendation
- LWC surfaces for scores and briefs

**Planned (Phase 2)**
- Broader Fit Rule field coverage
- AI-generated summaries from solicitation documents
- Plain-language score explanations via Agentforce (using stored reasons)
- Semantic search and “find similar”
- Likely-bidders suggestions
- Draft capture plans and call plans via agents

## Related Documentation

- [docs/deployment.md](deployment.md)
- [docs/scoring-and-capture-updates.md](scoring-and-capture-updates.md)
- [docs/mvp-implementation-notes.md](mvp-implementation-notes.md)
- [docs/agentforce/agent-sketches.md](agentforce/agent-sketches.md)
- [docs/data-model.md](data-model.md)
- [docs/external-data-sources.md](external-data-sources.md)
