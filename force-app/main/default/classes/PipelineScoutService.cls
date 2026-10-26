/**
 * Pipeline Scout service for scoring and retrieving Pipeline Candidates.
 */
public with sharing class PipelineScoutService {
    @AuraEnabled(cacheable=true)
    public static List<Pipeline_Candidate__c> getTopCandidates() {
        return [
            SELECT Id, Name, Agency__c, Candidate_Type__c, AI_Relevancy_Score__c,
                   Strategic_Fit__c, Estimated_Value__c, Status__c, Due_Date__c, NAICS__c
            FROM Pipeline_Candidate__c
            ORDER BY AI_Relevancy_Score__c DESC NULLS LAST
            LIMIT 25
        ];
    }

    @AuraEnabled
    public static void refreshScores() {
        // Placeholder for AI scoring logic that updates AI_Relevancy_Score__c
        // based on Past_Performance_Profile__c and Strategic_Objective__c
    }
}
