/**
 * Service class supporting Opportunity Intelligence agent actions.
 * Generates or refreshes AI brief summaries.
 */
public with sharing class OpportunityIntelligenceService {
    @AuraEnabled
    public static String generateBrief(Id opportunityId) {
        // TODO: Call Prompt Template or Agentforce action
        Opportunity opp = [SELECT Id, Name, AI_Brief_Summary__c FROM Opportunity WHERE Id = :opportunityId LIMIT 1];
        opp.AI_Brief_Summary__c = 'AI-generated brief placeholder for ' + opp.Name + '. Incumbent analysis, competitive whitespace, and prioritization to be populated by Agentforce.';
        update opp;
        return opp.AI_Brief_Summary__c;
    }
}
