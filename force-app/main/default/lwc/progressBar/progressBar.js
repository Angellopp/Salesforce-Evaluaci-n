import { LightningElement, api, wire } from 'lwc';
import getSeguimientos from '@salesforce/apex/SeguimientoController.getSeguimientosByContact';

export default class ProgressBar extends LightningElement {
    @api recordId; // Contact ID viene automáticamente de la página
    
    totalTasks = 0;
    completedTasks = 0;
    progressPercentage = 0;
    hasData = false;
    error = null;

    @wire(getSeguimientos, { contactId: '$recordId' })
    wiredSeguimientos({ error, data }) {
        if (data) {
            console.log('Aqui recibi datos:', data);
            this.totalTasks = data.length;
            this.completedTasks = data.filter(seg => seg.Etapa__c === 'Completado').length;
            
            if (this.totalTasks > 0) {
                this.progressPercentage = Math.round((this.completedTasks / this.totalTasks) * 100);
                this.hasData = true;
            } else {
                this.progressPercentage = 0;
                this.hasData = false;
            }
            this.error = null;
        } else if (error) {
            console.error('Error loading seguimientos:', error);
            this.hasData = false;
            this.error = error.body ? error.body.message : 'Error desconocido';
        }
    }
    get progressInfo() {
        return `${this.completedTasks} de ${this.totalTasks} completadas`;
    }
}