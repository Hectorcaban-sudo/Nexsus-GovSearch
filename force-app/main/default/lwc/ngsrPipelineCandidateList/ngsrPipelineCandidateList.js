import { LightningElement, wire } from 'lwc';
import getTopCandidates from '@salesforce/apex/NGSR_PipelineScoutService.getTopCandidates';

const COLUMNS = [
    { label: 'Title', fieldName: 'Name', type: 'text' },
    { label: 'Agency', fieldName: 'Agency__c', type: 'text' },
    { label: 'Est. Value', fieldName: 'Estimated_Value__c', type: 'currency' },
    {
        label: 'AI Relevancy Score',
        fieldName: 'AI_Relevancy_Score__c',
        type: 'number',
        cellAttributes: { class: { fieldName: 'scoreClass' } }
    },
    { label: 'Strategic Fit', fieldName: 'Strategic_Fit__c', type: 'text' },
    { label: 'Incumbent', fieldName: 'Incumbent__c', type: 'text' },
    { label: 'Type', fieldName: 'Candidate_Type__c', type: 'text' },
    { label: 'Due Date', fieldName: 'Due_Date__c', type: 'date' },
    {
        type: 'action',
        typeAttributes: { rowActions: [{ label: 'View', name: 'view' }] }
    }
];

export default class NgsrPipelineCandidateList extends LightningElement {
    candidates = [];
    error;
    columns = COLUMNS;

    @wire(getTopCandidates)
    wiredCandidates({ error, data }) {
        if (data) {
            this.candidates = data.map(c => ({
                ...c,
                scoreClass: this.getScoreClass(c.AI_Relevancy_Score__c)
            }));
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.candidates = [];
        }
    }

    get topFive() {
        return this.candidates.slice(0, 5);
    }

    get highScoreCount() {
        return this.candidates.filter(c => (c.AI_Relevancy_Score__c || 0) >= 90).length;
    }

    get totalValue() {
        return this.candidates.reduce((sum, c) => sum + (c.Estimated_Value__c || 0), 0);
    }

    getScoreClass(score) {
        if (score >= 90) return 'slds-text-color_success';
        if (score >= 80) return 'slds-text-color_warning';
        return '';
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        if (actionName === 'view') {
            console.log('Navigate to', row.Id);
        }
    }
}
