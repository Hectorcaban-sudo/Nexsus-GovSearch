# Deployment Instructions

This guide covers deploying Nexsus GovSearch, configuring integrations (including SAM.gov and Data Cloud), and setting up Agentforce agents.

## Prerequisites

- Salesforce Developer or Enterprise Edition org with:
  - Agentforce enabled (Employee agents)
  - (Recommended) Data Cloud enabled
- Dev Hub org (for scratch orgs)
- Salesforce CLI (`sf`) installed
- Visual Studio Code + Salesforce Extension Pack
- SAM.gov public API key (from the SAM.gov Account Details page)
- (Optional) MuleSoft Anypoint Platform for production-scale transformations

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

1. Assign the **Nexsus GovSearch User** permission set to users who will access the app.
2. Open the **Nexsus GovSearch** Lightning App.
3. Add the `pipelineCandidateList` LWC to a Home page or App page.
4. Add the `opportunityAiBriefCard` LWC to Opportunity record pages (via Lightning App Builder).
5. Verify `Integration_Log__c` is available for reviewing integration activity.

## Agentforce Setup & Deployment

1. In Setup → **Agentforce Studio** (or Agent Builder), create the three Employee Agents:

   **Pipeline Scout Agent**
   - Purpose: Score and surface best-fit Pipeline Candidates.
   - Topics: Score and Rank Candidates, Surface High-Score Alerts, Convert to Opportunity.
   - Actions: Expose `PipelineScoutService.getTopCandidates` and `PipelineScoutService.refreshScores`.
   - Grounding: `Pipeline_Candidate__c` records and (if available) the Data Cloud Pipeline Candidate DMO.

   **Opportunity Intelligence Agent**
   - Purpose: Generate AI-authored briefs.
   - Topics: Generate Pursuit Brief, Answer Follow-up Questions.
   - Actions: Expose methods from `OpportunityIntelligenceService`.
   - Grounding: Opportunity, related Pipeline Candidates, Awards, and documents.

   **Research & Relationship Agent**
   - Purpose: Market analysis, competitor intelligence, and contact planning.
   - Topics: Identify Key Decision Makers, Competitive & Partner Analysis, Build Call Plan.
   - Grounding: `Government_Contact__c`, `Agency_Hierarchy__c`, `Award__c`.

2. Configure agent users with the Nexsus GovSearch User permission set (least privilege).
3. Enable the Agentforce panel on:
   - Opportunity record pages
   - Pipeline Candidate record pages (if desired)
   - Home / App pages
4. Test each agent with sample utterances (see `docs/agentforce/agent-sketches.md`).
5. (Optional) Export agent metadata into the project under the appropriate `genAi` folders once stable.

## Integration Setup

### Option A: Data Cloud Ingestion API (Recommended for Scale)

1. Enable Data Cloud in the org.
2. Create a Connected App with the scopes required for the Data Cloud Ingestion API.
3. Define a Data Stream and Data Model Object (DMO) for Pipeline Candidates.  
   Recommended fields: `externalId`, `name`, `agency`, `candidateType`, `estimatedValue`, `naics`, `dueDate`, `sourceSystem`, `incumbent`, `status`.
4. Configure Data Cloud-to-CRM sync targeting `Pipeline_Candidate__c` (match on `External_Id__c`).
5. Use middleware (MuleSoft or custom) to:
   - Call the SAM.gov Get Opportunities API:  
     `GET https://api.sam.gov/opportunities/v2/search?api_key=YOUR_KEY&postedFrom=MM/dd/yyyy&postedTo=MM/dd/yyyy&limit=1000&offset=0`
   - Transform the `opportunitiesData` array to the DMO payload.
   - POST the records to the Data Cloud Ingestion API.
6. Ground Agentforce agents on the Data Cloud DMO and/or the synced CRM records.
7. After CRM sync, scoring can be triggered via `PipelineScoutService.refreshScoresFor` or a Flow.

See `docs/external-data-sources.md` for the full SAM.gov field mapping and example payload.

### Option B: Apex Callout (Pull)

1. Create a Named Credential named `SamGov` that points to `https://api.sam.gov` and stores the API key securely (or pass it as a query parameter via the credential).
2. Invoke the sync:
   ```apex
   PipelineScoutCalloutService.syncAndScore();
   ```
3. Schedule it with a Schedulable class or call it from a button / Flow.
4. Review results in `Integration_Log__c`.

### Option C: Apex REST Ingestion API (Push into CRM)

1. Create a Connected App for the calling system with appropriate OAuth scopes.
2. External systems POST to:
   ```
   POST /services/apexrest/nexsus/pipeline-candidates
   ```
3. Successful records are upserted and automatically scored.
4. Monitor `Integration_Log__c` for errors.

### SAM.gov Specific Notes

- Obtain a public API key from the SAM.gov Account Details page.
- Respect the 1-year maximum date range for `postedFrom`/`postedTo`.
- Use pagination (`limit` max 1000 + `offset`).
- Daily rate limits vary by user role.
- Store the API key in a Named Credential or secure middleware configuration — never hard-code it.

## Sample Data & Testing

1. Load sample Pipeline Candidates (see `docs/sample-data.md` or create manually).
2. Run scoring:
   ```apex
   PipelineScoutService.refreshScores();
   ```
3. Open the Nexsus GovSearch app and verify the `pipelineCandidateList` dashboard.
4. Open an Opportunity and verify the `opportunityAiBriefCard`.
5. Test the Agentforce agents with the sample utterances from the agent sketches.

## Packaging (Optional Unlocked Package)

```bash
sf package create --name "Nexsus GovSearch" --type Unlocked --path force-app
sf package version create --package "Nexsus GovSearch" --installation-key YourKey --wait 10
```

Install in target orgs with `sf package install`.

## Production Considerations

- Prefer Data Cloud Ingestion API for high-volume SAM.gov and multi-source data.
- Configure Named Credentials / Connected Apps for all external systems.
- Set up scheduled jobs or event-driven syncs.
- Apply Government Cloud / FedRAMP security settings.
- Review Agentforce compliance notes and regularly audit `Integration_Log__c`.
- Implement retry and dead-letter handling in middleware for SAM.gov rate limits.
- Test scoring logic with realistic past-performance and strategic objective data.

## Troubleshooting

- Check `Integration_Log__c` for callout, ingestion, Data Cloud sync, and scoring errors.
- Verify the SAM.gov API key and date-range parameters if callouts return 400/401.
- Ensure source API version in `sfdx-project.json` matches your org.
- Confirm agent user permissions if agents cannot query records.
- Use `sf project deploy report` and the VS Code Problems panel for metadata errors.
- Review Data Cloud ingestion logs if records are not appearing in the DMO or CRM.

## Related Documentation

- [docs/architecture.md](architecture.md)
- [docs/diagrams.md](diagrams.md)
- [docs/external-data-sources.md](external-data-sources.md)
- [docs/data-model.md](data-model.md)
- [docs/agentforce/agent-sketches.md](agentforce/agent-sketches.md)
- [docs/lwc-stubs.md](lwc-stubs.md)
