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

## Post-Deploy Configuration

1. Assign the **Nexsus GovSearch User** permission set.
2. Open the **Nexsus GovSearch** Lightning App.
3. Add the `pipelineCandidateList` LWC to a Home or App page.
4. Add the `opportunityAiBriefCard` LWC to Opportunity record pages.
5. (Optional) Create a Named Credential named `SamGov` for the callout service.
6. (Optional) Create a Connected App to secure the Ingestion API.

## Agentforce Setup

1. In Setup → Agentforce Studio / Agent Builder, create the three agents:
   - Pipeline Scout
   - Opportunity Intelligence
   - Research & Relationship
2. Configure topics and expose Apex actions (`PipelineScoutService`, `OpportunityIntelligenceService`).
3. Ground agents on Salesforce records and/or Data Cloud.
4. Enable the Agentforce panel on relevant record pages.

## Integration Setup

- **Ingestion API**: Available at `/services/apexrest/nexsus/pipeline-candidates`. See [external-data-sources.md](external-data-sources.md).
- **Callouts**: Invoke `PipelineScoutCalloutService.syncAndScore()` from a Schedulable or button.
- All integration activity is logged to `Integration_Log__c`.

## Packaging (Optional Unlocked Package)

```bash
sf package create --name "Nexsus GovSearch" --type Unlocked --path force-app
sf package version create --package "Nexsus GovSearch" --installation-key YourKey --wait 10
```

## Production Considerations

- Configure Named Credentials / Connected Apps for external systems.
- Set up scheduled jobs for callout-based sync if desired.
- Apply Government Cloud security settings.
- Review Agentforce compliance notes and audit Integration Logs.

## Troubleshooting

- Check `Integration_Log__c` for callout, ingestion, and scoring errors.
- Ensure source API version in `sfdx-project.json` matches your org.
- Verify agent user permissions.
- Use `sf project deploy report` for metadata issues.
