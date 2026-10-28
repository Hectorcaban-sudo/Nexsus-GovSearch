import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/NGSR_NGSR_Award__c.Name';
import INC_FIELD from '@salesforce/schema/NGSR_NGSR_Award__c.Incumbent__c';
const FIELDS = [NAME_FIELD, INC_FIELD];
export default class NgsrAwardRecord extends LightningElement {
    @api recordId;
    record;
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wired({ error, data }) { if (data) this.record = data; }
    get name() { return getFieldValue(this.record, NAME_FIELD); }
    get incumbent() { return getFieldValue(this.record, INC_FIELD) || '—'; }
}
