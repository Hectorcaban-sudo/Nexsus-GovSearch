import { LightningElement, wire } from 'lwc';
import getTopCandidates from '@salesforce/apex/PipelineScoutService.getTopCandidates';

export default class ResearchConsole extends LightningElement {
    candidates = [];
    searchTerm = '';

    @wire(getTopCandidates)
    wired({ error, data }) {
        if (data) this.candidates = data;
    }

    get filtered() {
        if (!this.searchTerm) return this.candidates;
        const t = this.searchTerm.toLowerCase();
        return this.candidates.filter(c => (c.Name || '').toLowerCase().includes(t) || (c.Agency__c || '').toLowerCase().includes(t));
    }

    get resultCount() { return this.filtered.length; }

    handleSearch(e) { this.searchTerm = e.target.value; }

    // Demo data for mockup-style panels
    get competitors() {
        return [
            { name: 'Unisys Corporation', pct: 22, value: '$2.38B', color: '#0176D3' },
            { name: 'Deloitte Consulting', pct: 18, value: '$1.98B', color: '#2E844A' },
            { name: 'Leidos, Inc.', pct: 14, value: '$1.58B', color: '#FE9339' },
            { name: 'Other Vendors', pct: 37, value: '$3.88B', color: '#706E6B' }
        ];
    }

    get partners() {
        return [
            { name: 'TechFlow, Inc.', match: 92, overlap: '87%', setAside: 'HUBZone', score: 9.2 },
            { name: 'One Federal Solution', match: 89, overlap: '82%', setAside: 'Small Business', score: 8.7 },
            { name: 'Iron Bow Technologies', match: 85, overlap: '78%', setAside: 'SDVOSB', score: 8.4 }
        ];
    }

    get spendYears() {
        return [
            { year: 'FY2020', value: 1.2 },
            { year: 'FY2021', value: 1.6 },
            { year: 'FY2022', value: 2.1 },
            { year: 'FY2023', value: 2.6 },
            { year: 'FY2024', value: 5.0 }
        ];
    }
}
