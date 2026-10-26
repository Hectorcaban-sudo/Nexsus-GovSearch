# Pure LWC Components

OmniStudio FlexCards have been replaced with pure Lightning Web Components.

## Components

### pipelineCandidateList
- Dashboard-style view with summary cards (count, high-score alerts, total value)
- Datatable of top Pipeline Candidates sorted by AI Relevancy Score
- Columns include Agency, Type, AI Score, Strategic Fit, Est. Value, Status
- Exposed to App Page, Home Page, and Record Page
- Wires to `PipelineScoutService.getTopCandidates()`

### opportunityAiBriefCard
- Displays AI Relevancy Score (with visual emphasis), Strategic Fit, Pursuit Priority, Incumbent, and NAICS Tags
- Shows AI Brief Summary
- Designed for Opportunity record pages
- Uses Lightning Data Service (`getRecord`)

### Notes
- These components are functional and styled to approximate the design mockups.
- No OmniStudio dependency.
- Add them via Lightning App Builder after deployment.
- Navigation actions are currently placeholders and can be enhanced with `NavigationMixin`.

See [mockups.md](mockups.md) for the original design references.
