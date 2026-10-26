# Pure LWC Stubs

OmniStudio FlexCards have been replaced with pure Lightning Web Components.

## Components

### pipelineCandidateList
- Displays top Pipeline Candidates
- Exposed to App Page, Home Page, and Record Page
- Currently wires to `PipelineScoutService.getTopCandidates` (stub Apex method — implement as needed)

### opportunityAiBriefCard
- Displays AI Relevancy Score, Strategic Fit, Pursuit Priority, Incumbent, and AI Brief Summary
- Designed for Opportunity record pages
- Uses Lightning Data Service (`getRecord`)

### Notes
- These are functional stubs. Enhance with sorting, filtering, navigation, and Agentforce actions as needed.
- No OmniStudio dependency.
- Deploy and add the components via Lightning App Builder.
