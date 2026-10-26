# Nexsus GovSearch

**AI-Powered Government Pipeline Solution for Salesforce Agentforce**

Nexsus GovSearch provides an AI-optimized list of the latest best-fit recompetes, solicitations, and task orders for your company based on past performance and strategic objectives. It aggregates data from top federal sources (SAM.gov, USAspending, FedConnect, PIEE, agency procurement forecasts) and delivers it through a single, user-friendly Salesforce Lightning interface.

On Opportunity, Contract Vehicle, and Award records, the digital assistant (Agentforce) automatically generates an AI-authored brief, giving BD and capture teams an instant, expert-level read on what a record really means: who the incumbent is and why, where genuine competitive opportunity exists, and how to prioritize pursuit.

It also includes contact intelligence (senior government decision makers, biographical details, and org chart views of agency/office hierarchies) to help Growth teams build the right relationships, plus streamlined research and analysis tools for partner identification, market/competitive analysis, and account planning.

## Key Features

- **AI-Optimized Pipeline**: Continuously scores and surfaces highly relevant Pipeline Candidates based on past performance, NAICS/PSC alignment, strategic objectives, contract vehicle access, and historical win patterns.
- **AI-Authored Briefs**: Agentforce digital assistant generates expert briefs on Opportunities, Awards, and Contract Vehicles.
- **Consolidated Federal Data**: Single view aggregating SAM.gov, USAspending, FedConnect, PIEE, agency forecasts, and proprietary contact/past-performance data.
- **Flexible Ingestion**: Support for both pull (Apex callouts) and push (Ingestion API) patterns.
- **Contact & Relationship Intelligence**: Org chart hierarchies, decision-maker bios, influence ratings, and AI-suggested call/account plans.
- **CRM-Native**: Fully embedded in Salesforce Lightning. Qualified Pipeline Candidates convert to Opportunities.
- **Agentforce Agents**:
  - Pipeline Scout Agent
  - Opportunity Intelligence Agent
  - Research & Relationship Agent

## Architecture Overview

See [docs/architecture.md](docs/architecture.md) for detailed diagrams and component descriptions.

High-level components:
- Custom Lightning App (Nexsus GovSearch)
- Agentforce Employee Agents
- Flows + Apex actions + Prompt Templates
- Custom objects including Pipeline_Candidate__c, Solicitation__c, Award__c, Government_Contact__c, Integration_Log__c
- Integrations via Apex Callouts, Ingestion API, MuleSoft, Platform Events, or Data Cloud

## Project Structure

```
Nexsus-GovSearch/
├── config/
│   └── project-scratch-def.json
├── docs/
│   ├── architecture.md
│   ├── deployment.md
│   ├── data-model.md
│   ├── external-data-sources.md
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

This repository contains the Salesforce DX project with custom objects, fields, layouts, permission sets, pure LWC components, Apex services (callout + ingestion + scoring + logging), and Agentforce sketches.

## License

Internal / proprietary. Contact the repository owner for usage rights.
