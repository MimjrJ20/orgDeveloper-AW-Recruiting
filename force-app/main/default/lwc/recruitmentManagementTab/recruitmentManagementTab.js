import { LightningElement, track } from "lwc";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import retrivePositions from "@salesforce/apex/PositionDAO.getPositionsAvailable";
import updatePosition from "@salesforce/apex/PositionController.updatePosition";
import getPicklistValues from "@salesforce/apex/PositionDAO.getPicklistValues";
import getCurrentUserProfileId from "@salesforce/apex/UserController.getCurrentUserProfileId";
import getProfileName from "@salesforce/apex/UserController.getProfileName";
import getCurrentUserId from "@salesforce/apex/UserController.getCurrentUserId";
import getCurrentUserName from "@salesforce/apex/UserController.getCurrentUserName";


export default class RecruitmentManagementTab extends LightningElement {

    //-----------------
    //variáveis
    @track data = [];
    @track filteredData = [];
    @track statusOptionsTable = [];
    @track ownerOptionsTable = [];
    @track recordIds = [];
    @track selectedCons = [];
    @track statusOptions = [];
    @track approvalStatusOptions = [];
    @track ownerOptions = [];

    @track queryTerm = "";    
    @track approvalStatusValue = "";
    @track statusValue = "";
    @track ownerValue = "";
    @track selectedStatus = "All";
    @track selectedOwner = "All";
    @track statusValueTable = "All";
    @track ownerValueTable = "All";


    @track rowNumber;
    @track idProfile;
    @track nameProfile;

    @track bShowModal = false;
    @track disableOptions = false;


    //-----------------
    //funções geral

    //função - fechar modal
    closeModal() {
        this.bShowModal = false;
        this.selectedCons = [];
        this.recordIds = [];
    }
    
    //função - simplificar as chamadas de toast
    showToast(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(toastEvent);
    }

    //função - seja executado uma vez, para evitar que ele seja executado duas vezes
    connectedCallback() { 
        this.loadTable(); 
        this.loadPicklistValues("Status__c");
        this.loadPicklistValues("Approval_Status__c");
    }

    //-----------------
    //funções de evento

    //função - verifica se foi pressionada a tecla ENTER e chama a função que filtra a tabela
    handleKeyUp(event) {
        const isEnterKey = event.keyCode === 13;

        if (isEnterKey) {
            this.queryTerm = event.target.value;
            this.loadTable();
        } else if (event.target.value.trim() === "") {
            this.queryTerm = "";
            this.loadTable();
        }
    }

    //função - quando altera o valor do status chama a função que atualiza a tabela
    handleChangeStatusTable(event) { 
        this.selectedStatus = event.detail.value; 
        this.loadTable();
    }

    //função - quando altera o valor do status chama a função que atualiza a tabela
    handleChangeOwnerTable(event) { 
        this.selectedOwner = event.detail.value; 
        this.loadTable();
    }

    //função - quando altera o valor
    handleChangeApprovalStatus(event) {
        this.approvalStatusValue = event.target.value;
    }
    
    //função - quando altera o valor
    handleChangeStatus(event) {
        this.statusValue = event.target.value;
    }

    //função - quando altera o valor
    handleChangeOwner(event) {
        this.ownerValue = event.target.value;
    }

    //-----------------
    //funções carregar

