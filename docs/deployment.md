# Deployment Instructions

## Prerequisites

- Salesforce Developer or Enterprise Edition org with Agentforce enabled (Employee agents)
- Dev Hub org (for scratch orgs)
- Salesforce CLI (`sf`) installed
- Visual Studio Code + Salesforce Extension Pack
- (Optional) Data Cloud and MuleSoft for production data ingestion

## Local Development Setup

1. Clone the repository and open in VS Code:
   ```bash
   git clone https://github.com/Hectorcaban-sudo/Nexsus-GovSearch.git
   cd Nexsus-GovSearch
   code .
   ```

2. Authorize your Dev Hub:
   ```bash
   sf org login web --set-default-dev-hub --alias DevHub
   ```

3. Create a scratch org:
   ```bash
   sf org create scratch \
     --definition-file config/project-scratch-def.json \
     --alias nexsus-govsearch \
     --duration-days 7 \
     --set-default
   ```

4. Deploy the source:
   ```bash
   sf project deploy start
   ```
   Or right-click `force-app` in VS Code → **SFDX: Deploy Source to Org**.

5. Open the scratch org:
   ```bash
   sf org open
   ```

## Agentforce Setup (Post-Deploy)

1. In Setup → Agentforce Studio / Agent Builder, create or import the three agents:
   - Pipeline Scout
   - Opportunity Intelligence
   - Research & Relationship
2. Configure topics, actions (Apex, Flows, Prompt Templates), and grounding data sources.
3. Assign agent users with appropriate permission sets.
4. Enable the Agentforce panel on Opportunity, Award, and Contract Vehicle record pages.
5. Create the custom Lightning App “Nexsus GovSearch” and add navigation items.

## Packaging (Optional Unlocked Package)

Update `sfdx-project.json` packageAliases after creating the package:

```bash
sf package create --name "Nexsus GovSearch" --type Unlocked --path force-app
sf package version create --package "Nexsus GovSearch" --installation-key YourKey --wait 10
```

Then install in target orgs with `sf package install`.

## Production Considerations

- Use a packaging org or unlocked package for controlled releases.
- Configure Named Credentials / External Services for SAM.gov, USAspending, etc.
- Set up scheduled Flows or Apex for data refresh.
- Apply Government Cloud security settings and review Agentforce compliance notes.
- Test scoring logic and brief generation with sample past-performance data.

## Troubleshooting

- Ensure source API version in `sfdx-project.json` matches your org.
- Check agent user permissions if agents cannot query records.
- Review Agentforce audit logs for failed actions.
- Use `sf project deploy report` and VS Code Problems panel for metadata errors.
