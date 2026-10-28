/**
 * Controller for the Nexsus GovSearch Admin Configuration page.
 * Secured by the NGSR_Admin permission set / NGSR_Admin_Access custom permission.
 */
public with sharing class NGSR_AdminConfigController {
    private static final String SOURCE = 'NGSR_AdminConfigController';

    // Custom objects to clear (Opportunity is intentionally excluded)
    private static final List<String> CLEAR_OBJECTS = new List<String>{
        'NGSR_NGSR_Pipeline_Candidate__c',
        'NGSR_Company_Profile__c',
        'NGSR_Agency_Hierarchy__c',
        'NGSR_NGSR_Government_Contact__c',
        'NGSR_NGSR_Solicitation__c',
        'NGSR_NGSR_Award__c',
        'NGSR_Contract_Vehicle__c',
        'NGSR_Capture_Plan__c',
        'NGSR_Gate_Review__c',
        'NGSR_Bid_Decision_Scorecard__c',
        'NGSR_Call_Report__c',
        'NGSR_Teaming_Partner__c',
        'NGSR_Forecast__c',
        'NGSR_Saved_Search__c',
        'NGSR_Notice_Version__c',
        'NGSR_Strategic_Objective__c',
        'NGSR_Integration_Log__c'
    };

    @AuraEnabled
    public static Map<String, Object> getAdminStatus() {
        assertAdminAccess();
        Map<String, Object> status = new Map<String, Object>();
        status.put('candidateCount', safeCount('NGSR_NGSR_Pipeline_Candidate__c'));
        status.put('companyProfileCount', safeCount('NGSR_Company_Profile__c'));
        status.put('hasCompanyProfile', safeCount('NGSR_Company_Profile__c') > 0);
        return status;
    }

    private static Integer safeCount(String objectName) {
        try {
            return Database.countQuery('SELECT COUNT() FROM ' + objectName);
        } catch (Exception e) {
            return 0;
        }
    }

    @AuraEnabled
    public static String loadSampleDatasets() {
        assertAdminAccess();
        try {
            List<NGSR_NGSR_Pipeline_Candidate__c> toInsert = generateSampleCandidates(20);
            String msg = insertCandidates(toInsert);
            if (safeCount('NGSR_Company_Profile__c') == 0) {
                NGSR_Company_Profile__c p = new NGSR_Company_Profile__c(
                    Name = 'Nexsus Sample Company',
                    Primary_NAICS__c = '541511;541512',
                    Secondary_NAICS__c = '541519;541330',
                    PSC_Codes__c = 'D399;R425',
                    Set_Aside_Eligibility__c = 'Small Business',
                    Vehicles_Held__c = 'GSA MAS;CIO-SP3',
                    Target_Agencies__c = 'Department of Defense;Department of Veterans Affairs'
                );
                insert p;
                msg += ' Created Company Profile.';
            }
            return msg;
        } catch (Exception e) {
            NGSR_IntegrationLogger.error(SOURCE, e);
            throw new AuraHandledException('Failed to load sample data: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static String uploadSampleDatasets(String jsonContent) {
        assertAdminAccess();
        if (String.isBlank(jsonContent)) {
            throw new AuraHandledException('JSON content is empty.');
        }
        try {
            Object parsed = JSON.deserializeUntyped(jsonContent);
            if (parsed instanceof List<Object>) {
                return loadCandidateList((List<Object>) parsed);
            } else if (parsed instanceof Map<String, Object>) {
                return loadMultiObject((Map<String, Object>) parsed);
            }
            throw new AuraHandledException('JSON must be an object keyed by API name or an array of candidates.');
        } catch (Exception e) {
            NGSR_IntegrationLogger.error(SOURCE, e);
            throw new AuraHandledException('Failed to parse or load JSON: ' + e.getMessage());
        }
    }

    private static String loadMultiObject(Map<String, Object> data) {
        List<String> messages = new List<String>();

        if (data.containsKey('NGSR_Company_Profile__c')) {
            List<Object> rows = (List<Object>) data.get('NGSR_Company_Profile__c');
            if (!rows.isEmpty() && safeCount('NGSR_Company_Profile__c') == 0) {
                Map<String, Object> m = (Map<String, Object>) rows[0];
                NGSR_Company_Profile__c p = new NGSR_Company_Profile__c();
                p.Name = (String) m.get('Name');
                p.Primary_NAICS__c = (String) m.get('Primary_NAICS__c');
                p.Secondary_NAICS__c = (String) m.get('Secondary_NAICS__c');
                p.PSC_Codes__c = (String) m.get('PSC_Codes__c');
                p.Set_Aside_Eligibility__c = (String) m.get('Set_Aside_Eligibility__c');
                p.Vehicles_Held__c = (String) m.get('Vehicles_Held__c');
                p.Target_Agencies__c = (String) m.get('Target_Agencies__c');
                insert p;
                messages.add('Company Profile');
            }
        }

        if (data.containsKey('NGSR_NGSR_Pipeline_Candidate__c')) {
            String r = loadCandidateList((List<Object>) data.get('NGSR_NGSR_Pipeline_Candidate__c'));
            messages.add(r);
        }

        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        for (String apiName : data.keySet()) {
            if (apiName == 'NGSR_Company_Profile__c' || apiName == 'NGSR_NGSR_Pipeline_Candidate__c') continue;
            if (!gd.containsKey(apiName)) continue;
            List<Object> rows = (List<Object>) data.get(apiName);
            List<SObject> toInsert = new List<SObject>();
            for (Object o : rows) {
                Map<String, Object> m = (Map<String, Object>) o;
                SObject sobj = gd.get(apiName).newSObject();
                if (m.containsKey('Name')) sobj.put('Name', (String) m.get('Name'));
                for (String key : m.keySet()) {
                    if (key == 'Name') continue;
                    try { sobj.put(key, m.get(key)); } catch (Exception e) { /* skip invalid */ }
                }
                toInsert.add(sobj);
            }
            if (!toInsert.isEmpty()) {
                Database.SaveResult[] results = Database.insert(toInsert, false);
                Integer ok = 0;
                for (Database.SaveResult sr : results) if (sr.isSuccess()) ok++;
                messages.add(apiName + ': ' + ok);
            }
        }

        String msg = 'Loaded multi-object sample data. ' + String.join(messages, '; ');
        NGSR_IntegrationLogger.info(SOURCE, msg);
        return msg;
    }

    private static String loadCandidateList(List<Object> raw) {
        List<NGSR_NGSR_Pipeline_Candidate__c> toInsert = new List<NGSR_NGSR_Pipeline_Candidate__c>();
        for (Object o : raw) {
            Map<String, Object> m = (Map<String, Object>) o;
            NGSR_NGSR_Pipeline_Candidate__c c = new NGSR_NGSR_Pipeline_Candidate__c();
            c.Name = (String) m.get('Name');
            if (m.get('External_Id__c') != null) c.External_Id__c = (String) m.get('External_Id__c');
            if (m.get('Agency__c') != null) c.Agency__c = (String) m.get('Agency__c');
            if (m.get('Candidate_Type__c') != null) c.Candidate_Type__c = (String) m.get('Candidate_Type__c');
            if (m.get('NAICS__c') != null) c.NAICS__c = (String) m.get('NAICS__c');
            if (m.get('Estimated_Value__c') != null) {
                c.Estimated_Value__c = Decimal.valueOf(String.valueOf(m.get('Estimated_Value__c')));
            }
            if (m.get('Due_Date__c') != null) {
                c.Due_Date__c = Date.valueOf((String) m.get('Due_Date__c'));
            }
            toInsert.add(c);
        }
        return insertCandidates(toInsert);
    }

    @AuraEnabled
    public static String clearSampleData() {
        assertAdminAccess();
        List<String> messages = new List<String>();
        Integer totalDeleted = 0;

        for (String objName : CLEAR_OBJECTS) {
            try {
                // Delete all records of this object (no field filters)
                List<SObject> records = Database.query('SELECT Id FROM ' + objName + ' LIMIT 200');
                if (!records.isEmpty()) {
                    delete records;
                    totalDeleted += records.size();
                    messages.add(objName + ': ' + records.size());
                }
            } catch (Exception e) {
                // Object may not exist or user may lack access — skip
                messages.add(objName + ': skipped');
            }
        }

        String msg = 'Cleared ' + totalDeleted + ' records from custom objects (Opportunity excluded). ' + String.join(messages, '; ');
        NGSR_IntegrationLogger.info(SOURCE, msg);
        return msg;
    }

    @AuraEnabled
    public static String refreshAllScores() {
        assertAdminAccess();
        NGSR_PipelineScoutService.refreshScores();
        return 'Scoring refresh initiated for recent candidates.';
    }

    private static String insertCandidates(List<NGSR_NGSR_Pipeline_Candidate__c> toInsert) {
        Database.SaveResult[] results = Database.insert(toInsert, false);
        Integer success = 0;
        Integer errors = 0;
        String firstError = '';
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) success++;
            else {
                errors++;
                if (String.isBlank(firstError) && sr.getErrors().size() > 0) {
                    firstError = sr.getErrors()[0].getMessage();
                }
            }
        }
        String msg = 'Loaded ' + success + ' Pipeline Candidates. Errors: ' + errors;
        if (String.isNotBlank(firstError)) msg += ' (First: ' + firstError + ')';
        NGSR_IntegrationLogger.info(SOURCE, msg);
        return msg;
    }

    private static void assertAdminAccess() {
        if (!FeatureManagement.checkPermission('NGSR_Admin_Access')) {
            throw new AuraHandledException('You do not have Nexsus Admin Access. Contact your administrator.');
        }
    }

    private static List<NGSR_NGSR_Pipeline_Candidate__c> generateSampleCandidates(Integer count) {
        List<String> agencies = new List<String>{'Department of Defense', 'Department of Veterans Affairs', 'Department of Homeland Security', 'General Services Administration', 'Department of Health and Human Services', 'Department of Energy', 'NASA', 'Department of Justice'};
        List<String> types = new List<String>{'Recompete', 'Solicitation', 'Task Order'};
        List<String> naics = new List<String>{'541511', '541512', '541519', '541330', '541611', '541618'};
        List<NGSR_NGSR_Pipeline_Candidate__c> records = new List<NGSR_NGSR_Pipeline_Candidate__c>();
        for (Integer i = 1; i <= count; i++) {
            NGSR_NGSR_Pipeline_Candidate__c c = new NGSR_NGSR_Pipeline_Candidate__c();
            c.Name = 'Sample Opportunity ' + String.valueOf(i).leftPad(3, '0');
            c.External_Id__c = 'SAMPLE-' + String.valueOf(i).leftPad(4, '0');
            c.Agency__c = agencies[Math.mod(i, agencies.size())];
            c.Candidate_Type__c = types[Math.mod(i, types.size())];
            c.NAICS__c = naics[Math.mod(i, naics.size())];
            c.Estimated_Value__c = 500000 + (i * 250000);
            c.Due_Date__c = Date.today().addDays(30 + Math.mod(i, 120));
            records.add(c);
        }
        return records;
    }
}
