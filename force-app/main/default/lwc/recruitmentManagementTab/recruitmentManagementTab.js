import { LightningElement, track } from "lwc";
import getPositionsAvailable from "@salesforce/apex/PositionDAO.getPositionsAvailable";
import RecruitmentManagementModal from "c/recruitmentManagementModal";
import { ShowToastEvent } from "lightning/platformShowToastEvent";


const columns = [
    { label: "Title", fieldName: "Name" },
    { label: "Account", fieldName: "AccountName" },
    { label: "Approval Status", fieldName: "Approval_Status__c" },
    { label: "Status", fieldName: "Status__c" },
    { label: "Owner", fieldName: "OwnerName" },
];

export default class RecruitmentManagementTab extends LightningElement {

    //variáveis
    data = [];
    columns = columns;
    queryTerm = "";
    filteredData = [];
    selectedStatus = "All";

    //função - seja executado uma vez, para evitar que ele seja executado duas vezes
    connectedCallback() {
        this.loadTable();
    }

    //função - carregar a tabela e obter os dados
    loadTable() {

        //método apex para obter os registros
        getPositionsAvailable({})
            .then((result) => {
                this.data = result.map((row) => ({
                    Id: row.Id,
                    Name: row.Name,
                    AccountName: row.Account__r.Name,
                    Approval_Status__c: row.Approval_Status__c,
                    Status__c: row.Status__c,
                    OwnerName: row.Owner.Name
                }));

                //definindo o valor de filteredData (que são os dados filtrados), sem alterar o data
                this.filteredData = [...this.data];

                //pegando os valores para Status__c no result e passando para uma lista Set para que sejam valores únicos
                const uniqueStatusValues = [...new Set(result.map((row) => row.Status__c))];
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

    //função - verifica se foi pressionado a tecla ENTER e chama a função que filtra a tabela
    handleKeyUp(event) {

        const isEnterKey = event.keyCode === 13;

        if (isEnterKey) {
            this.queryTerm = event.target.value;
            this.filterData();
        }
    }

    //função - filtra a tabela pelo titulo da posição, nome da conta ou status
    filterData() {
        if (this.queryTerm || this.selectedStatus !== "All") {

            const lowerCaseQuery = this.queryTerm.toLowerCase();

            this.filteredData = this.data.filter((row) =>
                (row.Name.toLowerCase().includes(lowerCaseQuery) || row.AccountName.toLowerCase().includes(lowerCaseQuery)) 
                && (this.selectedStatus === "All" || row.Status__c === this.selectedStatus)
            );

        } else {
            this.filteredData = [...this.data];
        }
    }

    //função - quando altera o valor do status chama a função que atualiza a tabela
    handleChange(event) {
        this.selectedStatus = event.detail.value;
        this.filterData(); 
    }


    //função - simplificar as chamadas de toast
    showToast(title, message, variant){
        
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(toastEvent);
    }

    //---------------------//
    //modal filho

    @track isOpenModal;
    @track selectedRows;
    @track selectedRowsIds = [];

    //
    async openModal() {

        const selectedRows = this.template.querySelector('lightning-datatable').getSelectedRows();

        if (selectedRows.length === 0) {

           this.showToast("None row selected","Please select at least one row to change position(s)!","error");

        } else {

            const isOpenModal = await RecruitmentManagementModal.open({
                size: "Small",
                selectedRowsIds: this.selectedRowsIds,
            });
            console.log("Selected IDs: ", this.selectedRowsIds);

            this.isOpenModal = isOpenModal;

            // // Adicionar um listener para quando o modal fechar e limpar os IDs selecionados
            // this.isOpenModal.addEventListener("close", () => {
            //     this.selectedRowsIds = [];
            // });

        }
    
    }


    //
    getSelectedId(event) {

        const selectedRows = event.detail.selectedRows;
    
        if (selectedRows && selectedRows.length > 0) {

            for (let i = 0; i < selectedRows.length; i++) {

                if (selectedRows[i].Id) {
                    console.log("You selected: " + selectedRows[i].Id);
                    this.selectedRowsIds.push(selectedRows[i].Id);
                }
            }

        } else {
            console.log("No rows selected.");
        }
    }
    

}
