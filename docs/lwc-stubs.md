# Pure LWC Components

OmniStudio FlexCards have been replaced with pure Lightning Web Components. These components are designed to approximate the Nexsus GovSearch mockups.

## Components

### pipelineCandidateList
- Dashboard with four summary cards: Top 5 Best-Fit Leads, Total Pipeline Value, New High-Score Alerts, Pipeline Health
- Datatable sorted by AI Relevancy Score with score coloring
- Exposed to App Page, Home Page, and Record Page
- Wires to `PipelineScoutService.getTopCandidates()`

### opportunityAiBriefCard
- Relevancy Score with progress bar
- Priority, Incumbent, NAICS
- Three-column structured brief: Incumbent Strengths, Competitive Whitespace, Pursuit Prioritization
- Full AI Brief Summary
- Designed for Opportunity record pages
- Uses Lightning Data Service

### contactsOrgChart
- Agency / Office Hierarchy tree (left)
- Senior Decision-Maker Contacts table (center)
- Research & Relationship Agent-style panel with Key Influencers and Recommended Call Plan (right)
- Currently uses sample data; wire to `ResearchRelationshipService` and `Government_Contact__c` for production
- Exposed to App Page, Home Page, Record Page, and Tab

### Notes
- These components closely follow the provided mockups.
- No OmniStudio dependency.
- Add them via Lightning App Builder after deployment.
- Load sample data from `docs/sample-data.md` for realistic appearance.
