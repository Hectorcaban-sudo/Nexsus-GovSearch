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
            List<Pipeline_Candidate__c> toInsert = generateSampleCandidates(20);
            String msg = insertCandidates(toInsert);
            if ([SELECT COUNT() FROM Company_Profile__c] == 0) {
                Company_Profile__c p = new Company_Profile__c(
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
            IntegrationLogger.error(SOURCE, e);
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
            IntegrationLogger.error(SOURCE, e);
            throw new AuraHandledException('Failed to parse or load JSON: ' + e.getMessage());
        }
    }

    private static String loadMultiObject(Map<String, Object> data) {
        List<String> messages = new List<String>();

        if (data.containsKey('Company_Profile__c')) {
            List<Object> rows = (List<Object>) data.get('Company_Profile__c');
            if (!rows.isEmpty() && [SELECT COUNT() FROM Company_Profile__c] == 0) {
                Map<String, Object> m = (Map<String, Object>) rows[0];
                Company_Profile__c p = new Company_Profile__c();
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

        if (data.containsKey('Pipeline_Candidate__c')) {
            String r = loadCandidateList((List<Object>) data.get('Pipeline_Candidate__c'));
            messages.add(r);
        }

        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        for (String apiName : data.keySet()) {
            if (apiName == 'Company_Profile__c' || apiName == 'Pipeline_Candidate__c') continue;
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
        IntegrationLogger.info(SOURCE, msg);
        return msg;
    }

    private static String loadCandidateList(List<Object> raw) {
        List<Pipeline_Candidate__c> toInsert = new List<Pipeline_Candidate__c>();
        for (Object o : raw) {
            Map<String, Object> m = (Map<String, Object>) o;
            Pipeline_Candidate__c c = new Pipeline_Candidate__c();
            c.Name = (String) m.get('Name');
            c.External_Id__c = (String) m.get('External_Id__c');
            c.Agency__c = (String) m.get('Agency__c');
            c.Candidate_Type__c = (String) m.get('Candidate_Type__c');
            c.NAICS__c = (String) m.get('NAICS__c');
            if (m.get('Estimated_Value__c') != null) {
                c.Estimated_Value__c = Decimal.valueOf(String.valueOf(m.get('Estimated_Value__c')));
            }
            if (m.get('Due_Date__c') != null) {
                c.Due_Date__c = Date.valueOf((String) m.get('Due_Date__c'));
            }
            // Only set Source_System__c if the field exists in the org
            if (hasField('Pipeline_Candidate__c', 'Source_System__c')) {
                c.put('Source_System__c', m.get('Source_System__c') != null ? (String) m.get('Source_System__c') : 'Sample');
            }
            if (hasField('Pipeline_Candidate__c', 'Status__c') && m.get('Status__c') != null) {
                c.put('Status__c', (String) m.get('Status__c'));
            }
            if (hasField('Pipeline_Candidate__c', 'Triage_Status__c') && m.get('Triage_Status__c') != null) {
                c.put('Triage_Status__c', (String) m.get('Triage_Status__c'));
            }
            toInsert.add(c);
        }
        return insertCandidates(toInsert);
    }

    @AuraEnabled
    public static String clearSampleData() {
        assertAdminAccess();
        try {
            List<Pipeline_Candidate__c> samples;
            if (hasField('Pipeline_Candidate__c', 'Source_System__c')) {
                samples = Database.query('SELECT Id FROM Pipeline_Candidate__c WHERE Source_System__c = \'Sample\' LIMIT 200');
            } else {
                // Fallback: match by Name prefix
                samples = [SELECT Id FROM Pipeline_Candidate__c WHERE Name LIKE 'Sample%' LIMIT 200];
            }
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

    private static String insertCandidates(List<Pipeline_Candidate__c> toInsert) {
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
        IntegrationLogger.info(SOURCE, msg);
        return msg;
    }

    private static Boolean hasField(String objectName, String fieldName) {
        return Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().containsKey(fieldName);
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
            if (hasField('Pipeline_Candidate__c', 'Source_System__c')) {
                c.put('Source_System__c', 'Sample');
            }
            if (hasField('Pipeline_Candidate__c', 'Status__c')) {
                c.put('Status__c', 'New');
            }
            if (hasField('Pipeline_Candidate__c', 'Triage_Status__c')) {
                c.put('Triage_Status__c', 'New');
            }
            records.add(c);
        }
        return records;
    }
}
