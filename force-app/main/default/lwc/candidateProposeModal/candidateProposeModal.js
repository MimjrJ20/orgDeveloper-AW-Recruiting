import { api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import LightningModal from "lightning/modal";
import searchJobByIdCandidateAndInterview from "@salesforce/apex/JobApplicationDAO.searchJobByIdCandidateAndInterview";
import updateJobApplicationProposal from "@salesforce/apex/JobApplicationController.updateJobApplicationProposal";
import getCurrentUserName from "@salesforce/apex/UserController.getCurrentUserName";

export default class CandidateProposeModal extends LightningModal{

    @api idCandidate; 

    value;
    options = [];

    //-----------//
    //função para extrair o ID do candidato da UR
    extractIdFromUrl(url) { 

        const parts = url.split("Candidate__c/"); 

        if (parts.length === 2) { 

            const id = parts[1].split("/view")[0]; 
            return id; 
        } 
        return "Erro: Não foi possível obter o id da url."; 
    }

    //-----------//
    //função para fechar o modal
    handleNoOkay() {
        this.close("okay");
    }

    //-----------//
    //função para chamar o pdf
    handleGeneratePdfClick() {

        getCurrentUserName()
        .then(result => {
            const encodedUserName = encodeURIComponent(result);
    
            const visualforceUrl = `/apex/CandidatePDF?idCandidate=${this.idCandidate}`;
            
            //atualiza o status e stage do job
            updateJobApplicationProposal({
                idJob: this.value
            })
            .then(() => {
                this.showToast("Success","Generate proposal and Job status updated successfully.", "success");
                setTimeout(() => {
                    window.open(visualforceUrl, "_blank");
                    this.handleNoOkay();
                    location.reload();
                }, 2000);
            })
            .catch(error => {
                this.showToast("Error","An error occurred while updating job status or generate proposal. Alert your administrator!", "error");
            });
        })
        .catch(error => {
            console.error("Error getting user info: ", error);
        });
    }
    

    //-----------//
    //função
    connectedCallback(){

        const urlId = this.extractIdFromUrl(window.location.href);

        if (!this.urlId) {

            this.idCandidate = urlId;
            console.log("id cadidate: ", this.idCandidate);
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

    //-----------//
    //rastrear qual opção foi selecionada
    handleChange(event) {

        this.value = event.detail.value;
        console.log("valor selecionado : ", this.value);

    }

    //-----------//
    //função para simplificar as chamadas de toast
    showToast(title, message, variant){
        
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(toastEvent);
    }

}