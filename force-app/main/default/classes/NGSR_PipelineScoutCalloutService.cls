/**
 * Callout service that pulls external opportunities and upserts Pipeline Candidates.
 * Includes error handling and logging.
 */
public with sharing class NGSR_PipelineScoutCalloutService {

    private static final String SOURCE = 'NGSR_PipelineScoutCalloutService';
    private static final String ENDPOINT = 'callout:SamGov/opportunities';

    @future(callout=true)
    public static void syncAndScore() {
        NGSR_IntegrationLogger.info(SOURCE, 'Starting SAM.gov sync');
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(ENDPOINT);
            req.setMethod('GET');
            req.setTimeout(120000);

            HttpResponse res = new Http().send(req);
            Integer status = res.getStatusCode();

            if (status != 200) {
                NGSR_IntegrationLogger.error(SOURCE, 'Callout failed with status ' + status + ': ' + res.getBody());
                return;
            }

            String body = res.getBody();
            if (String.isBlank(body)) {
                NGSR_IntegrationLogger.warn(SOURCE, 'Empty response body from external source');
                return;
            }

            List<Object> items;
            try {
                items = (List<Object>) JSON.deserializeUntyped(body);
            } catch (Exception jsonEx) {
                NGSR_IntegrationLogger.error(SOURCE, 'Failed to parse JSON: ' + jsonEx.getMessage());
                return;
            }

            if (items == null || items.isEmpty()) {
                NGSR_IntegrationLogger.info(SOURCE, 'No opportunities returned');
                return;
            }

            List<NGSR_Pipeline_Candidate__c> toUpsert = new List<NGSR_Pipeline_Candidate__c>();
            for (Object item : items) {
                try {
                    Map<String, Object> data = (Map<String, Object>) item;
                    NGSR_Pipeline_Candidate__c pc = mapToCandidate(data);
                    if (pc != null) {
                        toUpsert.add(pc);
                    }
                } catch (Exception mapEx) {
                    NGSR_IntegrationLogger.warn(SOURCE, 'Skipped record due to mapping error: ' + mapEx.getMessage());
                }
            }

            if (toUpsert.isEmpty()) {
                NGSR_IntegrationLogger.info(SOURCE, 'No valid candidates to upsert');
                return;
            }

            Database.UpsertResult[] results = Database.upsert(
                toUpsert,
                NGSR_Pipeline_Candidate__c.External_Id__c,
                false
            );

            Set<Id> successfulIds = new Set<Id>();
            Integer errorCount = 0;
            for (Integer i = 0; i < results.size(); i++) {
                if (results[i].isSuccess()) {
                    successfulIds.add(toUpsert[i].Id);
                } else {
                    errorCount++;
                    String errMsg = '';
                    for (Database.Error err : results[i].getErrors()) {
                        errMsg += err.getStatusCode() + ': ' + err.getMessage() + '; ';
                    }
                    NGSR_IntegrationLogger.error(SOURCE, 'Upsert failed for ' + toUpsert[i].External_Id__c + ': ' + errMsg);
                }
            }

            NGSR_IntegrationLogger.info(SOURCE, 'Upsert complete. Success: ' + successfulIds.size() + ', Errors: ' + errorCount);

            if (!successfulIds.isEmpty()) {
                NGSR_PipelineScoutService.refreshScoresFor(successfulIds);
            }

        } catch (Exception e) {
            NGSR_IntegrationLogger.error(SOURCE, e);
        }
    }

    private static NGSR_Pipeline_Candidate__c mapToCandidate(Map<String, Object> data) {
        String externalId = (String) data.get('noticeId');
        if (String.isBlank(externalId)) return null;

        NGSR_Pipeline_Candidate__c pc = new NGSR_Pipeline_Candidate__c();
        pc.External_Id__c = externalId;
        pc.Name = truncate((String) data.get('title'), 80);
        pc.Agency__c = truncate((String) data.get('department'), 255);
        pc.Candidate_Type__c = mapType((String) data.get('type'));
        pc.Estimated_Value__c = toDecimal(data.get('estimatedValue'));
        pc.NAICS__c = truncate((String) data.get('naicsCode'), 10);
        pc.Due_Date__c = toDate(data.get('responseDeadline'));
        pc.Source_System__c = 'SAM.gov';
        pc.Status__c = 'New';
        return pc;
    }

    private static String mapType(String externalType) {
        if (String.isBlank(externalType)) return 'Solicitation';
        String t = externalType.toLowerCase();
        if (t.contains('recompete') || t.contains('follow-on')) return 'Recompete';
        if (t.contains('task') || t.contains('order')) return 'Task Order';
        return 'Solicitation';
    }

    private static Decimal toDecimal(Object val) {
        if (val == null) return null;
        try {
            return Decimal.valueOf(String.valueOf(val));
        } catch (Exception e) {
            return null;
        }
    }

    private static Date toDate(Object val) {
        if (val == null) return null;
        try {
            return Date.valueOf(String.valueOf(val));
        } catch (Exception e) {
            return null;
        }
    }

    private static String truncate(String value, Integer maxLen) {
        if (value == null) return null;
        return value.length() > maxLen ? value.substring(0, maxLen) : value;
    }
}
