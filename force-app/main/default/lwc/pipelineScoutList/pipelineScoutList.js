import { LightningElement, wire } from 'lwc';
import getTopScoredOpportunities from '@salesforce/apex/PipelineScoutService.getTopScoredOpportunities';

export default class PipelineScoutList extends LightningElement {
    opportunities;
    error;

    @wire(getTopScoredOpportunities, { limitSize: 10 })
    wiredOpps({ error, data }) {
        if (data) {
            this.opportunities = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.opportunities = undefined;
        }
    }
}
