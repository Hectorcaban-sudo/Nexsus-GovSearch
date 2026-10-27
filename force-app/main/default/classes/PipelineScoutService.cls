/**
 * Pipeline Scout service for scoring and retrieving Pipeline Candidates.
 * Scoring uses Company Profile and Fit Rule custom metadata.
 */
public with sharing class PipelineScoutService {
    private static final String SOURCE = 'PipelineScoutService';

    @AuraEnabled(cacheable=true)
    public static List<Pipeline_Candidate__c> getTopCandidates() {
        try {
            return [
                SELECT Id, Name, Agency__c, Candidate_Type__c, AI_Relevancy_Score__c,
                       Strategic_Fit__c, Estimated_Value__c, Status__c, Due_Date__c, NAICS__c,
                       Triage_Status__c
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
            // Load Company Profile (singleton)
            Company_Profile__c profile = null;
            List<Company_Profile__c> profiles = [
                SELECT Id, Primary_NAICS__c, Set_Aside_Eligibility__c
                FROM Company_Profile__c
                LIMIT 1
            ];
            if (!profiles.isEmpty()) {
                profile = profiles[0];
            }

            // Load Fit Rules (custom metadata)
            List<Fit_Rule__mdt> rules = Fit_Rule__mdt.getAll().values();

            List<Pipeline_Candidate__c> candidates = [
                SELECT Id, Agency__c, NAICS__c, Estimated_Value__c, Candidate_Type__c,
                       AI_Relevancy_Score__c, Strategic_Fit__c
                FROM Pipeline_Candidate__c
                WHERE Id IN :candidateIds
            ];

            for (Pipeline_Candidate__c c : candidates) {
                Integer score = calculateScore(c, profile, rules);
                c.AI_Relevancy_Score__c = Math.min(score, 100);
                c.Strategic_Fit__c = score >= 80 ? 'High' : (score >= 60 ? 'Medium' : 'Low');
            }

            if (!candidates.isEmpty()) {
                Database.SaveResult[] results = Database.update(candidates, false);
                Integer errors = 0;
                for (Database.SaveResult sr : results) {
                    if (!sr.isSuccess()) errors++;
                }
                IntegrationLogger.info(SOURCE, 'Scored ' + candidates.size() + ' candidates using Company Profile + Fit Rules. Update errors: ' + errors);
            }
        } catch (Exception e) {
            IntegrationLogger.error(SOURCE, e);
        }
    }

    private static Integer calculateScore(Pipeline_Candidate__c c, Company_Profile__c profile, List<Fit_Rule__mdt> rules) {
        Integer score = 50;

        // Base rules (fallback if no metadata)
        if (c.Estimated_Value__c != null && c.Estimated_Value__c > 10000000) score += 20;
        if (c.Candidate_Type__c == 'Recompete') score += 15;
        if (c.NAICS__c != null && c.NAICS__c.startsWith('5415')) score += 10;

        // Company Profile matching
        if (profile != null && profile.Primary_NAICS__c != null && c.NAICS__c != null) {
            if (profile.Primary_NAICS__c.contains(c.NAICS__c)) {
                score += 15;
            }
        }

        // Apply Fit Rule custom metadata (simple additive model)
        if (rules != null) {
            for (Fit_Rule__mdt rule : rules) {
                // Placeholder: in a full implementation, evaluate rule criteria here
                // Example: if rule matches NAICS or set-aside, add weight
                if (rule.Weight__c != null) {
                    score += Integer.valueOf(rule.Weight__c);
                }
            }
        }

        return Math.min(score, 100);
    }
}
