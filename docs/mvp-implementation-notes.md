# MVP Implementation Notes

## Triage Queue

- Field: `Pipeline_Candidate__c.Triage_Status__c` (New / Watch / Promote / Dismiss)
- Field: `Dismiss_Reason__c` (required on Dismiss via validation rule — to be added)
- Field: `Related_Opportunity__c` (populated when promoted)

**Recommended Flow / Apex action**
1. Analyst reviews scored candidates in the LWC or list view.
2. Sets Triage_Status__c to Promote.
3. Flow creates an Opportunity, copies key fields, and links back via Related_Opportunity__c.
4. Sets Status__c to Promoted.

## Scoring Wiring

`PipelineScoutService.refreshScoresFor` should:
1. Query the singleton `Company_Profile__c`.
2. Query active `Fit_Rule__mdt` records.
3. Apply weighted rules (NAICS match, set-aside eligibility, value, strategic objectives, past performance).
4. Write `AI_Relevancy_Score__c` and `Strategic_Fit__c`.

Custom metadata type `Fit_Rule__mdt` is ready for rule records.

## Persona Permission Sets

| Permission Set | Persona | Key Access |
|----------------|---------|------------|
| Nexsus_BD_Analyst | BD / Opportunity Analyst | Create/edit Pipeline Candidates; read awards |
| Nexsus_Capture_Manager | Capture Manager | Full edit on Opportunities, Capture Plans, Gate Reviews |
| Nexsus_Growth_Executive | BD / Growth Executive | View All on Pipeline Candidates and Opportunities |

Assign via Permission Set Groups for production.

## Layouts

Basic object metadata is in place. Create page layouts in the org or add layout XML for:
- Pipeline_Candidate__c (include Triage section)
- Capture_Plan__c
- Gate_Review__c
- Company_Profile__c

## Next Code Tasks

- Validation rule: Dismiss_Reason__c required when Triage_Status__c = Dismiss
- Apex triage action or Flow to promote to Opportunity
- Update PipelineScoutService to read Company_Profile__c + Fit_Rule__mdt
- Saved Search alert engine (scheduled Apex)
- Admin console LWC for Integration_Log__c
