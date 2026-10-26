import { LightningElement, wire } from 'lwc';
import getTopCandidates from '@salesforce/apex/PipelineScoutService.getTopCandidates';

export default class PipelineCandidateList extends LightningElement {
    candidates = [];
    error;

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

    handleView(event) {
        const recordId = event.target.dataset.id;
        // Navigate to record (placeholder)
        console.log('View Pipeline Candidate:', recordId);
    }
}
