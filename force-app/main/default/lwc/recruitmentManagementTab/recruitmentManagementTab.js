import { LightningElement, track } from "lwc";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import retrivePositions from "@salesforce/apex/PositionDAO.getPositionsAvailable";
import updatePosition from "@salesforce/apex/PositionController.updatePosition";
import getPicklistValuesPosition from "@salesforce/apex/PositionDAO.getPicklistValuesPosition";
import getCurrentUserProfileId from "@salesforce/apex/UserController.getCurrentUserProfileId";
import getProfileName from "@salesforce/apex/UserController.getProfileName";
import getCurrentUserId from "@salesforce/apex/UserController.getCurrentUserId";
import getCurrentUserName from "@salesforce/apex/UserController.getCurrentUserName";
import getUsers from "@salesforce/apex/UserController.getUsers";
import getUserName from "@salesforce/apex/UserController.getUserName";
import getQueues from "@salesforce/apex/UserController.getQueues";
import sendEmail from "@salesforce/apex/SendNotification.sendEmail";
import createNotifications from "@salesforce/apex/SendNotification.createNotifications";


export default class RecruitmentManagementTab extends LightningElement {

    //--------------------------------------------------------------
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
    @track emails = [];
    @track pageSizeOptions = []; 
    @track recordsToDisplay = []; 
    @track pageSizeOptionsModal = []; 
    @track recordsToDisplayModal = []; 

    @track queryTerm = "";    
    @track approvalStatusValue = "";
    @track statusValue = "";
    @track ownerValue = "";
    @track selectedStatus = "All";
    @track selectedOwner = "All";
    @track statusValueTable = "All";
    @track ownerValueTable = "All";
    @track headerPagination = "Showing ";
    @track headerPaginationModal;

    @track rowNumber;
    @track idProfile;
    @track nameProfile;
    @track idUser;
    @track nameUser;
    @track titleOwner;
    @track nameManager;
    @track pageSize;
    @track totalPages;
    @track pageValueTable;
    @track pageSizeModal;
    @track totalPagesModal;
    @track pageValueTableModal;

    @track bShowModal = false;
    @track disableOptions = false;
    @track profileHumanResource = false;
    @track disableOwner = false;
    @track selectAll = false;
    @track hasRefresh = false;
    @track disableSave = true;
    @track isLoaded = false;

    @track selectedCount = 0;
    @track totalRecords = 0;
    @track pageNumber = 1; 
    @track totalRecordsModal = 0;
    @track pageNumberModal = 1; 


    //--------------------------------------------------------------
    //funções

    //-----------------------------------------
    //funções geral

    //função - seja executado uma vez, para evitar que ele seja executado duas vezes
    connectedCallback() { 
        this.loadPageOptions();
        this.loadTable(); 
        this.loadPageOptionsModal();
        this.loadPicklistValues("Status__c");
        this.loadPicklistValues("Approval_Status__c");
        this.loadUsers();
    }

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

                const hasOwner = this.ownerValue !== "" ? true : false;

                console.log("Success to update records selected.");
                this.showToast("Success to update!", "Sucess to update records selected!", "success");
                
