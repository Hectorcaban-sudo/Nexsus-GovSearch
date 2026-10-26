# External Data Sources & Mapping Guide

This guide covers setting up external federal data sources for Nexsus GovSearch, including recommended integration patterns, field mappings, and best practices. SAM.gov is a primary source via the public Get Opportunities API.

## Supported Sources

| Source | Primary Data | Recommended Integration |
|--------|--------------|-------------------------|
| SAM.gov | Opportunities, Solicitations, Notices | Data Cloud Ingestion API, Apex callouts, or MuleSoft |
| USAspending | Awards, Obligated Spend, Vendors | Data Cloud, Apex callouts, or scheduled sync |
| FedConnect | Task Orders, RFPs | MuleSoft or Data Cloud |
| PIEE | Invoices, Contract Data | MuleSoft preferred |
| Agency Forecasts | Planned procurements | Data Cloud or manual import |
| Proprietary Contacts | Decision makers, org charts | Data Cloud or managed package |

## Recommended Architecture

1. **Data Cloud Ingestion API (preferred for scale)**  
   - Stream external data (including SAM.gov) into Data Cloud via the Ingestion API.  
   - Unify, enrich, and ground Agentforce agents directly on Data Cloud.  
   - Sync qualified records into Salesforce CRM objects (`Pipeline_Candidate__c`) via Data Cloud-to-CRM sync.

2. **Apex REST Ingestion API (Push into CRM)**  
   - Endpoint: `/services/apexrest/nexsus/pipeline-candidates`  
   - External systems or middleware POST payloads that upsert directly into `Pipeline_Candidate__c` and trigger scoring.

3. **MuleSoft Anypoint Platform**  
   - Normalize SAM.gov / USAspending data and push via Data Cloud Ingestion API or the Apex REST endpoint.

4. **Apex Callouts**  
   - Pull pattern using Named Credentials (see `PipelineScoutCalloutService`).

5. **Scheduled Apex / Batch**  
   - Nightly or incremental syncs.

## Data Cloud Ingestion API

Data Cloud’s Ingestion API is ideal for high-volume or continuous streaming from SAM.gov and other federal sources.

### High-Level Flow

1. External system or middleware calls the SAM.gov Get Opportunities API.
2. Transform the response and POST to the Data Cloud Ingestion API.
3. Data lands in a Data Stream / Data Model Object (DMO).
4. Apply calculated insights or identity resolution if needed.
5. Sync selected records to `Pipeline_Candidate__c` (match on `External_Id__c`).
6. Pipeline Scout scoring and Agentforce agents run against the CRM records and/or Data Cloud.

### Setup Steps

1. Enable Data Cloud in the org.
2. Create a Connected App (or use Data Cloud credentials) with the required Ingestion API scopes.
3. Define a Data Stream and DMO for Pipeline Candidates (see field mapping below).
4. Configure the Ingestion API endpoint for the source.
5. Build the transformation (MuleSoft DataWeave, Apex, or external middleware) from SAM.gov JSON to the DMO payload.
6. Set up Data Cloud-to-CRM sync targeting `Pipeline_Candidate__c`.
7. Ground Agentforce agents on the DMO and/or synced CRM records.
8. Monitor ingestion via Data Cloud logs and `Integration_Log__c` (if additional CRM-side logging is used).

### SAM.gov Get Opportunities Public API

- **Documentation**: https://open.gsa.gov/api/get-opportunities-public-api/
- **Production Endpoint**: `GET https://api.sam.gov/opportunities/v2/search`
- **Authentication**: Public API key (`api_key` query parameter). Generate on the SAM.gov Account Details page.
- **Key Parameters**:
  - `postedFrom` / `postedTo` (required, MM/dd/yyyy, max 1-year range)
  - `limit` (max 1000) and `offset` for pagination
  - `ptype`, `ncode` (NAICS), `organizationName`, `rdlfrom`/`rdlto`, etc.
- **Response**: `opportunitiesData` array of opportunity objects.
- **Rate Limits**: Daily limits vary by user role (federal / non-federal / general).

**Important SAM.gov Fields**:
- `noticeId` — unique identifier
- `title`
- `solicitationNumber`
- `fullParentPathName` — hierarchical agency/office
- `type` / `baseType`
- `postedDate`
- `responseDeadLine`
- `naicsCode`
- `award` object (amount, awardee, date)
- `pointOfContact` array
- `setAside` / `setAsideCode`
- `active`

### Data Cloud DMO Field Mapping (SAM.gov → Pipeline Candidate)

| SAM.gov Field | Data Cloud DMO Field | Salesforce CRM Field | Notes |
|---------------|----------------------|----------------------|-------|
| noticeId | externalId | External_Id__c | Primary match key for upsert |
| title | name | Name | |
| fullParentPathName | agency | Agency__c | Hierarchical agency name |
| type or baseType | candidateType | Candidate_Type__c | Map: Solicitation, Award Notice, etc. → Solicitation / Recompete / Task Order |
| award.amount (if present) | estimatedValue | Estimated_Value__c | Or use other value fields when available |
| naicsCode | naics | NAICS__c | |
| responseDeadLine | dueDate | Due_Date__c | Parse date |
| award.awardee.name (if present) | incumbent | Incumbent__c | |
| (constant) | sourceSystem | Source_System__c | "SAM.gov" |
| active | status | Status__c | Map Yes → New/Active |

### Example Data Cloud Ingestion Payload Concept

```json
{
  "records": [
    {
      "externalId": "abc123-notice-id",
      "name": "IT Modernization Support Services",
      "agency": "Department of Defense.Department of the Army",
      "candidateType": "Solicitation",
      "estimatedValue": 15000000,
      "naics": "541512",
      "dueDate": "2026-11-30",
      "sourceSystem": "SAM.gov",
      "incumbent": null,
      "status": "New"
    }
  ]
}
```

### Apex REST Ingestion API (Alternative / Complement)

**Endpoint**: `POST /services/apexrest/nexsus/pipeline-candidates`

Use this when you want to write directly into CRM objects. See previous sections for request/response examples. It automatically triggers `PipelineScoutService.refreshScoresFor`.

## Implementation Steps

1. Obtain a SAM.gov public API key.
2. Choose the primary ingestion path:
   - Data Cloud Ingestion API (recommended for scale + Agentforce grounding)
   - Apex Callout (`PipelineScoutCalloutService`)
   - Apex REST Ingestion API
3. Implement transformation logic that maps SAM.gov fields to the DMO or CRM fields above.
4. Configure pagination and incremental loads (use `postedFrom`/`postedTo` windows).
5. Set up Data Cloud-to-CRM sync if using Data Cloud.
6. Trigger AI scoring after new Pipeline Candidates arrive.
7. Ground Agentforce agents appropriately.
8. Monitor rate limits and log failures.

## Security & Compliance Notes

- Store the SAM.gov API key securely (Named Credential, External Credential, or secure middleware).
- For Data Cloud, use least-privilege Connected App scopes.
- Respect SAM.gov daily rate limits and the 1-year date-range restriction.
- For government orgs, validate data handling against FedRAMP and agency policies.
- Prefer Data Cloud for production-scale federal data.

## Next Steps

- Implement a SAM.gov-specific callout or middleware transformation.
- Create the Data Cloud Data Stream and DMO.
- Configure CRM sync to `Pipeline_Candidate__c`.
- Enhance scoring logic to use past-performance and strategic objective data.
- Expose scoring and brief-generation methods as Agentforce actions.

See also `docs/architecture.md`, `docs/data-model.md`, and `docs/diagrams.md`.
