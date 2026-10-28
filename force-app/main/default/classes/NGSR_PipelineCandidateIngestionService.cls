/**
 * Ingestion API for Pipeline Candidates.
 * External systems (MuleSoft, middleware, Data Cloud, custom apps) can POST records
 * that are upserted and scored.
 *
 * Endpoint: /services/apexrest/nexsus/pipeline-candidates
 */
@RestResource(urlMapping='/nexsus/pipeline-candidates/*')
global with sharing class NGSR_PipelineCandidateIngestionService {

    private static final String SOURCE = 'NGSR_PipelineCandidateIngestionService';

    global class IngestionRequest {
        public List<CandidatePayload> candidates;
    }

    global class CandidatePayload {
        public String externalId;
        public String name;
        public String agency;
        public String candidateType;
        public Decimal estimatedValue;
        public String naics;
        public Date dueDate;
        public String sourceSystem;
        public String incumbent;
        public String status;
    }

    global class IngestionResponse {
        public Boolean success;
        public Integer totalReceived;
        public Integer successCount;
        public Integer errorCount;
        public List<String> errors;
        public List<String> processedExternalIds;
    }

    @HttpPost
    global static IngestionResponse ingest() {
        IngestionResponse response = new IngestionResponse();
        response.success = false;
        response.errors = new List<String>();
        response.processedExternalIds = new List<String>();
        response.totalReceived = 0;
        response.successCount = 0;
        response.errorCount = 0;

        try {
            String body = RestContext.request.requestBody.toString();
            if (String.isBlank(body)) {
                response.errors.add('Request body is empty');
                NGSR_IntegrationLogger.error(SOURCE, 'Empty request body');
                RestContext.response.statusCode = 400;
                return response;
            }

            IngestionRequest req;
            try {
                req = (IngestionRequest) JSON.deserialize(body, IngestionRequest.class);
            } catch (Exception jsonEx) {
                response.errors.add('Invalid JSON: ' + jsonEx.getMessage());
                NGSR_IntegrationLogger.error(SOURCE, 'JSON parse error: ' + jsonEx.getMessage());
                RestContext.response.statusCode = 400;
                return response;
            }

            if (req == null || req.candidates == null || req.candidates.isEmpty()) {
                response.errors.add('No candidates provided');
                NGSR_IntegrationLogger.warn(SOURCE, 'No candidates in payload');
                RestContext.response.statusCode = 400;
                return response;
            }

            response.totalReceived = req.candidates.size();
            NGSR_IntegrationLogger.info(SOURCE, 'Received ' + response.totalReceived + ' candidates for ingestion');

            List<NGSR_NGSR_Pipeline_Candidate__c> toUpsert = new List<NGSR_NGSR_Pipeline_Candidate__c>();
            Map<String, String> externalIdToError = new Map<String, String>();

            for (CandidatePayload payload : req.candidates) {
                if (String.isBlank(payload.externalId)) {
                    response.errorCount++;
                    response.errors.add('Missing externalId for candidate: ' + payload.name);
                    continue;
                }

                try {
                    NGSR_NGSR_Pipeline_Candidate__c pc = mapPayload(payload);
                    toUpsert.add(pc);
                } catch (Exception mapEx) {
                    response.errorCount++;
                    String err = 'Mapping error for ' + payload.externalId + ': ' + mapEx.getMessage();
                    response.errors.add(err);
                    externalIdToError.put(payload.externalId, err);
                }
            }

            if (toUpsert.isEmpty()) {
                NGSR_IntegrationLogger.warn(SOURCE, 'No valid records to upsert');
                RestContext.response.statusCode = 400;
                return response;
            }

            Database.UpsertResult[] results = Database.upsert(
                toUpsert,
                NGSR_NGSR_Pipeline_Candidate__c.External_Id__c,
                false
            );

            Set<Id> successfulIds = new Set<Id>();
            for (Integer i = 0; i < results.size(); i++) {
                String extId = toUpsert[i].External_Id__c;
                if (results[i].isSuccess()) {
                    response.successCount++;
                    response.processedExternalIds.add(extId);
                    successfulIds.add(toUpsert[i].Id);
                } else {
                    response.errorCount++;
                    String errMsg = '';
                    for (Database.Error err : results[i].getErrors()) {
                        errMsg += err.getStatusCode() + ': ' + err.getMessage() + '; ';
                    }
                    String fullErr = 'Upsert failed for ' + extId + ': ' + errMsg;
                    response.errors.add(fullErr);
                    NGSR_IntegrationLogger.error(SOURCE, fullErr);
                }
            }

            if (!successfulIds.isEmpty()) {
                try {
                    NGSR_PipelineScoutService.refreshScoresFor(successfulIds);
                } catch (Exception scoreEx) {
                    NGSR_IntegrationLogger.error(SOURCE, 'Scoring failed after ingestion: ' + scoreEx.getMessage());
                    response.errors.add('Records ingested but scoring failed: ' + scoreEx.getMessage());
                }
            }

            response.success = response.errorCount == 0;
            RestContext.response.statusCode = response.errorCount == 0 ? 200 : 207; // 207 Multi-Status for partial success

            NGSR_IntegrationLogger.info(SOURCE, 'Ingestion complete. Success: ' + response.successCount + ', Errors: ' + response.errorCount);

        } catch (Exception e) {
            NGSR_IntegrationLogger.error(SOURCE, e);
            response.errors.add('Unexpected error: ' + e.getMessage());
            RestContext.response.statusCode = 500;
        }

        return response;
    }

    private static NGSR_NGSR_Pipeline_Candidate__c mapPayload(CandidatePayload p) {
        NGSR_NGSR_Pipeline_Candidate__c pc = new NGSR_NGSR_Pipeline_Candidate__c();
        pc.External_Id__c = p.externalId;
        pc.Name = truncate(p.name, 80);
        pc.Agency__c = truncate(p.agency, 255);
        pc.Candidate_Type__c = String.isBlank(p.candidateType) ? 'Solicitation' : p.candidateType;
        pc.Estimated_Value__c = p.estimatedValue;
        pc.NAICS__c = truncate(p.naics, 10);
        pc.Due_Date__c = p.dueDate;
        pc.Source_System__c = String.isBlank(p.sourceSystem) ? 'Ingestion API' : p.sourceSystem;
        pc.Incumbent__c = truncate(p.incumbent, 255);
        pc.Status__c = String.isBlank(p.status) ? 'New' : p.status;
        return pc;
    }

    private static String truncate(String value, Integer maxLen) {
        if (value == null) return null;
        return value.length() > maxLen ? value.substring(0, maxLen) : value;
    }
}
