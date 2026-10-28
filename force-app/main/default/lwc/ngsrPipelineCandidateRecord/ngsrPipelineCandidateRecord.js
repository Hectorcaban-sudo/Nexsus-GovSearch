import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/NGSR_Pipeline_Candidate__c.Name';
import AGENCY_FIELD from '@salesforce/schema/NGSR_Pipeline_Candidate__c.Agency__c';
import TYPE_FIELD from '@salesforce/schema/NGSR_Pipeline_Candidate__c.Candidate_Type__c';
import VALUE_FIELD from '@salesforce/schema/NGSR_Pipeline_Candidate__c.Estimated_Value__c';
import SCORE_FIELD from '@salesforce/schema/NGSR_Pipeline_Candidate__c.AI_Relevancy_Score__c';
import FIT_FIELD from '@salesforce/schema/NGSR_Pipeline_Candidate__c.Strategic_Fit__c';
import STATUS_FIELD from '@salesforce/schema/NGSR_Pipeline_Candidate__c.Status__c';
import DUE_FIELD from '@salesforce/schema/NGSR_Pipeline_Candidate__c.Due_Date__c';
import TRIAGE_FIELD from '@salesforce/schema/NGSR_Pipeline_Candidate__c.Triage_Status__c';
import REASONS_FIELD from '@salesforce/schema/NGSR_Pipeline_Candidate__c.Score_Reasons__c';
import NAICS_FIELD from '@salesforce/schema/NGSR_Pipeline_Candidate__c.NAICS__c';

const FIELDS = [NAME_FIELD, AGENCY_FIELD, TYPE_FIELD, VALUE_FIELD, SCORE_FIELD, FIT_FIELD, STATUS_FIELD, DUE_FIELD, TRIAGE_FIELD, REASONS_FIELD, NAICS_FIELD];

export default class NgsrPipelineCandidateRecord extends LightningElement {
    @api recordId;
    record;
    error;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (data) {
            this.record = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.record = undefined;
        }
    }

    get name() { return getFieldValue(this.record, NAME_FIELD); }
    get agency() { return getFieldValue(this.record, AGENCY_FIELD) || '—'; }
    get candidateType() { return getFieldValue(this.record, TYPE_FIELD) || '—'; }
    get estimatedValue() { return getFieldValue(this.record, VALUE_FIELD); }
    get score() { return getFieldValue(this.record, SCORE_FIELD) || 0; }
    get strategicFit() { return getFieldValue(this.record, FIT_FIELD) || '—'; }
    get status() { return getFieldValue(this.record, STATUS_FIELD) || '—'; }
    get dueDate() { return getFieldValue(this.record, DUE_FIELD); }
    get triageStatus() { return getFieldValue(this.record, TRIAGE_FIELD) || '—'; }
    get reasons() { return getFieldValue(this.record, REASONS_FIELD) || 'No score reasons yet. Click Refresh Scores on the Admin page.'; }
    get naics() { return getFieldValue(this.record, NAICS_FIELD) || '—'; }

    get scoreClass() {
        if (this.score >= 90) return 'score-high';
        if (this.score >= 70) return 'score-medium';
        return 'score-low';
    }

    get formattedValue() {
        if (!this.estimatedValue) return '—';
        return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD', maximumFractionDigits: 0 }).format(this.estimatedValue);
    }
}
