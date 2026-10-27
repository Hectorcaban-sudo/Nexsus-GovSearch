# Sample Data

Use this data to populate the Nexsus GovSearch app so the dashboards and record pages look realistic after deployment.

## Pipeline Candidates (Pipeline_Candidate__c)

| Name | Agency__c | Candidate_Type__c | Estimated_Value__c | AI_Relevancy_Score__c | Strategic_Fit__c | Incumbent__c | Status__c | Due_Date__c | NAICS__c | External_Id__c |
|------|-----------|-------------------|--------------------|-----------------------|------------------|--------------|-----------|-------------|----------|----------------|
| Advanced Cloud Security Engineering Support | Department of Homeland Security | Recompete | 24800000 | 98 | High | Booz Allen Hamilton | New | 2025-06-17 | 541512 | SAM-001 |
| Enterprise IT Modernization Services | Department of Defense | Solicitation | 18600000 | 95 | High | Leidos | New | 2025-06-30 | 541512 | SAM-002 |
| AI/ML Platform Integration | Department of Health & Human Services | Task Order | 15200000 | 92 | High | Deloitte | New | 2025-07-11 | 541511 | SAM-003 |
| Cybersecurity Program Support | Department of Transportation | Recompete | 12700000 | 89 | Medium | CACI | New | 2025-07-25 | 541512 | SAM-004 |
| Data Analytics & Visualization Services | Department of Veterans Affairs | Solicitation | 9800000 | 85 | Medium | Accenture Federal Services | New | 2025-08-05 | 541511 | SAM-005 |
| Cloud Infrastructure Engineering | Department of Commerce | Task Order | 7600000 | 82 | Medium | General Dynamics IT | New | 2025-08-19 | 541512 | SAM-006 |
| Application Development Support | Department of Energy | Recompete | 6300000 | 78 | Low | Perspecta | New | 2025-09-02 | 541511 | SAM-007 |

## Opportunities

Create Opportunities with:
- Name: Army IT Modernization Recompete
- Amount: 275000000
- Stage: Qualification
- AI_Relevancy_Score__c: 92
- Pursuit_Priority__c: High
- Incumbent__c: Lockheed Martin
- NAICS_Tags__c: 541512;541513;541519;541611
- AI_Brief_Summary__c: (use the structured brief text from the mockup)

## Government Contacts (Government_Contact__c)

| Name | Title__c | Influence_Rating__c | Bio_Snippet__c |
|------|----------|---------------------|----------------|
| Christine Wormuth | Secretary of the Army | High | Former DoD senior policy official with 20+ years in defense strategy. |
| Douglas Bush | Assistant Secretary of the Army (ALT) | High | Oversees acquisition programs, logistics policy, and technology integration. |
| Gary M. Brito | Deputy Chief of Staff, G-8 | Medium | Leads Army resource programming and fiscal strategy. |
| Jodi S. Johnson | Deputy Assistant Secretary (Procurement) | Medium | Expert in federal procurement policy and contracting strategy. |

## How to Load

1. Use Data Loader, Salesforce Inspector, or Anonymous Apex to insert the records.
2. Or create a simple Apex script that inserts the Pipeline Candidates and Contacts.
3. After loading, run `PipelineScoutService.refreshScores()` if needed.
4. Open the Nexsus GovSearch app to see the dashboard and contacts page.

See also the LWC components that consume this data.
