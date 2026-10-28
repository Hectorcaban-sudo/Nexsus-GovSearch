import { LightningElement } from 'lwc';

export default class NgsrContactsOrgChart extends LightningElement {
    contacts = [
        { id: 1, initials: 'LD', name: 'Laura A. Dean', title: 'Program Executive Officer, PEO C3T', bio: '35+ years in Army acquisition and C4ISR; former PM for Tactical Radios.', influence: 'High', stars: '★★★★★' },
        { id: 2, initials: 'MT', name: 'Michael J. Talley', title: 'Deputy Program Executive Officer', bio: 'Former Brigade Commander and PM for Network Integration.', influence: 'High', stars: '★★★★★' },
        { id: 3, initials: 'JP', name: 'Jennifer K. Pucino', title: 'Chief of Staff, PEO C3T', bio: 'Manages PEO operations and senior leader engagement.', influence: 'Medium', stars: '★★★☆☆' },
        { id: 4, initials: 'DL', name: 'David R. Lewis', title: 'Project Manager, PM Tactical Network', bio: 'Oversees tactical network modernization programs.', influence: 'Medium', stars: '★★★☆☆' },
        { id: 5, initials: 'SW', name: 'Scott A. Williams', title: 'Product Director, PdM WESS', bio: 'Technical lead for satellite communications capabilities.', influence: 'Low', stars: '★☆☆☆☆' }
    ];

    get hierarchy() {
        return [
            { name: 'Department of Defense', children: [
                { name: 'Army', children: [
                    { name: 'ASA (ALT)', children: [
                        { name: 'Program Executive Office (PEO) C3T' }
                    ]}
                ]}
            ]}
        ];
    }
}
