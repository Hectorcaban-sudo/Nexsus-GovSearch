# Nexsus GovSearch

**AI-Powered Government Pipeline Solution for Salesforce Agentforce**

Nexsus GovSearch provides an AI-optimized list of the latest best-fit recompetes, solicitations, and task orders for your company based on past performance and strategic objectives. It aggregates data from top federal sources (SAM.gov, USAspending, FedConnect, PIEE, agency procurement forecasts) and delivers it through a single, user-friendly Salesforce Lightning interface.

On Opportunity, Contract Vehicle, and Award records, the digital assistant (Agentforce) automatically generates an AI-authored brief, giving BD and capture teams an instant, expert-level read on what a record really means: who the incumbent is and why, where genuine competitive opportunity exists, and how to prioritize pursuit.

It also includes contact intelligence (senior government decision makers, biographical details, and org chart views of agency/office hierarchies) to help Growth teams build the right relationships, plus streamlined research and analysis tools for partner identification, market/competitive analysis, and account planning.

## Key Features

- **AI-Optimized Pipeline**: Continuously scores and surfaces highly relevant leads based on your past performance, NAICS/PSC alignment, strategic objectives, contract vehicle access, and historical win patterns.
- **AI-Authored Briefs**: Agentforce digital assistant generates expert briefs on Opportunities, Awards, and Contract Vehicles covering incumbent analysis, competitive whitespace, prioritization rationale, risks, and recommended next actions.
- **Consolidated Federal Data**: Single view aggregating SAM.gov, USAspending, FedConnect, PIEE, agency forecasts, and proprietary contact/past-performance data.
- **Contact & Relationship Intelligence**: Org chart hierarchies, decision-maker bios, influence ratings, and AI-suggested call/account plans.
- **Research & Analysis Console**: Market spend trends, competitor intelligence, partner/teaming matchmaking, capability tagging, and saved searches.
- **CRM-Native**: Fully embedded in Salesforce Lightning. Qualified Pipeline Candidates convert to Opportunities with automatic field maintenance. Works with standard Opportunity, Account, Contact objects plus custom extensions.
- **Agentforce Agents**:
  - Pipeline Scout Agent
  - Opportunity Intelligence Agent
  - Research & Relationship Agent

## Architecture Overview

See [docs/architecture.md](docs/architecture.md) for detailed diagrams and component descriptions.

High-level components:
- Custom Lightning App (Nexsus GovSearch)
- Agentforce Employee Agents grounded in Data Cloud / Salesforce data + external sources
- Flows + Apex actions + Prompt Templates for scoring, enrichment, and brief generation
- Custom objects for Solicitation, Award, Contract Vehicle, Agency Hierarchy, Government Contact, Past Performance Profile, Strategic Objective, Pipeline Candidate
- Integrations via Apex / MuleSoft / Platform Events / Data Cloud for federal data sources

## Project Structure

This is a standard Salesforce DX project for Visual Studio Code (with Salesforce Extension Pack).

```
Nexsus-GovSearch/
├── config/
│   └── project-scratch-def.json
├── docs/
│   ├── architecture.md
│   ├── deployment.md
│   ├── data-model.md
│   ├── sample-data.md
│   └── lwc-stubs.md
├── force-app/
│   └── main/
│       └── default/
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

1. Install the [Salesforce Extension Pack](https://marketplace.visualstudio.com/items?itemName=salesforce.salesforcedx-vscode) in Visual Studio Code.
2. Clone this repository:
   ```bash
   git clone https://github.com/Hectorcaban-sudo/Nexsus-GovSearch.git
   cd Nexsus-GovSearch
   ```
3. Open the folder in VS Code.
4. Authorize a Dev Hub (or use a scratch org definition).
5. Create a scratch org:
   ```bash
   sf org create scratch --definition-file config/project-scratch-def.json --alias nexsus-govsearch --duration-days 7 --set-default
   ```
6. Push source:
   ```bash
   sf project deploy start
   ```
   (or use the VS Code “Deploy Source to Org” command)

See [docs/deployment.md](docs/deployment.md) for full deployment, packaging, and Agentforce setup instructions.

## Status

This repository contains the Salesforce DX project scaffolding, architecture documentation, custom objects (including Pipeline_Candidate__c), fields, layouts, permission sets, pure LWC stubs, and Agentforce sketches.

## License

Internal / proprietary. Contact the repository owner for usage rights.
