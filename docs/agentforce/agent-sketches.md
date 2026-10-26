# Agentforce Agent Configuration Sketches

These are design sketches for the three core Agentforce agents in Nexsus GovSearch. Actual agents are created in Agentforce Studio / Agent Builder and can be exported as metadata when ready.

## 1. Pipeline Scout Agent

**Type**: Employee Agent  
**Purpose**: Continuously identify and score best-fit recompetes, solicitations, and task orders.

### Topics / Subagents
- **Score and Rank Opportunities**
  - Instructions: Analyze past performance profiles, strategic objectives, NAICS/PSC alignment, contract vehicle access, and historical win rates. Assign AI Relevancy Score (0-100) and Strategic Fit.
  - Actions: Query Opportunities / Sparks, update AI_Relevancy_Score__c and Strategic_Fit__c, create Spark__c records.
- **Surface High-Score Alerts**
  - Instructions: Notify users of new opportunities scoring ≥ 85 that match business unit filters.
  - Actions: Query recent records, send notifications or Platform Events.

### Example Utterances
- "Show me the top 10 best-fit opportunities this week."
- "Score this solicitation against our past performance."
- "Create a Spark for the Army IT Modernization recompete."

## 2. Opportunity Intelligence Agent

**Type**: Employee Agent  
**Purpose**: Generate expert AI-authored briefs on Opportunity, Award, and Contract Vehicle records.

### Topics / Subagents
- **Generate Pursuit Brief**
  - Instructions: Produce a concise brief covering: (1) Incumbent strengths and why they hold the position, (2) Competitive whitespace / differentiation opportunities, (3) Pursuit prioritization recommendation with rationale and next actions. Ground in record data, related notices, documents, and external sources.
  - Actions: Update AI_Brief_Summary__c, call Prompt Template, summarize attached files.
- **Answer Follow-up Questions**
  - Instructions: Respond conversationally about risks, teaming, key decision makers, or win themes for the current record.
  - Actions: Query related Government_Contact__c, Award__c, etc.

### Example Utterances
- "Generate an AI brief for this opportunity."
- "Who is the incumbent and what are their weaknesses?"
- "What is the recommended pursuit priority and why?"

### Sample Prompt Template (Sketch)
```
You are an expert government contracting capture analyst.
Given the following opportunity details:
{!Opportunity.Name}
Agency: {!Opportunity.Account.Name}
Incumbent: {!Opportunity.Incumbent__c}
NAICS: {!Opportunity.NAICS_Tags__c}
Related Award Value: {!relatedAward.Value__c}

Generate a structured brief with sections:
1. Incumbent Analysis
2. Competitive Whitespace
3. Pursuit Prioritization & Recommended Actions
Keep the response concise, actionable, and professional.
```

## 3. Research & Relationship Agent

**Type**: Employee Agent  
**Purpose**: Support market analysis, competitor intelligence, partner matchmaking, and contact/org-chart planning.

### Topics / Subagents
- **Identify Key Decision Makers**
  - Instructions: Recommend senior contacts and influencers for a given agency/office based on hierarchy and influence ratings.
  - Actions: Query Government_Contact__c and Agency_Hierarchy__c.
- **Competitive & Partner Analysis**
  - Instructions: Summarize top vendors by obligated spend, identify teaming candidates with past performance overlap.
  - Actions: Query Award__c, related accounts.
- **Build Call Plan**
  - Instructions: Suggest talking points and engagement sequence for selected contacts.

### Example Utterances
- "Who are the key influencers in PEO C3T?"
- "Show top competitors on this contract vehicle."
- "Suggest a call plan for the Assistant Secretary."

## Implementation Notes
- Create agents in Agentforce Studio after deploying base metadata.
- Ground agents in Data Cloud (for external federal data) and Salesforce records.
- Use least-privilege agent users.
- Require human confirmation before record updates.
- Export agent metadata (when available) into this project under `force-app/main/default/genAi*` or equivalent folders in future releases.

See also the sample Apex actions (`PipelineScoutService`, `OpportunityIntelligenceService`) that can be exposed as Agentforce actions.
