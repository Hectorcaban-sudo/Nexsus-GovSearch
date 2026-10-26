import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = ['Opportunity.Name', 'Opportunity.AI_Relevancy_Score__c', 'Opportunity.Strategic_Fit__c', 'Opportunity.AI_Brief_Summary__c'];

export default class OpportunityBriefCard extends LightningElement {
    @api recordId;
    opportunity;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredOpp({ error, data }) {
        if (data) {
            this.opportunity = data;
        }
    }

    get relevancyScore() {
        return this.opportunity?.fields?.AI_Relevancy_Score__c?.value || '—';
    }

    get briefSummary() {
        return this.opportunity?.fields?.AI_Brief_Summary__c?.value || 'No AI brief generated yet. Ask Opportunity Intelligence to create one.';
    }
}
