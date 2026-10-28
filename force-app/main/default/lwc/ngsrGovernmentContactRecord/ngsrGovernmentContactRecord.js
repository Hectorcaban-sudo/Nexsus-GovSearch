import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/NGSR_NGSR_Government_Contact__c.Name';
import TITLE_FIELD from '@salesforce/schema/NGSR_NGSR_Government_Contact__c.Title__c';
import INFLUENCE_FIELD from '@salesforce/schema/NGSR_NGSR_Government_Contact__c.Influence_Rating__c';
import BIO_FIELD from '@salesforce/schema/NGSR_NGSR_Government_Contact__c.Bio_Snippet__c';
const FIELDS = [NAME_FIELD, TITLE_FIELD, INFLUENCE_FIELD, BIO_FIELD];
export default class NgsrGovernmentContactRecord extends LightningElement {
    @api recordId;
    record;
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wired({ error, data }) { if (data) this.record = data; }
    get name() { return getFieldValue(this.record, NAME_FIELD); }
    get title() { return getFieldValue(this.record, TITLE_FIELD) || '—'; }
    get influence() { return getFieldValue(this.record, INFLUENCE_FIELD) || '—'; }
    get bio() { return getFieldValue(this.record, BIO_FIELD) || 'No bio available.'; }
}
