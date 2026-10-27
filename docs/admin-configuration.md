# Admin Configuration

The Nexsus GovSearch Admin Configuration page provides administrative actions for solution setup and testing.

## Security

- Custom Permission: `Nexsus_Admin_Access`
- Permission Set: `Nexsus_Admin`
- Assign the permission set only to solution administrators.
- Apex methods check `FeatureManagement.checkPermission('Nexsus_Admin_Access')` before executing.

## Admin Actions

| Action | Description |
|--------|-------------|
| Load 100 Sample Datasets | Creates 100 Pipeline Candidate records with Source_System__c = Sample for testing scoring, triage, and dashboards without external ingestion. |
| Clear Sample Data | Deletes Pipeline Candidates where Source_System__c = Sample. |
| Refresh Scores | Runs PipelineScoutService.refreshScores() against recent candidates. |

## Sample Data

- JSON file: `docs/sample-datasets.json` (100 records)
- Apex generates equivalent records at runtime so no Static Resource is required for the initial implementation.
- All sample records use External_Id__c starting with SAMPLE- and Source_System__c = Sample.

## Setup

1. Deploy the project.
2. Assign the **Nexsus Admin** permission set to administrators.
3. Add the Admin Configuration tab to the Nexsus GovSearch app or create a Lightning page containing the `adminConfig` LWC.
4. Open the page and use **Load 100 Sample Datasets**.
5. Verify scoring and triage in the Pipeline dashboard.
6. Use **Clear Sample Data** when finished.

## Notes

- Sample data is for verification only and does not replace real SAM.gov or Data Cloud ingestion.
- All admin actions are logged to Integration_Log__c.
