# External Data Sources & Mapping Guide

This guide covers setting up external federal data sources for Nexsus GovSearch, including recommended integration patterns, field mappings, and best practices.

## Supported Sources

| Source | Primary Data | Recommended Integration |
|--------|--------------|-------------------------|
| SAM.gov | Opportunities, Solicitations, Notices | Apex callouts, MuleSoft, or Data Cloud |
| USAspending | Awards, Obligated Spend, Vendors | Apex callouts or scheduled sync |
| FedConnect | Task Orders, RFPs | MuleSoft or custom Apex |
| PIEE | Invoices, Contract Data | MuleSoft preferred |
| Agency Forecasts | Planned procurements | Manual or scheduled import |
| Proprietary Contacts | Decision makers, org charts | Data Cloud or managed package |

## Recommended Architecture

1. **Data Cloud (preferred for scale)**  
   - Connect external sources via Data Cloud connectors or custom connectors.  
   - Use Data Cloud to unify and ground Agentforce agents.  
   - Sync key records into Salesforce custom objects via Data Streams or calculated insights.

2. **MuleSoft Anypoint Platform**  
   - Build APIs that normalize SAM.gov / USAspending data.  
   - Push enriched records into Salesforce via Composite API or Bulk API.  
   - Handle authentication, rate limits, and transformation.

3. **Apex Callouts + Platform Events**  
   - Suitable for lighter volumes or proof-of-concept.  
   - Use Named Credentials for authentication.  
   - Publish Platform Events for real-time updates to Pipeline Candidates.

4. **Scheduled Apex / Batch**  
   - Nightly jobs that call external APIs and upsert Pipeline_Candidate__c, Solicitation__c, and Award__c records.

## Field Mapping Examples

### SAM.gov Opportunity → Pipeline_Candidate__c

| External Field | Salesforce Field | Notes |
|----------------|------------------|-------|
| title | Name | |
| department / agency | Agency__c | |
| type (solicitation, award, etc.) | Candidate_Type__c | Map to Recompete / Solicitation / Task Order |
| estimatedValue or awardAmount | Estimated_Value__c | |
| naicsCode | NAICS__c | |
| responseDeadline | Due_Date__c | |
| noticeId or solicitationNumber | Source_System__c + external ID | Store external ID for upsert |
| incumbent / awardee | Incumbent__c | |

### USAspending Award → Award__c

| External Field | Salesforce Field | Notes |
|----------------|------------------|-------|
| award_id | Award_Number__c | |
| recipient_name | Incumbent__c | |
| total_obligation | Value__c | |
| period_of_performance_end | Expiration_Date__c | |
| naics_code | NAICS__c | |

### Contact Intelligence

Map senior decision makers into `Government_Contact__c` with:
- Title__c
- Bio_Snippet__c
- Influence_Rating__c
- Agency_Office__c
- Org chart parent relationship

## Implementation Steps

1. **Create Named Credentials** for each external system.
2. **Define External IDs** on Pipeline_Candidate__c, Solicitation__c, and Award__c for safe upserts.
3. **Build transformation logic** (MuleSoft DataWeave or Apex) that maps external schemas to the fields above.
4. **Schedule or event-drive** the sync.
5. **Trigger AI scoring** (Pipeline Scout Agent or Apex) after new records are inserted.
6. **Ground Agentforce** agents in the synced Salesforce records and/or Data Cloud.

## Security & Compliance Notes

- Use Named Credentials and External Credentials; never hard-code keys.
- Respect rate limits and caching policies of federal APIs.
- For government orgs, validate data handling against your security policies and any FedRAMP or agency-specific requirements.
- Prefer Data Cloud or MuleSoft for production-scale integrations.

## Next Steps

- Implement `PipelineScoutService.refreshScores()` to recalculate AI Relevancy Scores after sync.
- Create Flows or Apex triggers that call scoring after new Pipeline Candidates are inserted.
- Expose scoring and brief-generation methods as Agentforce actions.

See also `docs/architecture.md` and `docs/data-model.md`.
