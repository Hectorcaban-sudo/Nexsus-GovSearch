# Nexsus GovSearch Diagrams

Visual workflow and architecture diagrams (JPG). High-resolution images for presentations and documentation.

## Updated Architecture Diagram

![Nexsus GovSearch Architecture](diagrams/architecture-updated.jpg)

Shows external sources (SAM.gov, USAspending, Agency Forecasts) flowing through the Integration Layer (Apex Callouts, Data Cloud Ingestion API, Ingestion API) into the Salesforce Core (Pipeline Candidate, Company Profile, Fit Rules, Scoring Service, Triage Flow, Gate Review Approval, Bid Scorecard, Opportunity). Agentforce Assist Layer sits on top of the deterministic core.

## User Workflow (Discovery to Bid Decision)

![User Workflow](diagrams/user-workflow-updated.jpg)

1. Data Ingestion from SAM.gov  
2. Criteria-based Scoring (Company Profile + Fit Rules, stores reasons)  
3. Analyst Review of scored candidates and Score Reasons  
4. Triage (Promote / Watch / Dismiss)  
5. Promote Flow creates Opportunity  
6. Gate Review Approval Process  
7. Bid Decision Scorecard  
8. Agentforce assists with briefs and explanations

## Deterministic Core vs Agentforce Assist

![Deterministic Core vs Agentforce](diagrams/deterministic-vs-agentforce.jpg)

Clear separation: Deterministic Core owns scoring rules, triage status, Promote Flow, Gate Approval Process, Bid Scorecard formula, and Weighted Value. Agentforce Assist reads from the core and recommends (explain score reasons, generate AI brief, suggest promotion, draft capture plan, answer questions).

## Pipeline Scoring Workflow

![Scoring Workflow](diagrams/scoring-workflow.jpg)

Company Profile (NAICS, PSC, Vehicles, Target Agencies) and Fit Rules (Field, Operator, Value, Weight) feed PipelineScoutService. Service evaluates matches only and writes AI Score, Strategic Fit, and Score Reasons on the Pipeline Candidate.

## Earlier Diagrams (still valid)

- [SAM.gov to Data Cloud Sequence](diagrams/sam-data-cloud-sequence.jpg)
- [Hybrid Ingestion Strategy](diagrams/hybrid-ingestion-strategy.jpg)

## Notes

- Place the latest JPG files in `docs/diagrams/`.
- Generated to match the current Nexsus GovSearch solution (criteria-based scoring, triage, gates, Agentforce assist layer).
- Update or regenerate as the architecture evolves.

## Related Documentation

- [docs/architecture.md](architecture.md)
- [docs/ai-layer.md](ai-layer.md)
- [docs/scoring-and-capture-updates.md](scoring-and-capture-updates.md)
- [docs/deployment.md](deployment.md)
