import { LightningElement } from 'lwc';

const CONTACT_COLUMNS = [
    { label: 'Name', fieldName: 'name', type: 'text' },
    { label: 'Title', fieldName: 'title', type: 'text' },
    { label: 'Phone / Email', fieldName: 'contact', type: 'text' },
    { label: 'Influence Rating', fieldName: 'influence', type: 'text' }
];

export default class ContactsOrgChart extends LightningElement {
    contactColumns = CONTACT_COLUMNS;

    hierarchy = [
        { id: '1', name: 'Department of Defense', count: 128, style: '' },
        { id: '2', name: 'Army', count: 45, style: 'margin-left: 1rem' },
        { id: '3', name: 'Office of the Secretary of the Army', count: 18, style: 'margin-left: 2rem' },
        { id: '4', name: 'Assistant Secretary of the Army (ALT)', count: 12, style: 'margin-left: 3rem' },
        { id: '5', name: 'PEO Combat Systems', count: 6, style: 'margin-left: 3rem' }
    ];

    contacts = [
        { id: 'c1', name: 'The Honorable Christine Wormuth', title: 'Secretary of the Army', contact: '(703) 695-3211', influence: 'High' },
        { id: 'c2', name: 'Mr. Douglas Bush', title: 'Assistant Secretary of the Army (ALT)', contact: '(703) 695-3100', influence: 'High' },
        { id: 'c3', name: 'LTG Gary M. Brito', title: 'Deputy Chief of Staff, G-8', contact: '(703) 693-5201', influence: 'Medium' },
        { id: 'c4', name: 'Ms. Jodi S. Johnson', title: 'Deputy Assistant Secretary (Procurement)', contact: '(703) 695-6515', influence: 'Medium' }
    ];

    influencers = [
        { id: 'i1', name: 'Douglas Bush', role: 'Oversees acquisition, logistics & technology' },
        { id: 'i2', name: 'Christine Wormuth', role: 'Sets strategic direction and Army modernization' },
        { id: 'i3', name: 'Gary M. Brito', role: 'Shapes resource allocation and investment' }
    ];

    callPlan = [
        { id: 'p1', name: 'Mr. Douglas Bush – Assistant Secretary (ALT)', objective: 'Discuss Army acquisition priorities and industry partnership. Timing: Within 2 weeks' },
        { id: 'p2', name: 'LTG Gary M. Brito – G-8', objective: 'Understand FY26 budget priorities. Timing: Within 3–4 weeks' }
    ];
}
