import { LightningElement } from "lwc";
import getPositionsAvailable from "@salesforce/apex/PositionDAO.getPositionsAvailable";

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
    existingData;
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

            this.existingData = this.filteredData !== "" ? true : false;

        } else {
            this.filteredData = [...this.data];
        }
    }

    //função - quando altera o valor do status chama a função que atualiza a tabela
    handleChange(event) {
        this.selectedStatus = event.detail.value;
        this.filterData(); 
    }
}
