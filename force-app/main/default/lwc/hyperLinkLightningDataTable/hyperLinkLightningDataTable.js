import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import fetchAccounts from '@salesforce/apex/AccountController.fetchAccounts';

const columns = [
    {label: 'Name', fieldName: 'Id', type: 'url',
        typeAttributes: {
            label: { fieldName: 'AccountName' },
            target: '_blank'
        }
    },
    { label: 'Industry', fieldName: 'Industry' }
];

export default class HyperLinkLightningDataTable extends NavigationMixin(LightningElement) {
    data = [];
    columns = columns;

    connectedCallback() {
        this.loadAccountData();
    }

    loadAccountData() {
        fetchAccounts()
            .then(result => {
                this.data = result.map(account => ({
                    ...account,
                    AccountName: account.Name,
                    Id: `/${account.Id}`
                }));
            })
            .catch(error => {
                console.error('Erro ao buscar as contas:', error);
            });
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        if (actionName === 'urlredirect') {
            this.showRowDetails(row);
        }
    }

    showRowDetails(row) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: row.Id,
                objectApiName: 'Account',
                actionName: 'view'
            }
        });
    }
}