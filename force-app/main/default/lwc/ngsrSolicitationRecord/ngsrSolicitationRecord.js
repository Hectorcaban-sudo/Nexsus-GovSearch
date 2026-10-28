import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/NGSR_NGSR_Solicitation__c.Name';
import NUM_FIELD from '@salesforce/schema/NGSR_NGSR_Solicitation__c.Solicitation_Number__c';
const FIELDS = [NAME_FIELD, NUM_FIELD];
export default class NgsrSolicitationRecord extends LightningElement {
    @api recordId;
    record;
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wired({ error, data }) { if (data) this.record = data; }
    get name() { return getFieldValue(this.record, NAME_FIELD); }
    get number() { return getFieldValue(this.record, NUM_FIELD) || '—'; }
}
