import { LightningElement, wire } from 'lwc';
import getTopCandidates from '@salesforce/apex/PipelineScoutService.getTopCandidates';

export default class PipelineScoutList extends LightningElement {
    candidates;
    error;

    @wire(getTopCandidates)
    wiredCandidates({ error, data }) {
        if (data) {
            this.candidates = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.candidates = undefined;
        }
    }
}
