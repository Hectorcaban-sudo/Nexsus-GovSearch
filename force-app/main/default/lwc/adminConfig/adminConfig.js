import { LightningElement, track } from 'lwc';
import getAdminStatus from '@salesforce/apex/AdminConfigController.getAdminStatus';
import loadSampleDatasets from '@salesforce/apex/AdminConfigController.loadSampleDatasets';
import uploadSampleDatasets from '@salesforce/apex/AdminConfigController.uploadSampleDatasets';
import clearSampleData from '@salesforce/apex/AdminConfigController.clearSampleData';
import refreshAllScores from '@salesforce/apex/AdminConfigController.refreshAllScores';

export default class AdminConfig extends LightningElement {
    @track status;
    @track message;
    @track error;
    @track isLoading = false;

    connectedCallback() {
        this.loadStatus();
    }

    async loadStatus() {
        try {
            this.status = await getAdminStatus();
            this.error = null;
        } catch (e) {
            this.error = e.body?.message || e.message;
        }
    }

    async handleLoadSample() {
        this.isLoading = true;
        this.message = null;
        this.error = null;
        try {
            this.message = await loadSampleDatasets();
            await this.loadStatus();
        } catch (e) {
            this.error = e.body?.message || e.message;
        } finally {
            this.isLoading = false;
        }
    }

    handleFileChange(event) {
        const file = event.target.files[0];
        if (!file) return;
        const reader = new FileReader();
        reader.onload = async () => {
            this.isLoading = true;
            this.message = null;
            this.error = null;
            try {
                this.message = await uploadSampleDatasets({ jsonContent: reader.result });
                await this.loadStatus();
            } catch (e) {
                this.error = e.body?.message || e.message;
            } finally {
                this.isLoading = false;
            }
        };
        reader.readAsText(file);
    }

    async handleClearSample() {
        this.isLoading = true;
        this.message = null;
        this.error = null;
        try {
            this.message = await clearSampleData();
            await this.loadStatus();
        } catch (e) {
            this.error = e.body?.message || e.message;
        } finally {
            this.isLoading = false;
        }
    }

    async handleRefreshScores() {
        this.isLoading = true;
        this.message = null;
        this.error = null;
        try {
            this.message = await refreshAllScores();
        } catch (e) {
            this.error = e.body?.message || e.message;
        } finally {
            this.isLoading = false;
        }
    }
}
