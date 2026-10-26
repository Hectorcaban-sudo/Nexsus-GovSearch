# Agentforce Agent Configuration Sketches

These are refined design sketches for the three core Agentforce agents in Nexsus GovSearch. Actual agents are created in Agentforce Studio / Agent Builder.

## 1. Pipeline Scout Agent

**Type**: Employee Agent  
**Purpose**: Continuously identify, score, and surface best-fit Pipeline Candidates (recompetes, solicitations, and task orders).

### Topics / Subagents
- **Score and Rank Candidates**
  - Instructions: Analyze past performance profiles, strategic objectives, NAICS/PSC alignment, contract vehicle access, and historical win rates. Assign AI Relevancy Score (0-100) and Strategic Fit. Prefer candidates with scores ≥ 80.
  - Actions: Query Pipeline_Candidate__c and Opportunities, update AI_Relevancy_Score__c, create new Pipeline_Candidate__c records from external data.
- **Surface High-Score Alerts**
  - Instructions: Notify users of new Pipeline Candidates scoring ≥ 85 that match business unit or agency filters.
  - Actions: Query recent Pipeline_Candidate__c, send notifications or Platform Events.
- **Convert to Opportunity**
  - Instructions: When a user qualifies a candidate, convert it to an Opportunity and link related data.
  - Actions: Create Opportunity, update Status__c to "Converted to Opportunity".

### Example Utterances
- "Show me the top 10 best-fit Pipeline Candidates this week."
- "Score this solicitation against our past performance."
- "Create a Pipeline Candidate for the Army IT Modernization recompete."
- "Convert the top DHS candidate to an Opportunity."

## 2. Opportunity Intelligence Agent

**Type**: Employee Agent  
**Purpose**: Generate expert AI-authored briefs on Opportunity, Award, and Contract Vehicle records.

### Topics / Subagents
- **Generate Pursuit Brief**
  - Instructions: Produce a concise brief covering: (1) Incumbent strengths and why they hold the position, (2) Competitive whitespace / differentiation opportunities, (3) Pursuit prioritization recommendation with rationale and next actions. Ground in record data, related notices, documents, Pipeline Candidates, and external sources. Update the AI_Brief_Summary__c field.
  - Actions: Update AI_Brief_Summary__c, call Prompt Template, summarize attached files.
- **Answer Follow-up Questions**
  - Instructions: Respond conversationally about risks, teaming, key decision makers, win themes, or competitive landscape for the current record.
  - Actions: Query related Government_Contact__c, Award__c, Pipeline_Candidate__c, etc.

### Example Utterances
- "Generate an AI brief for this opportunity."
- "Who is the incumbent and what are their weaknesses?"
- "What is the recommended pursuit priority and why?"
- "Refresh the brief with the latest documents."

## 3. Research & Relationship Agent

**Type**: Employee Agent  
**Purpose**: Support market analysis, competitor intelligence, partner matchmaking, and contact/org-chart planning.

### Topics / Subagents
- **Identify Key Decision Makers**
  - Instructions: Recommend senior contacts and influencers for a given agency/office based on hierarchy and influence ratings. Suggest engagement sequence.
  - Actions: Query Government_Contact__c and Agency_Hierarchy__c.
- **Competitive & Partner Analysis**
  - Instructions: Summarize top vendors by obligated spend, identify teaming candidates with past performance overlap on similar NAICS or vehicles.
  - Actions: Query Award__c and related accounts.
- **Build Call Plan**
  - Instructions: Suggest talking points, objectives, and timing for selected contacts related to a Pipeline Candidate or Opportunity.

### Example Utterances
- "Who are the key influencers in PEO C3T?"
- "Show top competitors on this contract vehicle."
- "Suggest a call plan for the Assistant Secretary related to the Army IT opportunity."

## Implementation Notes
- Create agents in Agentforce Studio after deploying base metadata.
- Ground agents in Data Cloud (for external federal data) and Salesforce records.
- Use least-privilege agent users.
- Require human confirmation before record updates or Opportunity conversion.
- Expose Apex actions (PipelineScoutService, OpportunityIntelligenceService) as Agentforce actions.
- Export agent metadata into this project under appropriate genAi folders when ready.

See also docs/agentforce/prompt-templates.md for prompt examples.
