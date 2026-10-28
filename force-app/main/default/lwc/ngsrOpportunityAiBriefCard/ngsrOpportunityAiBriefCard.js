import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';


const FIELDS = [AI_SCORE, STRATEGIC_FIT, BRIEF, INCUMBENT, PRIORITY, NAICS];

export default class NgsrOpportunityAiBriefCard extends LightningElement {
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    opportunity;

    get score() {
        return getFieldValue(this.opportunity.data, AI_SCORE) || 0;
    }

    get strategicFit() {
        return getFieldValue(this.opportunity.data, STRATEGIC_FIT) || '—';
    }

    get brief() {
        return getFieldValue(this.opportunity.data, BRIEF) || 'No AI brief generated yet. Use the Opportunity Intelligence Agent to create one.';
    }

    get incumbent() {
        return getFieldValue(this.opportunity.data, INCUMBENT) || '—';
    }

    get priority() {
        return getFieldValue(this.opportunity.data, PRIORITY) || '—';
    }

    get naics() {
        return getFieldValue(this.opportunity.data, NAICS) || '—';
    }

    get scoreClass() {
        const s = this.score;
        if (s >= 90) return 'slds-text-color_success';
        if (s >= 75) return 'slds-text-color_warning';
        return '';
    }

    get scoreStyle() {
        return `width: ${this.score}%`;
    }

    // Placeholder structured sections — replace with real Agentforce output
    get incumbentStrengths() {
        return 'Incumbent holds strong position with deep agency knowledge and established relationships.';
    }

    get competitiveWhitespace() {
        return 'Opportunity exists in cloud-native modernization, zero-trust architecture, and data analytics capabilities.';
    }

    get pursuitPrioritization() {
        return `Score: ${this.score}/100 – ${this.priority} strategic fit. Recommend early positioning and teaming.`;
    }
}
