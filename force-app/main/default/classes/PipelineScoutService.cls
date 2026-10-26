/**
 * Pipeline Scout service for scoring and retrieving Pipeline Candidates.
 * Includes error handling and logging.
 */
public with sharing class PipelineScoutService {
    private static final String SOURCE = 'PipelineScoutService';

    @AuraEnabled(cacheable=true)
    public static List<Pipeline_Candidate__c> getTopCandidates() {
        try {
            return [
                SELECT Id, Name, Agency__c, Candidate_Type__c, AI_Relevancy_Score__c,
                       Strategic_Fit__c, Estimated_Value__c, Status__c, Due_Date__c, NAICS__c
                FROM Pipeline_Candidate__c
                ORDER BY AI_Relevancy_Score__c DESC NULLS LAST
                LIMIT 25
            ];
        } catch (Exception e) {
            IntegrationLogger.error(SOURCE, e);
            return new List<Pipeline_Candidate__c>();
        }
    }

    @AuraEnabled
    public static void refreshScores() {
        try {
            Set<Id> ids = new Map<Id, Pipeline_Candidate__c>([
                SELECT Id FROM Pipeline_Candidate__c
                WHERE CreatedDate = LAST_N_DAYS:7
            ]).keySet();
            refreshScoresFor(ids);
        } catch (Exception e) {
            IntegrationLogger.error(SOURCE, e);
            throw new AuraHandledException('Unable to refresh scores: ' + e.getMessage());
        }
    }

    public static void refreshScoresFor(Set<Id> candidateIds) {
        if (candidateIds == null || candidateIds.isEmpty()) return;

        try {
            List<Pipeline_Candidate__c> candidates = [
                SELECT Id, Agency__c, NAICS__c, Estimated_Value__c, Candidate_Type__c,
                       AI_Relevancy_Score__c, Strategic_Fit__c
                FROM Pipeline_Candidate__c
                WHERE Id IN :candidateIds
            ];

            for (Pipeline_Candidate__c c : candidates) {
                Integer score = 50;
                if (c.Estimated_Value__c != null && c.Estimated_Value__c > 10000000) score += 20;
                if (c.Candidate_Type__c == 'Recompete') score += 15;
                if (c.NAICS__c != null && c.NAICS__c.startsWith('5415')) score += 10;
                c.AI_Relevancy_Score__c = Math.min(score, 100);
                c.Strategic_Fit__c = score >= 80 ? 'High' : (score >= 60 ? 'Medium' : 'Low');
            }

            if (!candidates.isEmpty()) {
                Database.SaveResult[] results = Database.update(candidates, false);
                Integer errors = 0;
                for (Database.SaveResult sr : results) {
                    if (!sr.isSuccess()) errors++;
                }
                IntegrationLogger.info(SOURCE, 'Scored ' + candidates.size() + ' candidates. Update errors: ' + errors);
            }
        } catch (Exception e) {
            IntegrationLogger.error(SOURCE, e);
        }
    }
}
