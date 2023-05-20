import { LightningElement, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import getCEP from '@salesforce/apex/IntegrationViaCEPCallout.getCEP';

export default class CandidateTost extends LightningElement {
    @api recordId;
    @wire(getRecord, { recordId: '$recordId', layoutTypes: ['Full'] })
    candidate;

    handleSave() {
        this.template.querySelector('lightning-record-form').submit();
        console.log('handleSave event triggered');


        // Verifica se há um CEP preenchido
        if (this.candidate.data.fields.Zip_Postal_Code__c.value) {
            getCEP({ endCEP: this.candidate.data.fields.Zip_Postal_Code__c.value })
                .then(result => {
                    console.log('getCEP result:', result);

                    if (result && result.erro === 'true') {
                        const evt = new ShowToastEvent({
                            title: 'CEP não encontrado!',
                            message: 'CEP não encontrado. Por favor, verifique o CEP informado.',
                            variant: 'warning',
                        });
                        this.dispatchEvent(evt);
                    }
                })
                .catch(error => {
                    console.log('Erro:', error);
                });
        }
    }
}