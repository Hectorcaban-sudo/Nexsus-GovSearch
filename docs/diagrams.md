# Nexsus GovSearch Diagrams

This document contains Mermaid diagrams for architecture, user workflows, data flows, and supporting processes. They render natively on GitHub.

## 1. High-Level Architecture

```mermaid
flowchart TD
    subgraph External["External Data Sources"]
        SAM[SAM.gov]
        USA[USAspending]
        FC[FedConnect]
        PIEE[PIEE]
        Forecasts[Agency Forecasts]
        Contacts[Proprietary Contacts]
    end

    subgraph Integration["Integration Layer"]
        Callout[PipelineScoutCalloutService<br/>Pull via Named Credential]
        Ingest[PipelineCandidateIngestionService<br/>Push via Apex REST]
        DataCloud[Data Cloud / MuleSoft]
    end

    subgraph Salesforce["Salesforce Platform"]
        PC[Pipeline_Candidate__c]
        Opp[Opportunity]
        Award[Award__c]
        Sol[Solicitation__c]
        Contact[Government_Contact__c]
        Log[Integration_Log__c]
        Score[PipelineScoutService<br/>Scoring]
        Agents[Agentforce Agents]
        LWC[LWC Components]
        App[Nexsus GovSearch App]
    end

    External -->|Pull| Callout
    External -->|Push| Ingest
    External --> DataCloud

    Callout --> PC
    Ingest --> PC
    DataCloud --> PC

    PC --> Score
    Score --> PC
    Score --> Log
    Callout --> Log
    Ingest --> Log

    PC --> Opp
    PC --> LWC
    Opp --> LWC
    Agents --> PC
    Agents --> Opp
    Agents --> Contact
    LWC --> App
    Agents --> App
```

## 2. Data Ingestion Workflows

```mermaid
flowchart LR
    subgraph Pull["Pull Pattern - Apex Callout"]
        Sched[Schedulable / Button]
        CalloutSvc[PipelineScoutCalloutService]
        NamedCred[Named Credential]
        ExtAPI[External API]
        Upsert1[Upsert Pipeline_Candidate__c]
        Score1[PipelineScoutService.refreshScoresFor]
    end

    Sched --> CalloutSvc
    CalloutSvc --> NamedCred
    NamedCred --> ExtAPI
    ExtAPI --> CalloutSvc
    CalloutSvc --> Upsert1
    Upsert1 --> Score1

    subgraph Push["Push Pattern - Ingestion API"]
        ExtSys[External System / MuleSoft]
        REST[POST /nexsus/pipeline-candidates]
        IngestSvc[PipelineCandidateIngestionService]
        Upsert2[Upsert Pipeline_Candidate__c]
        Score2[PipelineScoutService.refreshScoresFor]
    end

    ExtSys --> REST
    REST --> IngestSvc
    IngestSvc --> Upsert2
    Upsert2 --> Score2
```

## 3. Pipeline Scout User Workflow

```mermaid
flowchart TD
    Start([BD User opens Nexsus GovSearch App]) --> Dashboard[Views pipelineCandidateList<br/>Summary cards + ranked table]
    Dashboard --> Review{Review high-score<br/>candidates?}
    Review -->|Yes| Detail[Open Pipeline Candidate<br/>or related Opportunity]
    Review -->|No| Filter[Apply filters or<br/>ask Pipeline Scout Agent]
    Filter --> Dashboard

    Detail --> Decide{Pursue?}
    Decide -->|Yes| Convert[Convert to Opportunity<br/>via Agent or Flow]
    Decide -->|No| Disqualify[Update Status to Disqualified]
    Decide -->|Need more info| Agent[Ask Pipeline Scout Agent<br/>for scoring rationale]

    Convert --> OppPage[Opportunity record page]
    OppPage --> Brief[View opportunityAiBriefCard<br/>or generate AI Brief]
    Brief --> Team[Teaming / Call Plan<br/>via Research Agent]
    Team --> End([Pursuit decision complete])
```

## 4. Opportunity Intelligence Workflow

```mermaid
sequenceDiagram
    actor User as BD / Capture User
    participant Opp as Opportunity Record
    participant LWC as opportunityAiBriefCard
    participant Agent as Opportunity Intelligence Agent
    participant Apex as OpportunityIntelligenceService
    participant PT as Prompt Template

    User->>Opp: Opens Opportunity
    Opp->>LWC: Displays current AI fields
    User->>Agent: "Generate an AI brief"
    Agent->>Apex: Call generateBrief action
    Apex->>PT: Invoke prompt with record context
    PT-->>Apex: Generated brief text
    Apex->>Opp: Update AI_Brief_Summary__c
    Opp-->>LWC: Refresh via LDS
    LWC-->>User: Shows updated brief
    User->>Agent: Follow-up questions
    Agent-->>User: Answers grounded in record + related data
```

## 5. Scoring Process

```mermaid
flowchart TD
    Trigger[New or updated<br/>Pipeline_Candidate__c]
    Trigger --> Source{Source?}
    Source -->|Callout| CalloutDone[PipelineScoutCalloutService]
    Source -->|Ingestion| IngestDone[PipelineCandidateIngestionService]
    Source -->|Manual| Manual[User or Flow]

    CalloutDone --> Score[PipelineScoutService.refreshScoresFor]
    IngestDone --> Score
    Manual --> Score

    Score --> Logic[Apply scoring rules<br/>Value, Type, NAICS, Past Performance]
    Logic --> Update[Update AI_Relevancy_Score__c<br/>and Strategic_Fit__c]
    Update --> Log[IntegrationLogger.info]
    Log --> Dashboard[LWC refreshes<br/>or Agent queries]
```

## 6. Agentforce Interaction Overview

```mermaid
flowchart LR
    User[User]
    Panel[Agentforce Panel]
    Scout[Pipeline Scout Agent]
    Intel[Opportunity Intelligence Agent]
    Research[Research & Relationship Agent]

    User <--> Panel
    Panel --> Scout
    Panel --> Intel
    Panel --> Research

    Scout --> PC[Pipeline_Candidate__c]
    Scout --> ScoreSvc[PipelineScoutService]
    Intel --> Opp[Opportunity]
    Intel --> BriefSvc[OpportunityIntelligenceService]
    Research --> Contact[Government_Contact__c]
    Research --> Award[Award__c]
```

## 7. Logging & Error Handling

```mermaid
flowchart TD
    Process[Callout / Ingestion / Scoring]
    Process -->|Success| Info[IntegrationLogger.info]
    Process -->|Warning| Warn[IntegrationLogger.warn]
    Process -->|Error| Err[IntegrationLogger.error]
    Info --> LogObj[Integration_Log__c]
    Warn --> LogObj
    Err --> LogObj
    LogObj --> Review[Admin / Developer reviews logs]
```

## Usage Notes

- These diagrams are written in Mermaid and render on GitHub and in many Markdown viewers.
- Update them as the solution evolves (e.g., when real past-performance scoring logic is added).
- For formal architecture reviews, export the Mermaid diagrams to images using the Mermaid Live Editor or a CI tool.
