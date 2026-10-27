# Nexsus GovSearch Data Model

Updated to align with the GovCon Capture & Market Intelligence requirements (MVP).

## Core Objects

### Pipeline_Candidate__c (Opportunity Intel)
AI-qualified pipeline candidate (recompete, solicitation, or task order) that can be promoted to an Opportunity (Pursuit).
- External_Id__c (unique, source lineage)
- Agency__c, Candidate_Type__c, Estimated_Value__c
- AI_Relevancy_Score__c, Strategic_Fit__c, Status__c
- Source_System__c, Due_Date__c, NAICS__c, Incumbent__c
- **Triage status** (Promote / Watch / Dismiss) to be added

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

## MVP Objects (Scaffolded)

### Company_Profile__c
Singleton company profile for fit scoring.
- Primary_NAICS__c
- Set_Aside_Eligibility__c (8(a), SDVOSB, WOSB, HUBZone, Small)
- Core capabilities, certifications, target agencies (to be expanded)

### Fit_Rule__mdt (Custom Metadata)
Configurable scoring weights and conditions against the Company Profile.

### Notice_Version__c
Amendment / modification snapshot of a Pipeline Candidate.
- Parent: Pipeline_Candidate__c
- Changed fields (due date, set-aside, NAICS, scope)

### Forecast__c
Agency procurement forecast entry that can later link to a solicitation.

### Gate_Review__c
Gate checklist, decision, and approvers for a Pursuit (Opportunity).
- Parent: Opportunity
- Gate number, checklist, decision, approvers

### Bid_Decision_Scorecard__c
Weighted bid/no-bid criteria and outcome.
- Parent: Opportunity

### Capture_Plan__c
Win themes, discriminators, solution approach, price-to-win, risks.
- Parent: Opportunity (1:1)

### Saved_Search__c
User-defined search criteria and alert settings.
- Owner, criteria, alert frequency

### Teaming_Partner__c
Partner role, workshare %, and capability on a Pursuit.
- Parent: Opportunity
- Lookup to Account (partner)

### Call_Report__c
Customer engagement record.
- Related to Contact, Agency, Opportunity
- Objectives, outcomes, follow-ups

## Opportunity (Pursuit) Extensions

| Field | Type | Purpose |
|-------|------|---------|
| AI_Relevancy_Score__c | Number | 0–100 AI fit score |
| Strategic_Fit__c | Picklist | High / Medium / Low |
| Incumbent__c | Text | Current holder |
| Pursuit_Priority__c | Picklist | High / Medium / Low / Watch |
| AI_Brief_Summary__c | Long Text Area | Generated brief |
| NAICS_Tags__c | Text | Capability tags |
| pWin__c | Percent | Probability of win (to be added) |
| pGo__c | Percent | Probability of go (to be added) |
| Weighted_Value__c | Currency | TCV × pWin × pGo (to be added) |

## Key Relationships

- Pipeline_Candidate__c → Opportunity (promotion / conversion)
- Notice_Version__c → Pipeline_Candidate__c
- Forecast__c → Agency / later Pipeline_Candidate__c
- Gate_Review__c, Bid_Decision_Scorecard__c, Capture_Plan__c, Teaming_Partner__c → Opportunity
- Call_Report__c → Contact, Account (Agency), Opportunity
- Company_Profile__c drives Fit_Rule__mdt scoring
- Saved_Search__c → User

## Next Field & Layout Work

- Expand fields on all new objects
- Add page layouts for Gate Review, Capture Plan, Company Profile
- Permission sets per persona
- Triage status and actions on Pipeline_Candidate__c

See also `docs/requirements-gap-analysis.md`.
