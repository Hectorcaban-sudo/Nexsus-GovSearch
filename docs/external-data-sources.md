# External Data Sources & Mapping Guide

This guide covers setting up external federal data sources for Nexsus GovSearch, including recommended integration patterns, field mappings, and best practices.

## Supported Sources

| Source | Primary Data | Recommended Integration |
|--------|--------------|-------------------------|
| SAM.gov | Opportunities, Solicitations, Notices | Apex callouts, Ingestion API, MuleSoft, or Data Cloud |
| USAspending | Awards, Obligated Spend, Vendors | Apex callouts, Ingestion API, or scheduled sync |
| FedConnect | Task Orders, RFPs | MuleSoft or Ingestion API |
| PIEE | Invoices, Contract Data | MuleSoft preferred |
| Agency Forecasts | Planned procurements | Manual, Ingestion API, or scheduled import |
| Proprietary Contacts | Decision makers, org charts | Data Cloud or managed package |

## Recommended Architecture

1. **Data Cloud (preferred for scale)**  
   - Connect external sources via Data Cloud connectors or custom connectors.  
   - Use Data Cloud to unify and ground Agentforce agents.  
   - Sync key records into Salesforce custom objects via Data Streams or calculated insights.

2. **Ingestion API (Push from external systems)**  
   - Apex REST endpoint: `/services/apexrest/nexsus/pipeline-candidates`  
   - External systems, MuleSoft, or middleware POST Pipeline Candidate payloads.  
   - Supports single or bulk records, upserts via `External_Id__c`, and automatically triggers scoring.  
   - Ideal when the source system can push data or when you want to avoid Salesforce-initiated callouts.

3. **MuleSoft Anypoint Platform**  
   - Build APIs that normalize SAM.gov / USAspending data.  
   - Push enriched records into Salesforce via the Ingestion API, Composite API, or Bulk API.  
   - Handle authentication, rate limits, and transformation.

4. **Apex Callouts + Platform Events**  
   - Suitable for lighter volumes or proof-of-concept.  
   - Use Named Credentials for authentication.  
   - Publish Platform Events for real-time updates to Pipeline Candidates.

5. **Scheduled Apex / Batch**  
   - Nightly jobs that call external APIs and upsert Pipeline_Candidate__c, Solicitation__c, and Award__c records.

## Ingestion API Usage

**Endpoint**: `POST /services/apexrest/nexsus/pipeline-candidates`

**Authentication**: Standard Salesforce OAuth (Connected App) or Named Principal.

**Example Request Body**:
```json
{
  "candidates": [
    {
      "externalId": "SAM-123456",
      "name": "Army IT Modernization Recompete",
      "agency": "Department of the Army",
      "candidateType": "Recompete",
      "estimatedValue": 249000000,
      "naics": "541512",
      "dueDate": "2026-12-15",
      "sourceSystem": "SAM.gov",
      "incumbent": "Lockheed Martin",
      "status": "New"
    }
  ]
}
```

**Example Response** (200 or 207):
```json
{
  "success": true,
  "totalReceived": 1,
  "successCount": 1,
  "errorCount": 0,
  "errors": [],
  "processedExternalIds": ["SAM-123456"]
}
```

- Partial success returns HTTP 207 with details in the `errors` array.
- All activity is logged to `Integration_Log__c`.
- Successful records are automatically scored via `PipelineScoutService.refreshScoresFor`.

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
| noticeId or solicitationNumber | External_Id__c | Required for upsert |
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

1. **Create Named Credentials** for each external system (for callout pattern).
2. **Define External IDs** on Pipeline_Candidate__c, Solicitation__c, and Award__c for safe upserts.
3. **Choose push (Ingestion API) or pull (Callout)** based on source system capabilities.
4. **Build transformation logic** (MuleSoft DataWeave or Apex) that maps external schemas to the fields above.
5. **Schedule or event-drive** the sync.
6. **Trigger AI scoring** (Pipeline Scout Agent or Apex) after new records are inserted.
7. **Ground Agentforce** agents in the synced Salesforce records and/or Data Cloud.

## Security & Compliance Notes

- Use Named Credentials and External Credentials; never hard-code keys.
- For the Ingestion API, use a Connected App with least-privilege OAuth scopes.
- Respect rate limits and caching policies of federal APIs.
- For government orgs, validate data handling against your security policies and any FedRAMP or agency-specific requirements.
- Prefer Data Cloud or MuleSoft for production-scale integrations.

## Next Steps

- Implement `PipelineScoutService.refreshScores()` to recalculate AI Relevancy Scores after sync.
- Create Flows or Apex triggers that call scoring after new Pipeline Candidates are inserted.
- Expose scoring and brief-generation methods as Agentforce actions.
- Secure the Ingestion API with a Connected App and appropriate permission sets.

See also `docs/architecture.md` and `docs/data-model.md`.
