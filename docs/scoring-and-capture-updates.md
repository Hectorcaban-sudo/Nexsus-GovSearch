# Scoring and Capture Updates

## Criteria-Based Scoring

### Company Profile expansions
- Primary_NAICS__c, Secondary_NAICS__c
- PSC_Codes__c
- Vehicles_Held__c
- Target_Agencies__c
- Set_Aside_Eligibility__c (existing)

### Fit Rule criteria
- Target_Field__c (e.g. NAICS__c, Agency__c, Candidate_Type__c)
- Operator__c (Equals, Contains, Starts With, Greater Than)
- Value__c
- Weight__c

### Scoring behavior (`PipelineScoutService`)
- Awards points only on actual matches against Company Profile and Fit Rules.
- Stores plain-language reasons in `Pipeline_Candidate__c.Score_Reasons__c`.
- Reasons are available for QUAL-06 explanations and Agentforce grounding.

## Gate Review Controls
- Checklist_Complete__c
- Approver__c (User lookup)
- Approval_Status__c
- Approval Process: `Gate_Review_Approval` (routes to Approver__c)
- Validation rule stub on Opportunity to block stage advance without approved Gate 0 (full enforcement recommended via Flow or Apex).

## Bid/No-Bid Scorecard
- Technical_Fit_Weight__c / Technical_Fit_Score__c
- Price_Competitiveness_Weight__c / Price_Competitiveness_Score__c
- Weighted_Score__c (formula)
- Recommendation__c (formula: Bid / Conditional Bid / No-Bid)

## Opportunity
- Weighted_Value__c = Amount × pWin × pGo
- Field History Tracking enabled on pWin__c and Opportunity

## Notes
- Approval Process field updates (`Gate_Approved` / `Gate_Rejected`) should be created as Field Update actions in the org or added as metadata.
- Stage-blocking validation is intentionally simplified; replace the FALSE condition with a proper rollup or Flow-based check for production.
- Scoring currently evaluates a limited set of fields; extend `matchesRule` as new criteria fields are added.
