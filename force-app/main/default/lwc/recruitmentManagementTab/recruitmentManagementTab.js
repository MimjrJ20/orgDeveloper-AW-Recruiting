import { LightningElement, track } from "lwc";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import retrivePositions from "@salesforce/apex/PositionDAO.getPositionsAvailable";
import updatePosition from "@salesforce/apex/PositionController.updatePosition";
import getPicklistValues from "@salesforce/apex/PositionDAO.getPicklistValues";
import getCurrentUserProfileId from "@salesforce/apex/UserController.getCurrentUserProfileId";
import getProfileName from "@salesforce/apex/UserController.getProfileName";
import getCurrentUserId from "@salesforce/apex/UserController.getCurrentUserId";
import getCurrentUserName from "@salesforce/apex/UserController.getCurrentUserName";
import getUsers from "@salesforce/apex/UserController.getUsers";
import getUserName from "@salesforce/apex/UserController.getUserName";
import getQueues from "@salesforce/apex/UserController.getQueues";
import sendEmail from "@salesforce/apex/SendNotification.sendEmail";


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
    @track idUser;
    @track nameUser;
    @track titleOwner;
    @track nameManager;

    @track bShowModal = false;
    @track disableOptions = false;
    @track profileHumanResource = false;
    @track disableOwner = false;


    //-----------------
    //funções


    //--------
    //funções geral
    //função - fechar modal
    closeModal() {
        this.bShowModal = false;
        this.selectedCons = [];
        this.recordIds = [];
        this.approvalStatusValue = "";
        this.statusValue = "";
        this.ownerValue = "";
    }
    
    //função - simplificar as chamadas de toast
    showToast(title, message, variant) {
        let toastEvent = new ShowToastEvent({
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
        this.loadUsers();
    }

    //--------
    //funções de evento

    //função - verifica se foi pressionada a tecla ENTER e chama a função que filtra a tabela
    handleKeyUp(event) {
        let isEnterKey = event.keyCode === 13;

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

    //função - selecionar todas as linhas
    allSelected(event) {
    
        let selectedRows = this.template.querySelectorAll("lightning-input");

        for (let i = 0; i < selectedRows.length; i++) {
            if (selectedRows[i].type === "checkbox") {
                selectedRows[i].checked = event.target.checked;
            }
        }
    }

    //--------
    //funções carregar

    //função - carregar a tabela e obter os dados
    loadTable() {

        this.rowNumber = 1;

        getCurrentUserProfileId({})
        .then((profileId) => {
            this.idProfile = profileId;
            return getProfileName({ id: this.idProfile });
        })
        .then((profileName) => {

            this.nameProfile = profileName;

            if (this.nameProfile === "Human Resources") {
                this.profileHumanResource = true;
                this.disableOptions = true;
                this.disableOwner = false;
                this.titleOwner = "You can only access positions associated with your name";

                getCurrentUserId({})
                .then((userId) => {
                    this.idUser = userId;
                    return retrivePositions({
                        searchTerm: this.queryTerm,
                        selectedStatus: this.selectedStatus,
                        selectedOwner: this.selectedOwner,
                        profileHumanResource: this.profileHumanResource,
                        idUser: this.idUser
                    });
                    })
                    .then((result) => {
                        return Promise.all(result.map(item => 
                            getUserName({ id: item.Hiring_Manager__c })))
                            .then(managerNames => {
                                result.forEach((item, index) => {
                                    item.rowNumber = this.rowNumber;
                                    this.rowNumber++;
                                    item.CreatedDate = this.formatDate(item.CreatedDate);
                                    item.LastModifiedDate = this.formatDate(item.LastModifiedDate);
                                    item.Location__c = item.Location__c || "N/A";
                                    item.nameManager = managerNames[index];
                                });

                                this.data = result;
                                
                                //pegando os valores para Status__c no result e passando para uma lista Set para que sejam valores únicos
                                let uniqueStatusValues = [...new Set(result.map((row) => row.Status__c))];

                                this.statusOptionsTable = [
                                    { label: this.statusValueTable, value: this.statusValueTable },
                                    ...uniqueStatusValues.map((status) => ({
                                        label: status,
                                        value: status
                                    }))
                                ];

                                getCurrentUserName({})
                                .then((userName) => {

                                    this.nameUser = userName;
                                    this.ownerOptionsTable = [];
                                    let currentUserOption = { label: this.nameUser, value: this.idUser };
                                    this.ownerOptionsTable.push(currentUserOption);
                                    this.selectedOwner = this.idUser;
                                    this.ownerValueTable = this.idUser;
                            
                                })
                                .catch((error) => {
                                    console.error("Error loading user name: ", error);
                                });
                            });
                    })
                    .catch((error) => {
                        console.error("Error loading positions: ", error);
                    });

            } else {
                this.titleOwner = "Please, select one owner or 'all'";
                this.disableOwner = true;

                retrivePositions({
                    searchTerm: this.queryTerm,
                    selectedStatus: this.selectedStatus,
                    selectedOwner: this.selectedOwner,
                    profileHumanResource: this.profileHumanResource,
                    idUser: this.idUser
                })
                .then((result) => {
                    return Promise.all(result.map(item => 
                        getUserName({ id: item.Hiring_Manager__c })))
                        .then(managerNames => {
                            result.forEach((item, index) => {
                                item.rowNumber = this.rowNumber;
                                this.rowNumber++;
                                item.CreatedDate = this.formatDate(item.CreatedDate);
                                item.LastModifiedDate = this.formatDate(item.LastModifiedDate);
                                item.Location__c = item.Location__c || "N/A";
                                item.nameManager = managerNames[index];
                            });

                            this.data = result;

                            //pegando os valores para Status__c no result e passando para uma lista Set para que sejam valores únicos
                            let uniqueStatusValues = [...new Set(result.map((row) => row.Status__c))];

                            this.statusOptionsTable = [
                                { label: this.statusValueTable, value: this.statusValueTable },
                                ...uniqueStatusValues.map((status) => ({
                                    label: status,
                                    value: status
                                }))
                            ];

                            //pegando os valores para Owner no result e passando para uma lista Set para que sejam valores únicos
                            let uniqueOwnerValues = [...new Set(result.map((row) => row.OwnerId))];
                            let ownerNamesMap = new Map();
                            
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
                        });
                })
                .catch((error) => {
                    console.error("Error loading positions: ", error);
                });
            }
        })
        .catch((error) => {
            console.error("Error loading profile id: ", error);
        });
    }

    //função - para refresh
    loadTableRefresh() {
        this.queryTerm = "";
        this.selectedStatus = "All";
        this.selectedOwner = "All";
        this.loadTable();
    }


    //função - abrir modal e mostrar positions
    showPositions() {

        this.rowNumber = 1;

        let selectedRows = this.template.querySelectorAll("lightning-input");
        let selectedCons = [];
        let recordIds = [];

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

    //função - carregar os usuários disponiveis e colocar na lista de opções
    loadUsers(){

        getUsers({})
        .then((result) => {

            let options = [{ label: "None", value: "" }];

            result.forEach((row) => {
                row.Name = this.capitalizeWords(row.Name);
                options.push({
                    label: row.Name,
                    value: row.Id
                });
            });

            this.ownerOptions = options;
        })
        .catch((error) => {
            console.error("Error loading users: ", error);
        });    

        getQueues({})
        .then((result) => {

            let options = this.ownerOptions;

            result.forEach((row) => {
                row.Name = this.capitalizeWords(row.Name);
                options.push({
                    label: row.Name,
                    value: row.Id
                });
            });
        })
        .catch((error) => {
            console.error("Error loading queues: ", error);
        });  
    }

    //função - para carregar as opções do picklist
    loadPicklistValues(fieldApiName) {

        getPicklistValues({
            fieldApiName: fieldApiName
        })
        .then((result) => {

            let options = [{ label: "None", value: "" }];

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

    //--------
    //funções salvar

    //função - salvar os registros selecionados
    saveChanges(){

        this.bShowModal = false;

        getCurrentUserId({})
        .then((userId) =>{

            this.idUser = userId;

            updatePosition({
                ids: this.recordIds,
                approvalStatus: this.approvalStatusValue,
                status: this.statusValue,
                owner: this.ownerValue,
                user: this.idUser
            })
            .then(() => {
                
                console.log("Success to update records selected.");
                this.showToast("Success to update!", "Sucess to update records selected!", "success");
                this.closeModal();
                this.loadTable();
                
                sendEmail({
                    emails: "michele.jeniffer.mr@gmail.com",
                    titlesPositions: this.recordIds
                })
                .then(() =>{

                })
            })
            .catch(error => {
                console.error("Error to update records selected: ", error);
                let errorMessage = "Error to update records selected: " + error.statusText;
                this.showToast("Error to update!", errorMessage, "error");
            });
        })
        .catch(error => {
            console.error("Error get Id user: ", error);
        });
    }

    //--------
    //funções formatar

    //função - formatar data
    formatDate(dateString) {
        let options = { day: "2-digit", month: "2-digit", year: "numeric" };
        let [month, day, year] = new Date(dateString).toLocaleDateString(undefined, options).split("/");
        return `${day}/${month}/${year}`
    }

    //função - formatar primeira letra de cada palavra para maiuscula
    capitalizeWords(wordsString) {
        return wordsString
            .toLowerCase()
            .split(' ')
            .map(word => word.charAt(0).toUpperCase() + word.slice(1))
            .join(' ');
    }
 
}