                if (hasOwner) {

                    //enviar notificação
                    createNotifications({
                        ownerId: this.ownerValue,
                        targetIds: this.recordIds
                    })
                    .then(() => {
                        console.log("Success to send notifications records selected.");
                    })
                    .catch((error) =>{
                        console.error("Error to create notification: ", error);    
                    })

                    //enviar email
                    sendEmail({
                        ownerId: this.ownerValue,
                        recordIds: this.recordIds
                    })
                    .then(() =>{
                        this.showToast("E-mail sended!", "Sucess to send emails!", "success");
                    })
                    .catch((error) => {

                        let errorMessage = "Error to send e-mail: ";
                        if (error.body.message) {
                            errorMessage += error.body.message;
                        } else {
                            errorMessage += "Unknown error"; 
                        }
                        console.error("Error to send e-mail: ", error);
                        this.showToast("Error to send e-mail!", errorMessage, "error");
                    })
                }
                this.selectAll = false; 
                this.closeModal();
                this.loadTable();
                
            })
            .catch(error => {

                console.error("Error to update records selected: ", error);
                let errorMessage = "Error to update records selected: ";
                if (error.body.pageErrors && error.body.pageErrors.length > 0) {
                    errorMessage += error.body.pageErrors[0].message;
                } else {
                    errorMessage += "Unknown error"; 
                }
                this.showToast("Error to update!", errorMessage, "error");

            });
        })
        .catch(error => {
            console.error("Error get Id user: ", error);
        });
    }

    //função - fechar modal
    closeModal() {
        this.bShowModal = false;
        this.disableSave = true;
        this.selectedCons = [];
        this.recordIds = [];
        this.approvalStatusValue = "";
        this.statusValue = "";
        this.ownerValue = "";
        this.selectedCount = 0;
    }  

    //função - paginação voltar uma página
    previousPage() {
        this.pageNumber = this.pageNumber - 1;
        this.paginationHelper();
    }

    //função - paginação avançar uma página
    nextPage() {
        this.pageNumber = this.pageNumber + 1;
        this.paginationHelper();
    }

    //função - paginação ir para a primeira página    
    firstPage() {
        this.pageNumber = 1;
        this.paginationHelper();
    }

    //função - paginação ir para a última página
    lastPage() {
        this.pageNumber = this.totalPages;
        this.paginationHelper();
    }

    //função - paginação voltar uma página do modal
    previousPageModal() {
        this.pageNumberModal = this.pageNumberModal - 1;
        this.paginationHelperModal();
    }

    //função - paginação avançar uma página do modal
    nextPageModal() {
        this.pageNumberModal = this.pageNumberModal + 1;
        this.paginationHelperModal();
    }

    //função - paginação ir para a primeira página do modal   
    firstPageModal() {
        this.pageNumberModal = 1;
        this.paginationHelperModal();
    }

    //função - paginação ir para a última página do modal 
    lastPageModal() {
        this.pageNumberModal = this.totalPagesModal;
        this.paginationHelperModal();
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

    //-----------------------------------------
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
    
    //função - chama a função loadTable sempre que o campo de pesquisa é atualizado
    handleInput(event) {
        this.queryTerm = event.target.value;
        this.loadTable();
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

    //função - quando altera o valor do select Approval Status dentro do modal
    handleChangeApprovalStatus(event) {
        this.approvalStatusValue = event.target.value;
        this.disableButtonSave();
    }
    
    //função - quando altera o valor do select Status dentro do modal
    handleChangeStatus(event) {
        this.statusValue = event.target.value;
        this.disableButtonSave();
    }

    //função - quando altera o valor do select Owner dentro do modal
    handleChangeOwner(event) {
        this.ownerValue = event.target.value;
        this.disableButtonSave();
    }

    //função - desabilitar o botão 'Save' 
    disableButtonSave() {
        if (this.approvalStatusValue === "" && this.statusValue === "" && this.ownerValue === "") {
            this.disableSave = true;
        } else {
            this.disableSave = false;
        }
    }

    //função - selecionar todas as linhas
    allSelected(event) {

        this.selectAll = event.target.checked; //boolean
    
        //map percorre esse array e, para cada item (linha de dados)
        this.recordsToDisplay = this.recordsToDisplay.map((item) => {

            //se o checkbox para todos for selecionados então os individuais é marcado como true, o mesmo para false quando estiver desmarcado
            item.selected = this.selectAll; //boolean
            return item;
        });

    }
    
    //função - para desmarcar as linhas
    handleIndividualCheckboxChange(event) {

        //obter o id do item selecionando
        const itemId = event.target.dataset.id;
    
        this.data = this.data.map((item) => {
            //verifica se o id do item da lista é igual ao id do item selecionado
            if (item.Id === itemId) {
                item.selected = event.target.checked; //boolean
            }
            return item;
        });

        //se todos os itens tiverem a propriedade "selected" como true, a variável selectAll também é definida como true.
        //every = verifica se TODOS os elementos de um array atendem a true e retorna true
        this.selectAll = this.data.every((item) => item.selected);
        this.selectedCount = 0;
    }

    //função - para rastrear a alteração da paginação
    handleRecordsPerPage(event) {
        this.pageValueTable = parseInt(event.detail.value, 10);
        this.pageSize = this.pageValueTable;
        this.pageNumber = 1;
        this.paginationHelper();
    }

    //função - para rastrear a alteração da paginação do modal
    handleRecordsPerPageModal(event) {
        this.pageValueTableModal = parseInt(event.detail.value, 10);
        this.pageSizeModal = this.pageValueTableModal;
        this.pageNumberModal = 1;
        this.paginationHelperModal();
    }

    //-----------------------------------------
    //funções carregar

    //função - carregar a tabela e obter os dados
    loadTable() {

        this.rowNumber = 1;
        this.isLoaded = true;

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
                                const uniqueStatusValues = [...new Set(result.map((row) => row.Status__c))];

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
                                    const currentUserOption = { label: this.nameUser, value: this.idUser };
                                    this.ownerOptionsTable.push(currentUserOption);
                                    this.selectedOwner = this.idUser;
                                    this.ownerValueTable = this.idUser;                            
                                })
                                .catch((error) => {
                                    console.error("Error loading user name: ", error);
                                });

                                this.totalRecords = result.length;
                                const firstPageSizeOption = this.pageSizeOptions[0].value;
                                this.pageValueTable = firstPageSizeOption;
                                this.pageSize = firstPageSizeOption; 
                                this.pageNumber = 1;
                                this.paginationHelper();  
                                this.isLoaded = false;
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

                            this.totalRecords = result.length;
                            const firstPageSizeOption = this.pageSizeOptions[0].value;
                            this.pageValueTable = firstPageSizeOption;
                            this.pageSize = firstPageSizeOption; 
                            this.pageNumber = 1;
                            this.paginationHelper();  
                            this.isLoaded = false;
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
        this.isLoaded = true;
        this.queryTerm = "";
        this.selectedStatus = "All";
        this.selectedOwner = "All";
        this.hasRefresh = true;
        this.selectAll = false; 
        this.loadTable();
    }

    //função - para destravar o filtro na tabela
    editFilters() {
        this.hasRefresh = false;
    }

    //função - calcula as paginações
    paginationHelper() {
        this.recordsToDisplay = [];
        this.selectAll = false;
        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);

        if (this.totalPages === 1) {
            this.headerPagination = "Showing " + this.pageNumber + " of " + this.totalPages + " Page";
        } else {
            this.headerPagination = "Showing " + this.pageNumber + " of " + this.totalPages + " Pages";
        }

        if (this.pageNumber <= 1) {
            this.pageNumber = 1;
        } else if (this.pageNumber >= this.totalPages) {
            this.pageNumber = this.totalPages;
        }

        for (let i = (this.pageNumber - 1) * this.pageSize; i < this.pageNumber * this.pageSize; i++) {
            if (i === this.totalRecords) {
                break;
            }
            this.recordsToDisplay.push(this.data[i]);
        }
    }

    //função - calcula as paginações do modal
    paginationHelperModal() {
        this.recordsToDisplayModal = [];
        this.totalPagesModal = Math.ceil(this.totalRecordsModal / this.pageSizeModal);

        if (this.totalPagesModal === 1) {
            this.headerPaginationModal = this.pageNumberModal + " of " + this.totalPagesModal + " Page";
        } else {
            this.headerPaginationModal = this.pageNumberModal + " of " + this.totalPagesModal + " Pages";
        }

        if (this.pageNumberModal <= 1) {
            this.pageNumberModal = 1;
        } else if (this.pageNumberModal >= this.totalPagesModal) {
            this.pageNumberModal = this.totalPagesModal;
        }

        for (let i = (this.pageNumberModal - 1) * this.pageSizeModal; i < this.pageNumberModal * this.pageSizeModal; i++) {
            
            if (i === this.totalRecordsModal) {
                break;
            }
            if (this.selectedCons[i].Name) {
                this.recordsToDisplayModal.push(this.selectedCons[i]);
            }
            
        }
    }

    //função - abrir modal e mostrar positions
    showPositions() {

        this.rowNumber = 1;

        const selectedRows = this.template.querySelectorAll("lightning-input");
        const selectedCons = [];
        const recordIds = [];
        
        for (let i = 0; i < selectedRows.length; i++) {
            if (selectedRows[i].checked && selectedRows[i].type === "checkbox") {

                if (selectedRows[i].value) {
                    selectedCons.push({
                        Name: selectedRows[i].value,
                        Id: selectedRows[i].dataset.id,
                    });
                }
               
                const recordId = selectedRows[i].dataset.id;
                if (recordId) {
                    recordIds.push(recordId);
                }
            }
        }

        if (selectedCons.length > 0) {

            const selectedCount = selectedCons.length;
            const firstPageSizeOption = this.pageSizeOptionsModal[0].value;

            this.bShowModal = true;
            this.selectedCons = selectedCons;
            this.recordIds = recordIds;
            this.selectedCount += selectedCount;
            this.totalRecordsModal = selectedCons.length;
            this.pageValueTableModal = firstPageSizeOption;
            this.pageSizeModal = firstPageSizeOption; 
            this.pageNumberModal = 1;
            this.paginationHelperModal();  

        } else {
            this.showToast("None row selected!", "Please select at least one row to change the position(s)!!!", "error");
        }
    }

    //função - carregar os usuários disponiveis e colocar na lista de opções
    loadUsers(){

        getUsers({})
        .then((result) => {

            const options = [{ label: "None", value: "" }];

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

            const options = this.ownerOptions;

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

        getPicklistValuesPosition({
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

    //função - carrega os valores para o tamanho de cada página da tabela
    loadPageOptions(){
        this.pageSizeOptions = [5, 10, 25, 50, 75, 100].map(option => ({ label: option.toString(), value: option }));
    }

    //função - carrega os valores para o tamanho de cada página da tabela do modal
    loadPageOptionsModal(){
        this.pageSizeOptionsModal = [5, 10].map(option => ({ label: option.toString(), value: option }));
    }
    
    //-----------------------------------------
    //funções formatar

    //função - formatar data
    formatDate(dateString) {
        const options = { day: "2-digit", month: "2-digit", year: "numeric" };
        const [month, day, year] = new Date(dateString).toLocaleDateString(undefined, options).split("/");
        return `${day}/${month}/${year}`
    }

    //função - formatar primeira constra de cada palavra para maiuscula
    capitalizeWords(wordsString) {
        return wordsString
            .toLowerCase()
            .split(" ")
            .map(word => word.charAt(0).toUpperCase() + word.slice(1))
            .join(" ");
    }

    //--------------------------------------------------------------
    //get e set

    //get - desabilita o botão first da paginação
    get getDisableFirst() {
        return this.pageNumber === 1;
    }

    //get - desabilita o botão last da paginação
    get getDisableLast() {
        return this.pageNumber === this.totalPages;
    }

    //get - texto para total de registros na tabela
    get totalRecordsBadgeLabel() {
        return "Total Records: " + this.totalRecords;
    }

    //get - desabilita o botão first da paginação do modal
    get getDisableFirstModal() {
        return this.pageNumberModal === 1;
    }

    //get - desabilita o botão last da paginação do modal
    get getDisableLastModal() {
        return this.pageNumberModal === this.totalPagesModal;
    }

    //get - texto para total de registros na tabela do modal
    get totalRecordsBadgeLabelModal() {
        return "Total Records: " + this.totalRecordsModal;
    } 
}
