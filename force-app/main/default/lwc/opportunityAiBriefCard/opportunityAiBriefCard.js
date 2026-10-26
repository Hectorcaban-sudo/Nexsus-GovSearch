import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import AI_SCORE from '@salesforce/schema/Opportunity.AI_Relevancy_Score__c';
import STRATEGIC_FIT from '@salesforce/schema/Opportunity.Strategic_Fit__c';
import BRIEF from '@salesforce/schema/Opportunity.AI_Brief_Summary__c';
import INCUMBENT from '@salesforce/schema/Opportunity.Incumbent__c';
import PRIORITY from '@salesforce/schema/Opportunity.Pursuit_Priority__c';

const FIELDS = [AI_SCORE, STRATEGIC_FIT, BRIEF, INCUMBENT, PRIORITY];

export default class OpportunityAiBriefCard extends LightningElement {
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    opportunity;

    get score() {
        return getFieldValue(this.opportunity.data, AI_SCORE) || '—';
    }

    get strategicFit() {
        return getFieldValue(this.opportunity.data, STRATEGIC_FIT) || '—';
    }

    get brief() {
        return getFieldValue(this.opportunity.data, BRIEF) || 'No AI brief generated yet.';
    }

    get incumbent() {
        return getFieldValue(this.opportunity.data, INCUMBENT) || '—';
    }

    get priority() {
        return getFieldValue(this.opportunity.data, PRIORITY) || '—';
    }
}
