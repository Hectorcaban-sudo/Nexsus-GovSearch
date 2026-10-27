# Nexsus GovSearch

**AI-Powered Government Pipeline Solution for Salesforce Agentforce**

Nexsus GovSearch provides an AI-optimized list of the latest best-fit recompetes, solicitations, and task orders for your company based on past performance and strategic objectives. It aggregates data from top federal sources (SAM.gov, USAspending, FedConnect, PIEE, agency procurement forecasts) and delivers it through a single, user-friendly Salesforce Lightning interface.

On Opportunity, Contract Vehicle, and Award records, the digital assistant (Agentforce) automatically generates an AI-authored brief, giving BD and capture teams an instant, expert-level read on what a record really means: who the incumbent is and why, where genuine competitive opportunity exists, and how to prioritize pursuit.

It also includes contact intelligence (senior government decision makers, biographical details, and org chart views of agency/office hierarchies) to help Growth teams build the right relationships, plus streamlined research and analysis tools for partner identification, market/competitive analysis, and account planning.

## Design Principle

**Deterministic core + Agentforce assist layer.**

- Scoring, triage, routing, and gate decisions are rules-based, auditable, and reproducible.
- Agentforce agents explain scores, generate briefs, suggest actions, and draft plans. Users accept or edit the output.

See [docs/ai-layer.md](docs/ai-layer.md) and the diagrams in [docs/diagrams.md](docs/diagrams.md).

## Requirements Alignment

The solution is being built against the **GovCon Capture & Market Intelligence on Salesforce — Requirements Document**.

- Full gap analysis: [docs/requirements-gap-analysis.md](docs/requirements-gap-analysis.md)
- Updated data model: [docs/data-model.md](docs/data-model.md)
- AI layer explanation: [docs/ai-layer.md](docs/ai-layer.md)
- Scoring and capture updates: [docs/scoring-and-capture-updates.md](docs/scoring-and-capture-updates.md)

**Current status**: Criteria-based scoring with stored reasons, triage and promote Flow, Gate Review Approval Process, Bid Decision Scorecard with weighted recommendation, and Weighted Value formula. Agentforce agents assist on top of the deterministic core.

## Key Features

- **Criteria-Based Scoring**: Matches Pipeline Candidates against Company Profile (NAICS, PSC, set-asides, vehicles, target agencies) and configurable Fit Rules. Stores plain-language Score Reasons.
- **AI-Authored Briefs**: Agentforce digital assistant generates expert briefs on Opportunities, Awards, and Contract Vehicles.
- **Consolidated Federal Data**: Single view aggregating SAM.gov, USAspending, FedConnect, PIEE, agency forecasts, and proprietary contact/past-performance data.
- **Flexible Ingestion**: Support for both pull (Apex callouts) and push (Ingestion API / Data Cloud) patterns.
- **Contact & Relationship Intelligence**: Org chart hierarchies, decision-maker bios, influence ratings, and AI-suggested call/account plans.
- **CRM-Native**: Fully embedded in Salesforce Lightning. Qualified Pipeline Candidates convert to Opportunities via Triage and Promote Flow.
- **Capture Controls**: Gate Review Approval Process, Bid/No-Bid Scorecard, Weighted Value (TCV × pWin × pGo).
- **Agentforce Agents**:
  - Pipeline Scout Agent
  - Opportunity Intelligence Agent
  - Research & Relationship Agent

## Architecture & Diagrams

- [docs/architecture.md](docs/architecture.md) — High-level architecture overview
- [docs/diagrams.md](docs/diagrams.md) — Updated architecture, user workflow, scoring workflow, and deterministic-vs-Agentforce diagrams
- [docs/requirements-gap-analysis.md](docs/requirements-gap-analysis.md) — Gap analysis vs. requirements document
- [docs/ai-layer.md](docs/ai-layer.md) — AI scoring and Agentforce implementation
- [docs/scoring-and-capture-updates.md](docs/scoring-and-capture-updates.md) — Criteria scoring, gates, and bid scorecard
- [docs/deployment.md](docs/deployment.md) — Full deployment and setup instructions

High-level components:
- Custom Lightning App (Nexsus GovSearch)
- Deterministic scoring and process layer (Company Profile, Fit Rules, Triage, Gates, Bid Scorecard)
- Agentforce Assist Layer
- Flows + Apex actions + Prompt Templates
- Custom objects including Pipeline_Candidate__c, Company_Profile__c, Gate_Review__c, Capture_Plan__c, and supporting MVP objects
- Integrations via Apex Callouts, Ingestion API, MuleSoft, Platform Events, or Data Cloud

## Project Structure

```
Nexsus-GovSearch/
├── config/
│   └── project-scratch-def.json
├── docs/
│   ├── architecture.md
│   ├── diagrams.md
│   ├── deployment.md
│   ├── data-model.md
│   ├── external-data-sources.md
│   ├── requirements-gap-analysis.md
│   ├── ai-layer.md
│   ├── scoring-and-capture-updates.md
│   ├── mvp-implementation-notes.md
│   ├── sample-data.md
│   └── lwc-stubs.md
├── force-app/
│   └── main/
│       └── default/
│           ├── applications/
│           ├── classes/
│           ├── lwc/
│           ├── objects/
│           ├── layouts/
│           ├── permissionsets/
│           └── ...
├── .gitignore
├── README.md
└── sfdx-project.json
```

## Getting Started (VS Code)

1. Install the [Salesforce Extension Pack](https://marketplace.visualstudio.com/items?itemName=salesforce.salesforcedx-vscode).
2. Clone the repository:
   ```bash
   git clone https://github.com/Hectorcaban-sudo/Nexsus-GovSearch.git
   cd Nexsus-GovSearch
   ```
3. Open the folder in VS Code.
4. Authorize a Dev Hub.
5. Create a scratch org:
   ```bash
   sf org create scratch --definition-file config/project-scratch-def.json --alias nexsus-govsearch --duration-days 7 --set-default
   ```
6. Deploy:
   ```bash
   sf project deploy start
   ```

See [docs/deployment.md](docs/deployment.md) for full instructions.

## Integration Options

- **Ingestion API**: `POST /services/apexrest/nexsus/pipeline-candidates` (see [docs/external-data-sources.md](docs/external-data-sources.md))
- **Apex Callouts**: `PipelineScoutCalloutService.syncAndScore()`
- Logging available via `Integration_Log__c`

## Status

This repository contains the Salesforce DX project with custom objects, criteria-based scoring with stored reasons, triage and promote Flow, Gate Review Approval Process, Bid Decision Scorecard, Weighted Value, pure LWC components, Apex services, Agentforce sketches, updated architecture and workflow diagrams, a full requirements gap analysis, and detailed AI layer documentation.

## License

Internal / proprietary. Contact the repository owner for usage rights.
