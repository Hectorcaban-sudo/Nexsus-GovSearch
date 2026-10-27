# Nexsus GovSearch — Requirements Gap Analysis

**Source**: GovCon Capture & Market Intelligence on Salesforce — Requirements Document (v0.1)
**Date**: 2026-10-26
**Scope**: Comparison against current Nexsus GovSearch solution

## Summary

| Layer | Coverage | Notes |
|-------|----------|-------|
| Market intelligence & AI scoring | ~65% | Strong foundation with Pipeline_Candidate__c, scoring, Agentforce, Data Cloud |
| Full capture CRM (gates, scorecards, plans, teaming) | ~20% | Major gaps in structured capture process |
| Overall MVP readiness | Foundation | Ready for intelligence layer; capture lifecycle needs expansion |

## Aligned Capabilities

- SAM.gov ingestion (hybrid strategy + Apex callout + Data Cloud + Ingestion API)
- Rules-based AI relevancy scoring (`PipelineScoutService`)
- Agentforce agent sketches (Pipeline Scout, Opportunity Intelligence, Research & Relationship)
- Government contacts + org chart LWC
- Integration logging (`Integration_Log__c`)
- LWC dashboard and AI brief components matching TechnoMile-style UX
- Core objects: Pipeline_Candidate__c, Award__c, Contract_Vehicle__c, Solicitation__c

## Gap Analysis by Module

### 1. Opportunity Intelligence (INT) — Partial

| ID | Requirement | Status | Gap |
|----|-------------|--------|-----|
| INT-01 | Ingest SAM.gov opportunities every 4h | Partial | Callout + scheduled pattern exists; frequency & full notice types need config |
| INT-02 | Amendments as versions | Missing | No Notice_Version__c |
| INT-03 | Download attachments | Missing | No document handling |
| INT-04 | Agency forecasts | Missing | No Forecast__c |
| INT-05 | USAspending awards | Partial | Award__c exists; no full ingestion |
| INT-06 | De-duplication + source lineage | Partial | External_Id__c used; fuzzy matching not implemented |
| INT-10 | Admin console for feeds | Partial | Integration_Log__c exists; no UI console |

### 2. Search, Saved Searches & Alerts (SRCH) — Missing

- Faceted search, Saved Search object, alert frequency, change alerts, daily digests, bulk export all missing.

### 3. Qualification & Fit Scoring (QUAL) — Partial

- Scoring exists but is not driven by a Company Profile.
- No Company_Profile__c, no configurable Fit_Rule__mdt, no formal triage queue (Promote/Watch/Dismiss).

### 4. Pipeline & Capture Management (CAP) — Major Gap

Missing:
- Gate reviews with checklists and approvals
- Bid/No-Bid scorecard
- pWin / pGo and weighted value
- Capture Plan
- Key dates + reminders
- Capture team roles
- Kanban board
- Win/loss debrief structure

### 5. Market & Competitive Intelligence (MKT) — Partial

- Agency hierarchy and Award objects exist.
- Missing: full agency profiles (spend/budget), recompete tracker, vendor/competitor profiles with UEI/CAGE.

### 6. Teaming & Partner Management (TEAM) — Missing

- No Teaming_Partner__c junction, no Agreement object, no partner search.

### 7. Government Contacts (CON) — Partial

- Government_Contact__c and org chart exist.
- Missing: auto-create from notice POCs, Call Report / Call Plan objects.

### 8. Contract Vehicles (VEH) — Partial

- Contract_Vehicle__c exists.
- Missing: holders junction, email-to-opportunity intake.

### 9. Documents & Collaboration (DOC) — Missing

- No structured document storage against pursuits.

### 10. AI Assistant (AI) — Strong (Phase 2 alignment)

- Agentforce agents and prompt stubs already exist. Aligns well with AI-01 / AI-02.

## Recommended Priority (MVP Musts)

1. Company_Profile__c + Fit_Rule__mdt + update scoring
2. Notice_Version__c + Forecast__c
3. Gate_Review__c + Bid_Decision_Scorecard__c + Capture_Plan__c
4. Saved_Search__c + alert framework
5. Teaming_Partner__c + Call_Report__c
6. Triage actions (Promote / Watch / Dismiss) on Pipeline_Candidate__c
7. Persona permission sets
8. Core dashboards

## Scaffolded Objects (this commit)

The following objects have been added as stubs to accelerate MVP development:

- Company_Profile__c
- Fit_Rule__mdt (custom metadata)
- Notice_Version__c
- Forecast__c
- Gate_Review__c
- Bid_Decision_Scorecard__c
- Capture_Plan__c
- Saved_Search__c
- Teaming_Partner__c
- Call_Report__c

See `docs/data-model.md` for updated model.

## Next Actions

- Flesh out fields and relationships on the new objects
- Add page layouts and permission sets
- Implement triage Flow / Apex action
- Wire scoring to Company Profile + Fit Rules
- Build saved search + alert engine
- Add the five MVP dashboards
