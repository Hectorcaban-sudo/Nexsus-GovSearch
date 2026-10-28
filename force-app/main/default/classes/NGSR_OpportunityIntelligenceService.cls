/**
 * Opportunity Intelligence service for AI brief generation.
 * References Opportunity only — does not modify Opportunity fields.
 * Stubs for Agentforce actions.
 */
public with sharing class NGSR_OpportunityIntelligenceService {
    private static final String SOURCE = 'NGSR_OpportunityIntelligenceService';

    @AuraEnabled
    public static String generateBrief(Id opportunityId) {
        try {
            // Reference only standard Opportunity fields
            Opportunity opp = [
                SELECT Id, Name, StageName, Amount, CloseDate, Probability
                FROM Opportunity
                WHERE Id = :opportunityId
                LIMIT 1
            ];

            String brief = 'Opportunity: ' + opp.Name + '. ' +
                'Stage: ' + opp.StageName + '. ' +
                'Amount: ' + (opp.Amount != null ? String.valueOf(opp.Amount) : 'N/A') + '. ' +
                'Close: ' + (opp.CloseDate != null ? String.valueOf(opp.CloseDate) : 'N/A') + '. ' +
                'Recommend teaming and early stakeholder engagement.';

            // Do not update Opportunity — return the brief only
            NGSR_IntegrationLogger.info(SOURCE, 'Generated brief for Opportunity ' + opportunityId);
            return brief;
        } catch (Exception e) {
            NGSR_IntegrationLogger.error(SOURCE, e);
            throw new AuraHandledException('Unable to generate brief: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, String> getStructuredBrief(Id opportunityId) {
        Map<String, String> result = new Map<String, String>();
        result.put('incumbentStrengths', 'Incumbent holds strong position with deep agency knowledge.');
        result.put('competitiveWhitespace', 'Whitespace in cloud-native, zero-trust, and AI/ML capabilities.');
        result.put('pursuitPrioritization', 'High strategic fit. Recommend early positioning.');
        return result;
    }
}
