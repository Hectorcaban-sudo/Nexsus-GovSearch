# Sample Data Notes

Use these examples to seed a scratch org or developer org for Nexsus GovSearch demos.

## Pipeline Candidates

| Name | Agency | Type | Estimated Value | AI Score | Status | Source |
|------|--------|------|-----------------|----------|--------|--------|
| Army IT Modernization Recompete | Department of the Army | Recompete | 249000000 | 92 | New | SAM.gov |
| DHS Cloud Security Engineering | Department of Homeland Security | Solicitation | 18600000 | 95 | Under Review | SAM.gov |
| VA Data Analytics Platform | Department of Veterans Affairs | Task Order | 9800000 | 85 | New | FedConnect |

## Past Performance Profiles

- Cloud modernization and cybersecurity for DoD agencies (NAICS 541512, 541519)
- Enterprise IT services for civilian agencies

## Strategic Objectives

- Grow digital modernization and AI/ML practice
- Expand presence with Army and DHS
- Prioritize contracts > $10M with high strategic fit

## How to Load

1. Create records via Data Loader, Salesforce Inspector, or a simple Apex script.
2. Or use the following as a starting point for an Anonymous Apex script in Developer Console:

```apex
Pipeline_Candidate__c c1 = new Pipeline_Candidate__c(
    Name = 'Army IT Modernization Recompete',
    Agency__c = 'Department of the Army',
    Candidate_Type__c = 'Recompete',
    Estimated_Value__c = 249000000,
    AI_Relevancy_Score__c = 92,
    Status__c = 'New',
    Source_System__c = 'SAM.gov'
);
insert c1;
```

After loading, run the Pipeline Scout agent or scoring logic to refine scores.
