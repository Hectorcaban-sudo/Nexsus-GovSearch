/**
 * Controller for the Nexsus GovSearch Admin Configuration page.
 * Secured by the Nexsus_Admin permission set / Nexsus_Admin_Access custom permission.
 */
public with sharing class AdminConfigController {
    private static final String SOURCE = 'AdminConfigController';

    @AuraEnabled
    public static Map<String, Object> getAdminStatus() {
        assertAdminAccess();
        Map<String, Object> status = new Map<String, Object>();
        status.put('candidateCount', [SELECT COUNT() FROM Pipeline_Candidate__c]);
        status.put('companyProfileCount', [SELECT COUNT() FROM Company_Profile__c]);
        status.put('hasCompanyProfile', [SELECT COUNT() FROM Company_Profile__c] > 0);
        return status;
    }

    @AuraEnabled
    public static String loadSampleDatasets() {
        assertAdminAccess();
        try {
            // Sample data is loaded from the Static Resource or inline JSON
            // For this implementation we generate 100 representative records
            List<Pipeline_Candidate__c> toInsert = generateSampleCandidates(100);
            Database.SaveResult[] results = Database.insert(toInsert, false);
            Integer success = 0;
            Integer errors = 0;
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) success++;
                else errors++;
            }
            String msg = 'Loaded ' + success + ' sample Pipeline Candidates. Errors: ' + errors;
            IntegrationLogger.info(SOURCE, msg);
            return msg;
        } catch (Exception e) {
            IntegrationLogger.error(SOURCE, e);
            throw new AuraHandledException('Failed to load sample data: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static String clearSampleData() {
        assertAdminAccess();
        try {
            List<Pipeline_Candidate__c> samples = [
                SELECT Id FROM Pipeline_Candidate__c
                WHERE Source_System__c = 'Sample'
                LIMIT 200
            ];
            delete samples;
            String msg = 'Cleared ' + samples.size() + ' sample Pipeline Candidates.';
            IntegrationLogger.info(SOURCE, msg);
            return msg;
        } catch (Exception e) {
            IntegrationLogger.error(SOURCE, e);
            throw new AuraHandledException('Failed to clear sample data: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static String refreshAllScores() {
        assertAdminAccess();
        PipelineScoutService.refreshScores();
        return 'Scoring refresh initiated for recent candidates.';
    }

    private static void assertAdminAccess() {
        if (!FeatureManagement.checkPermission('Nexsus_Admin_Access')) {
            throw new AuraHandledException('You do not have Nexsus Admin Access. Contact your administrator.');
        }
    }

    private static List<Pipeline_Candidate__c> generateSampleCandidates(Integer count) {
        List<String> agencies = new List<String>{'Department of Defense', 'Department of Veterans Affairs', 'Department of Homeland Security', 'General Services Administration', 'Department of Health and Human Services', 'Department of Energy', 'NASA', 'Department of Justice'};
        List<String> types = new List<String>{'Recompete', 'Solicitation', 'Task Order'};
        List<String> naics = new List<String>{'541511', '541512', '541519', '541330', '541611', '541618'};
        List<Pipeline_Candidate__c> records = new List<Pipeline_Candidate__c>();
        for (Integer i = 1; i <= count; i++) {
            Pipeline_Candidate__c c = new Pipeline_Candidate__c();
            c.Name = 'Sample Opportunity ' + String.valueOf(i).leftPad(3, '0');
            c.External_Id__c = 'SAMPLE-' + String.valueOf(i).leftPad(4, '0');
            c.Agency__c = agencies[Math.mod(i, agencies.size())];
            c.Candidate_Type__c = types[Math.mod(i, types.size())];
            c.NAICS__c = naics[Math.mod(i, naics.size())];
            c.Estimated_Value__c = 500000 + (i * 250000);
            c.Due_Date__c = Date.today().addDays(30 + Math.mod(i, 120));
            c.Source_System__c = 'Sample';
            c.Status__c = 'New';
            c.Triage_Status__c = 'New';
            records.add(c);
        }
        return records;
    }
}