    //função - carregar a tabela e obter os dados
    loadTable() {

        this.rowNumber = 1;

        //método apex para obter os registros
        retrivePositions({
            searchTerm: this.queryTerm,
            selectedStatus: this.selectedStatus,
            selectedOwner: this.selectedOwner
        })
        .then((result) => {

            result.forEach((item) => {
                item.rowNumber = this.rowNumber;
                this.rowNumber++;
                item.CreatedDate = this.formatDate(item.CreatedDate);
            });

            this.data = result;

            //pegando os valores para Status__c no result e passando para uma lista Set para que sejam valores únicos
            const uniqueStatusValues = [...new Set(result.map((row) => row.Status__c))];

            this.statusOptionsTable = [
                { label: this.statusValueTable, value: this.statusValueTable },
                ...uniqueStatusValues.map((status) => ({
                    label: status,
                    value: status
                }))
            ];

            //pegando os valores para Owner no result e passando para uma lista Set para que sejam valores únicos
            const uniqueOwnerValues = [...new Set(result.map((row) => row.OwnerId))];
            const ownerNamesMap = new Map();
            
            result.forEach((row) => {
                ownerNamesMap.set(row.OwnerId, row.Owner.Name);
            });
            
            this.ownerOptionsTable = [
                { label: this.ownerValueTable, value: this.ownerValueTable },
                ...uniqueOwnerValues.map((ownerId) => ({
                    label: ownerNamesMap.get(ownerId),
                    value: ownerId
                }))
            ];
            console.log("this.selectedOwner: ", this.selectedOwner);

        })
        .catch((error) => {
            console.error("Error loading positions: ", error);
        });

    }

    //função - para refresh
    loadTableRefresh(){
        this.loadTable();
    }

    //função - selecionar todas as linhas
    allSelected(event) {
        
        var selectedRows = this.template.querySelectorAll("lightning-input");

        for (let i = 0; i < selectedRows.length; i++) {
            if (selectedRows[i].type === "checkbox") {
                selectedRows[i].checked = event.target.checked;
            }
        }
    }

    //função - abrir modal e mostrar positions
    showPositions() {

        this.rowNumber = 1;

        var selectedRows = this.template.querySelectorAll("lightning-input");
        var selectedCons = [];
        var recordIds = [];

        //com base na linha selecionada, obtenha os valores das positions
        for (let i = 0; i < selectedRows.length; i++) {
            if (selectedRows[i].checked && selectedRows[i].type === "checkbox") {
                    
                selectedCons.push({
                        Name: selectedRows[i].value,
                        Id: selectedRows[i].dataset.id,
                });

                recordIds.push(selectedRows[i].dataset.id);
            }
        }

        if (selectedCons.length > 0) {
            this.bShowModal = true;
            this.selectedCons = selectedCons;
            this.recordIds = recordIds;
        } else {
            this.showToast("None row selected!", "Please select at least one row to change the position(s)!!!", "error");
        }

    }

    //função - para carregar as opções do picklist
    loadPicklistValues(fieldApiName) {

        getPicklistValues({
            fieldApiName: fieldApiName
        })
        .then((result) => {

            const options = [{ label: "None", value: "" }];

            result.forEach((value) => {
                options.push({ label: value, value });
            });
    
            if (fieldApiName === "Status__c") {
                this.statusOptions = options;
            } else if (fieldApiName === "Approval_Status__c") {
                this.approvalStatusOptions = options;
            }
        
        })
        .catch((error) =>{
            console.error("Error get values picklist: ", error);
        });
    }

    //função - salvar os registros selecionados
    saveChanges(){

        this.bShowModal = false;
        const approvalStatusValue = this.approvalStatusValue;
        const statusValue = this.statusValue;

        updatePosition({
            ids: this.recordIds,
            approvalStatus: approvalStatusValue,
            status: statusValue
        })
        .then(() => {
            console.log("Success to update records selected.");
            this.showToast("Success to update!", "Sucess to update records selected!", "success");
            setTimeout(() => {this.loadTable()},2000);

        })
        .catch(error => {
            console.error("Error to update records selected: ", error);
            let errorMessage = "Error to update records selected: " + error.statusText;
            this.showToast("Error to update!", errorMessage, "error");
        });
        
    }


    //função - formatar data
    formatDate(dateString) {
        const options = { day: "2-digit", month: "2-digit", year: "numeric" };
        const [month, day, year] = new Date(dateString).toLocaleDateString(undefined, options).split("/");
        return `${day}/${month}/${year}`
    }
    
}
