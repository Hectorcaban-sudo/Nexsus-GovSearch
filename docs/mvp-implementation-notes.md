# MVP Implementation Notes

## Triage Queue

- Field: `Pipeline_Candidate__c.Triage_Status__c` (New / Watch / Promote / Dismiss)
- Field: `Dismiss_Reason__c` (required on Dismiss via validation rule)
- Field: `Related_Opportunity__c` (populated when promoted)
- **Validation Rule**: `Dismiss_Reason_Required` enforces reason on Dismiss
- **Flow**: `Promote_Pipeline_Candidate` creates an Opportunity and links it when Triage Status changes to Promote and no Opportunity exists yet

## Scoring Wiring

`PipelineScoutService.refreshScoresFor` now:
1. Queries the singleton `Company_Profile__c`
2. Loads `Fit_Rule__mdt` records
3. Applies base rules + NAICS match from Company Profile + additive weights from Fit Rules
4. Writes `AI_Relevancy_Score__c` and `Strategic_Fit__c`

`Fit_Rule__mdt.Weight__c` field is available for rule configuration.

## Persona Permission Sets

| Permission Set | Persona | Key Access |
|----------------|---------|------------|
| Nexsus_BD_Analyst | BD / Opportunity Analyst | Create/edit Pipeline Candidates; read awards |
| Nexsus_Capture_Manager | Capture Manager | Full edit on Opportunities, Capture Plans, Gate Reviews |
| Nexsus_Growth_Executive | BD / Growth Executive | View All on Pipeline Candidates and Opportunities |

## Page Layouts

- Pipeline_Candidate__c-Pipeline Candidate Layout (includes Triage section)
- Capture_Plan__c-Capture Plan Layout
- Gate_Review__c-Gate Review Layout

## Next Code Tasks

- Expand Fit Rule criteria evaluation (currently additive weight)
- Saved Search alert engine (scheduled Apex)
- Admin console LWC for Integration_Log__c
- Additional layouts for Company Profile and Bid Decision Scorecard
- Field history tracking on key pursuit fields
