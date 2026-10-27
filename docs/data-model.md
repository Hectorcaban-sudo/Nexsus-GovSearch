# Nexsus GovSearch Data Model

Updated to align with the GovCon Capture & Market Intelligence requirements (MVP).

## Core Objects

### Pipeline_Candidate__c (Opportunity Intel)
AI-qualified pipeline candidate (recompete, solicitation, or task order) that can be promoted to an Opportunity (Pursuit).
- External_Id__c (unique, source lineage)
- Agency__c, Candidate_Type__c, Estimated_Value__c
- AI_Relevancy_Score__c, Strategic_Fit__c, Status__c
- Source_System__c, Due_Date__c, NAICS__c, Incumbent__c
- **Triage_Status__c** (New / Watch / Promote / Dismiss)
- **Dismiss_Reason__c**
- **Related_Opportunity__c** (lookup when promoted)

### Solicitation__c
Solicitation details linked to Pipeline Candidate or Opportunity.

### Award__c
Award history for incumbents, recompetes, and market analysis.

### Contract_Vehicle__c
GWAC, IDIQ, GSA MAS, BPA records.

### Government_Contact__c
Decision makers with bio and influence rating.

### Agency_Hierarchy__c
Hierarchical agency/office structure.

### Past_Performance_Profile__c
Company historical awards used for scoring.

### Strategic_Objective__c
Business unit goals that influence relevance.

### Integration_Log__c
Structured logs for all integrations and scoring.

## MVP Objects (Scaffolded + Key Fields)

### Company_Profile__c
Singleton company profile for fit scoring.
- Primary_NAICS__c
- Set_Aside_Eligibility__c (8(a), SDVOSB, WOSB, HUBZone, Small)

### Fit_Rule__mdt (Custom Metadata)
Configurable scoring weights and conditions against the Company Profile.

### Notice_Version__c
- Master-detail to Pipeline_Candidate__c
- Change_Summary__c

### Forecast__c
Agency procurement forecast entry.

### Gate_Review__c
- Master-detail to Opportunity
- Gate_Number__c (Gate 0–4)
- Decision__c (Pending / Approved / Rejected / Conditional)

### Bid_Decision_Scorecard__c
- Master-detail to Opportunity

### Capture_Plan__c
- Master-detail to Opportunity
- Win_Themes__c

### Saved_Search__c
User-defined search criteria and alert settings.

### Teaming_Partner__c
- Master-detail to Opportunity
- Partner_Account__c (lookup to Account)
- Workshare_Percent__c

### Call_Report__c
- Related_Opportunity__c
- Objectives__c

## Opportunity (Pursuit) Extensions

| Field | Type | Purpose |
|-------|------|---------|
| AI_Relevancy_Score__c | Number | 0–100 AI fit score |
| Strategic_Fit__c | Picklist | High / Medium / Low |
| Incumbent__c | Text | Current holder |
| Pursuit_Priority__c | Picklist | High / Medium / Low / Watch |
| AI_Brief_Summary__c | Long Text Area | Generated brief |
| NAICS_Tags__c | Text | Capability tags |
| pWin__c | Percent | Probability of win |
| pGo__c | Percent | Probability of go |

## Key Relationships

- Pipeline_Candidate__c → Opportunity (Related_Opportunity__c)
- Notice_Version__c → Pipeline_Candidate__c (master-detail)
- Gate_Review__c, Bid_Decision_Scorecard__c, Capture_Plan__c, Teaming_Partner__c → Opportunity (master-detail)
- Teaming_Partner__c → Account (Partner_Account__c)
- Call_Report__c → Opportunity
- Company_Profile__c drives Fit_Rule__mdt scoring

## Permission Sets

- Nexsus_BD_Analyst
- Nexsus_Capture_Manager
- Nexsus_Growth_Executive

See also `docs/requirements-gap-analysis.md` and `docs/mvp-implementation-notes.md`.
