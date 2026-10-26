# Nexsus GovSearch Data Model

## Custom Objects (Planned)

### Spark__c
Qualified lead before conversion to Opportunity.
- Name, Agency__c, Estimated_Value__c, AI_Relevancy_Score__c, Type__c (Recompete / Solicitation / Task Order), Source_System__c, Status__c

### Solicitation__c
- Solicitation_Number__c, Title__c, Agency__c, NAICS__c, PSC__c, Response_Date__c, Documents__c (files)

### Award__c
- Award_Number__c, Incumbent__c, Value__c, Expiration_Date__c, NAICS__c, Contract_Vehicle__c

### Contract_Vehicle__c
- Vehicle_Name__c, Type__c (IDIQ / BPA / etc.), Ordering_Period_End__c

### Government_Contact__c
- Name, Title__c, Agency_Office__c, Email__c, Phone__c, Bio_Snippet__c, Influence_Rating__c, Org_Chart_Parent__c

### Agency_Hierarchy__c
Hierarchical agency/office structure supporting org charts.

### Past_Performance_Profile__c
Company’s historical awards used for scoring.

### Strategic_Objective__c
Business unit / program goals that influence relevance scoring.

## Opportunity Extensions (Custom Fields)

| Field | Type | Purpose |
|-------|------|---------|
| AI_Relevancy_Score__c | Number | 0–100 AI fit score |
| Strategic_Fit__c | Picklist | High / Medium / Low |
| Incumbent__c | Text / Lookup | Current holder |
| Pursuit_Priority__c | Picklist | High / Medium / Low / Watch |
| AI_Brief_Summary__c | Long Text Area | Generated brief excerpt |
| NAICS_Tags__c | Multi-select / Text | Capability tags |
| Last_AI_Refresh__c | DateTime | When brief/score was last generated |

## Relationships

- Spark__c → Opportunity (conversion)
- Opportunity → Account (agency)
- Opportunity → Government_Contact__c (related list)
- Award__c / Solicitation__c → Opportunity (related)
- Agency_Hierarchy__c self-lookup for org chart

All objects will have appropriate page layouts, compact layouts, and search layouts once metadata is added.
