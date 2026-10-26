# Nexsus GovSearch Data Model

## Custom Objects

### Pipeline_Candidate__c
AI-qualified pipeline candidate (recompete, solicitation, or task order) that can be converted to an Opportunity.
- Name
- External_Id__c (unique external ID for upserts)
- Agency__c
- Candidate_Type__c (Recompete / Solicitation / Task Order)
- Estimated_Value__c
- AI_Relevancy_Score__c
- Strategic_Fit__c
- Status__c
- Source_System__c
- Due_Date__c
- NAICS__c
- Incumbent__c

### Solicitation__c
- Solicitation_Number__c, Title__c, Agency__c, NAICS__c, PSC__c, Response_Date__c

### Award__c
- Award_Number__c, Incumbent__c, Value__c, Expiration_Date__c, NAICS__c

### Contract_Vehicle__c
- Vehicle_Name__c, Type__c (IDIQ / BPA / etc.), Ordering_Period_End__c

### Government_Contact__c
- Name, Title__c, Agency_Office__c, Email__c, Phone__c, Bio_Snippet__c, Influence_Rating__c

### Agency_Hierarchy__c
Hierarchical agency/office structure supporting org charts.

### Past_Performance_Profile__c
Company’s historical awards used for scoring.

### Strategic_Objective__c
Business unit / program goals that influence relevance scoring.

### Integration_Log__c
Structured logs for integrations, callouts, ingestion, and scoring.
- Level__c (INFO / WARN / ERROR)
- Source__c
- Message__c

## Opportunity Extensions (Custom Fields)

| Field | Type | Purpose |
|-------|------|---------|
| AI_Relevancy_Score__c | Number | 0–100 AI fit score |
| Strategic_Fit__c | Picklist | High / Medium / Low |
| Incumbent__c | Text | Current holder |
| Pursuit_Priority__c | Picklist | High / Medium / Low / Watch |
| AI_Brief_Summary__c | Long Text Area | Generated brief excerpt |
| NAICS_Tags__c | Text | Capability tags |

## Relationships

- Pipeline_Candidate__c → Opportunity (conversion)
- Opportunity → Account (agency)
- Opportunity → Government_Contact__c (related list)
- Award__c / Solicitation__c → Opportunity (related)
- Agency_Hierarchy__c self-lookup for org chart

Page layouts exist for Pipeline_Candidate__c and Opportunity. Additional compact and search layouts can be refined as needed.
