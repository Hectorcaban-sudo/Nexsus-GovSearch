/**
 * Pipeline Scout service for scoring and retrieving Pipeline Candidates.
 * Scoring evaluates Fit Rule criteria against the Company Profile and stores match reasons.
 */
public with sharing class NGSR_PipelineScoutService {
    private static final String SOURCE = 'NGSR_PipelineScoutService';

    @AuraEnabled(cacheable=true)
    public static List<NGSR_NGSR_Pipeline_Candidate__c> getTopCandidates() {
        try {
            return [
                SELECT Id, Name, Agency__c, Candidate_Type__c, AI_Relevancy_Score__c,
                       Strategic_Fit__c, Estimated_Value__c, Status__c, Due_Date__c, NAICS__c,
                       Triage_Status__c, Score_Reasons__c
                FROM NGSR_NGSR_Pipeline_Candidate__c
                ORDER BY AI_Relevancy_Score__c DESC NULLS LAST
                LIMIT 25
            ];
        } catch (Exception e) {
            NGSR_IntegrationLogger.error(SOURCE, e);
            return new List<NGSR_NGSR_Pipeline_Candidate__c>();
        }
    }

    @AuraEnabled
    public static void refreshScores() {
        try {
            Set<Id> ids = new Map<Id, NGSR_NGSR_Pipeline_Candidate__c>([
                SELECT Id FROM NGSR_NGSR_Pipeline_Candidate__c
                WHERE CreatedDate = LAST_N_DAYS:7
            ]).keySet();
            refreshScoresFor(ids);
        } catch (Exception e) {
            NGSR_IntegrationLogger.error(SOURCE, e);
            throw new AuraHandledException('Unable to refresh scores: ' + e.getMessage());
        }
    }

    public static void refreshScoresFor(Set<Id> candidateIds) {
        if (candidateIds == null || candidateIds.isEmpty()) return;

        try {
            NGSR_Company_Profile__c profile = null;
            List<NGSR_Company_Profile__c> profiles = [
                SELECT Id, Primary_NAICS__c, Secondary_NAICS__c, Set_Aside_Eligibility__c,
                       PSC_Codes__c, Vehicles_Held__c, Target_Agencies__c
                FROM NGSR_Company_Profile__c
                LIMIT 1
            ];
            if (!profiles.isEmpty()) profile = profiles[0];

            List<Fit_Rule__mdt> rules = Fit_Rule__mdt.getAll().values();

            List<NGSR_NGSR_Pipeline_Candidate__c> candidates = [
                SELECT Id, Agency__c, NAICS__c, Estimated_Value__c, Candidate_Type__c,
                       AI_Relevancy_Score__c, Strategic_Fit__c, Score_Reasons__c
                FROM NGSR_NGSR_Pipeline_Candidate__c
                WHERE Id IN :candidateIds
            ];

            for (NGSR_NGSR_Pipeline_Candidate__c c : candidates) {
                ScoreResult result = calculateScore(c, profile, rules);
                c.AI_Relevancy_Score__c = Math.min(result.score, 100);
                c.Strategic_Fit__c = result.score >= 80 ? 'High' : (result.score >= 60 ? 'Medium' : 'Low');
                c.Score_Reasons__c = String.join(result.reasons, '\n');
            }

            if (!candidates.isEmpty()) {
                Database.SaveResult[] results = Database.update(candidates, false);
                Integer errors = 0;
                for (Database.SaveResult sr : results) {
                    if (!sr.isSuccess()) errors++;
                }
                NGSR_IntegrationLogger.info(SOURCE, 'Scored ' + candidates.size() + ' candidates with criteria matching. Update errors: ' + errors);
            }
        } catch (Exception e) {
            NGSR_IntegrationLogger.error(SOURCE, e);
        }
    }

    private class ScoreResult {
        Integer score = 0;
        List<String> reasons = new List<String>();
    }

    private static ScoreResult calculateScore(NGSR_NGSR_Pipeline_Candidate__c c, NGSR_Company_Profile__c profile, List<Fit_Rule__mdt> rules) {
        ScoreResult result = new ScoreResult();

        // Company Profile direct matches
        if (profile != null) {
            if (profile.Primary_NAICS__c != null && c.NAICS__c != null && profile.Primary_NAICS__c.contains(c.NAICS__c)) {
                result.score += 20;
                result.reasons.add('Primary NAICS match: ' + c.NAICS__c);
            }
            if (profile.Secondary_NAICS__c != null && c.NAICS__c != null && profile.Secondary_NAICS__c.contains(c.NAICS__c)) {
                result.score += 10;
                result.reasons.add('Secondary NAICS match: ' + c.NAICS__c);
            }
            if (profile.Target_Agencies__c != null && c.Agency__c != null && profile.Target_Agencies__c.contains(c.Agency__c)) {
                result.score += 15;
                result.reasons.add('Target agency match: ' + c.Agency__c);
            }
        }

        // Evaluate Fit Rule criteria
        if (rules != null) {
            for (Fit_Rule__mdt rule : rules) {
                if (matchesRule(c, rule)) {
                    Integer weight = rule.Weight__c != null ? Integer.valueOf(rule.Weight__c) : 0;
                    result.score += weight;
                    result.reasons.add(rule.Label + ' (' + weight + ' pts)');
                }
            }
        }

        if (result.reasons.isEmpty()) {
            result.reasons.add('No strong matches against Company Profile or Fit Rules');
        }
        return result;
    }

    private static Boolean matchesRule(NGSR_NGSR_Pipeline_Candidate__c c, Fit_Rule__mdt rule) {
        if (rule.Target_Field__c == null || rule.Operator__c == null || rule.Value__c == null) return false;

        String fieldValue;
        if (rule.Target_Field__c == 'NAICS__c') fieldValue = c.NAICS__c;
        else if (rule.Target_Field__c == 'Agency__c') fieldValue = c.Agency__c;
        else if (rule.Target_Field__c == 'Candidate_Type__c') fieldValue = c.Candidate_Type__c;
        else return false;

        if (fieldValue == null) return false;

        if (rule.Operator__c == 'Equals') return fieldValue == rule.Value__c;
        if (rule.Operator__c == 'Contains') return fieldValue.contains(rule.Value__c);
        if (rule.Operator__c == 'Starts With') return fieldValue.startsWith(rule.Value__c);
        return false;
    }
}
