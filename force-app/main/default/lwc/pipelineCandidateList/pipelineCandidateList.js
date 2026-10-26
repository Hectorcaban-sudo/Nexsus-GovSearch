import { LightningElement, wire } from 'lwc';
import getTopCandidates from '@salesforce/apex/PipelineScoutService.getTopCandidates';

const COLUMNS = [
    { label: 'Name', fieldName: 'Name', type: 'text' },
    { label: 'Agency', fieldName: 'Agency__c', type: 'text' },
    { label: 'Type', fieldName: 'Candidate_Type__c', type: 'text' },
    { label: 'AI Score', fieldName: 'AI_Relevancy_Score__c', type: 'number', cellAttributes: { alignment: 'center' } },
    { label: 'Strategic Fit', fieldName: 'Strategic_Fit__c', type: 'text' },
    { label: 'Est. Value', fieldName: 'Estimated_Value__c', type: 'currency' },
    { label: 'Status', fieldName: 'Status__c', type: 'text' },
    {
        type: 'action',
        typeAttributes: { rowActions: [{ label: 'View', name: 'view' }] }
    }
];

export default class PipelineCandidateList extends LightningElement {
    candidates = [];
    error;
    columns = COLUMNS;

    @wire(getTopCandidates)
    wiredCandidates({ error, data }) {
        if (data) {
            this.candidates = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.candidates = [];
        }
    }

    get highScoreCount() {
        return this.candidates.filter(c => (c.AI_Relevancy_Score__c || 0) >= 85).length;
    }

    get totalValue() {
        return this.candidates.reduce((sum, c) => sum + (c.Estimated_Value__c || 0), 0);
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        if (actionName === 'view') {
            // Placeholder navigation
            console.log('Navigate to', row.Id);
        }
    }
}
