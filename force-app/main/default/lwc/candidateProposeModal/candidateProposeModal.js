import { api} from "lwc";
import LightningModal from "lightning/modal";
import searchJobByIdCandidateAndInterview from "@salesforce/apex/JobApplicationDAO.searchJobByIdCandidateAndInterview";



export default class CandidateProposeModal extends LightningModal{

    @api idCandidate; 
    value;
    options = [];

    //função para gerar o pdf
    handleGeneratePdfClick() {

        const urlId = this.extractIdFromUrl(window.location.href);

        window.open('/apex/CandidatePDF?idCandidate=' + urlId);

        this.close("cancel");
    }

    //função para fechar o modal
    handleNoOkay() {
        this.close("cancel");
    }

    //função para extrair o ID do candidato da UR
    extractIdFromUrl(url) { 

        const parts = url.split("Candidate__c/"); 

        if (parts.length === 2) { 

            const id = parts[1].split("/view")[0]; 
            return id; 
        } 
        return "Erro - Não foi possível obter o id da url."; 
    }


    connectedCallback(){

        const urlId = this.extractIdFromUrl(window.location.href);

        if (!this.urlId) {

            this.idCandidate = urlId;
            console.log("id cadidate: " + this.idCandidate);
        }

        //chama a função no Apex para buscar os registros de job associados ao candidato
        searchJobByIdCandidateAndInterview({ 

            //criando um objeto com um campo idCandidate e atribuindo a ele o valor da propriedade idCandidate do componente LWC
            idCandidate: this.idCandidate })

            .then((result) => {

                this.options = result.map(job => ({
                    label: job.Name + " - " + job.Position__r.Name,
                    value: job.Id
                
                }));
            })

            .catch((error) => {

                console.log(error);
            });

            
    }

    // rastrear qual opção foi selecionada
    handleChange(event) {
        this.value = event.detail.value;
        console.log("valor selecionado : " + this.value);
    }


    
}