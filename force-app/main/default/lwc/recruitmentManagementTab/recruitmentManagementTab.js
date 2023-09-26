// recruitmentManagementTab.js
import { LightningElement, track } from "lwc";
import retrivePositions from "@salesforce/apex/PositionDAO.getPositionsAvailable";

export default class RecruitmentManagementTab extends LightningElement {

    //variáveis
    @track data = [];
    @track filteredData = [];
    @track queryTerm = "";
    @track selectedStatus = "All";
    @track options = [];
    @track bShowModal = false;
    @track selectedCons = [];
    @track value = "All";
    @track rowNumber = 1;

    //função - abrir modal
    openModal() { this.bShowModal = true; }

    //função - fechar modal
    closeModal() {
        this.bShowModal = false;
        this.selectedCons = [];
    }

    //função - seja executado uma vez, para evitar que ele seja executado duas vezes
    connectedCallback() { this.loadTable(); }

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
    handleChange(event) { 
        this.selectedStatus = event.detail.value; 
        this.loadTable();
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

    //função - carregar a tabela e obter os dados
    loadTable() {

        this.rowNumber = 1;

        //método apex para obter os registros
        retrivePositions({
                searchTerm: this.queryTerm,
                selectedStatus: this.selectedStatus})
            .then((result) => {

                result.forEach((item) => {
                    item.rowNumber = this.rowNumber;
                    this.rowNumber++;
                });

                this.data = result;

                //pegando os valores para Status__c no result e passando para uma lista Set para que sejam valores únicos
                const uniqueStatusValues = [
                    ...new Set(result.map((row) => row.Status__c)),
                ];
                this.options = [
                    { label: "All", value: "All" },
                    ...uniqueStatusValues.map((status) => ({
                    label: status,
                    value: status,
                    })),
                ];

                console.log("Result: ", result);
            })
            .catch((error) => {
            console.error("Error loading positions: ", error);
            });
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

    //função - mostrar posições
    showPositions() {
        

        this.bShowModal = true;
        this.selectedCons = [];
        let selectedRows = this.template.querySelectorAll("lightning-input");
    
        //com base na linha selecionada, obtenha os valores da posição
        for (let i = 0; i < selectedRows.length; i++) {
            if (selectedRows[i].checked && selectedRows[i].type === "checkbox") {

                this.selectedCons.push({
                    Name: selectedRows[i].value,
                    Id: selectedRows[i].dataset.id,
                });
            }
        }
    }

    saveChanges(){
        this.bShowModal = false;

    }
}
