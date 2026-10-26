# Sample Prompt Templates

These prompt templates can be created in Prompt Builder and referenced by Agentforce actions or Apex.

## Opportunity Pursuit Brief Template

**Name**: Opportunity_Pursuit_Brief  
**Type**: Field Generation or Flex Prompt  

**Prompt**:
```
You are a senior government contracting capture manager.

Opportunity: {!Opportunity.Name}
Account / Agency: {!Opportunity.Account.Name}
Stage: {!Opportunity.StageName}
Amount: {!Opportunity.Amount}
Close Date: {!Opportunity.CloseDate}
AI Relevancy Score: {!Opportunity.AI_Relevancy_Score__c}
Strategic Fit: {!Opportunity.Strategic_Fit__c}
Incumbent: {!Opportunity.Incumbent__c}
NAICS Tags: {!Opportunity.NAICS_Tags__c}

Related documents and notices are available in the record.

Generate a concise, expert-level pursuit brief with these sections:
1. **Incumbent Strengths** – Why the current holder is entrenched and any vulnerabilities.
2. **Competitive Whitespace** – Genuine opportunities to differentiate (technology, delivery, small business participation, innovation areas).
3. **Pursuit Prioritization** – High/Medium/Low recommendation with rationale, estimated win probability range, and 2-3 concrete next actions.

Write in a professional, actionable tone suitable for a BD/Capture team. Limit to 250-350 words.
```

## Pipeline Scoring Guidance Template

**Name**: Pipeline_Scoring_Guidance  

**Prompt**:
```
Evaluate the following opportunity against the company's past performance and strategic objectives.

Opportunity Summary: {!inputOpportunitySummary}
Past Performance Highlights: {!inputPastPerformance}
Strategic Objectives: {!inputStrategicObjectives}

Return a JSON object with:
- relevancyScore (integer 0-100)
- strategicFit ("High", "Medium", or "Low")
- rationale (string, 1-2 sentences)
```

These templates ground the Opportunity Intelligence and Pipeline Scout agents.
