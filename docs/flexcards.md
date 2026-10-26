# FlexCard Stubs

OmniStudio FlexCard metadata stubs have been added under `force-app/main/default/omniUiCards/`.

## PipelineCandidateList
- Displays top Pipeline Candidates sorted by AI Relevancy Score
- Suitable for App Pages or Home Pages
- Sample query against `Pipeline_Candidate__c`

## OpportunityAIBrief
- Displays AI Relevancy Score, Strategic Fit, Pursuit Priority, Incumbent, and AI Brief Summary on an Opportunity record
- Designed for Opportunity record pages
- Uses `{recordId}` context variable

### Notes
- These are minimal stubs. Open them in the OmniStudio FlexCard Designer in a scratch org (with OmniStudio enabled) to add visual elements, actions, and styling.
- After deploy, activate the cards and add them to Lightning pages via the App Builder or FlexCard component.
- Ensure OmniStudio is enabled in the target org.
