import { api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import LightningModal from "lightning/modal";
import searchJobByIdCandidateAndInterview from "@salesforce/apex/JobApplicationDAO.searchJobByIdCandidateAndInterview";
import updateJobApplicationProposal from "@salesforce/apex/JobApplicationController.updateJobApplicationProposal";
import getCurrentUserName from "@salesforce/apex/UserController.getCurrentUserName";
import savePDFCandidate from "@salesforce/apex/CandidatePDFController.savePDFCandidate";
import generatePDFContent from "@salesforce/apex/CandidatePDFController.generatePDFContent";

export default class CandidateProposeModal extends LightningModal{

    @api idCandidate; 

    //variaveis para seleção do Job no modal value é o id e options a lista que retorna com as opções de job para aquele candidato
    value;
    options = [];

    //variaveis para tags do html condicional
    isEmptyOptions = false;
    isNotEmptyOptions = false;

    //variaveis para salvar o pdf
    pdfBody;
    jobName;

    //variaveis para gerar o pdf
    city;
    state;
    country;
    candidateNumber;
    candidateName;
    positionName;
    accountName;
    description;
    skills;
    department;
    startDate;
    salary;
    manager;
    deadline;
    userName;

    //-----------//
    //função para fechar o modal
    handleNoOkay() {
        this.close("okay");
    }

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
    //rastrear qual opção foi selecionada
    handleChange(event) {
        this.value = event.detail.value;
    }

    //-----------//
    // Método para chamar o Apex para salvar o PDF
    savePDF() {

        savePDFCandidate({
            idCandidate: this.idCandidate,
            pdfBody: this.pdfBody,
            jobName: this.jobName            
        })        
        .then(() => {
            location.reload();
            console.log("PDF saved successfully.");

        })
        .catch(error => {
            console.error("Error saving PDF: ", error);
        });
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

    //-----------//
    //função para clicar no botã  do 'generate' pdf
    handleGeneratePdfClick() {

        //retorna o nome do usuário que clica no botão
        getCurrentUserName()
        .then((result) => {
            this.userName = result;
        })
        .catch(error => {
            console.error("Error get userName: ", error);
        });

        //atualiza o status e stage do job
        updateJobApplicationProposal({
            idJob: this.value
        })
        .then((result) => {
            this.jobName = result.jobName;
            this.city = result.city;
            this.state = result.state;
            this.country = result.country;
            this.candidateNumber = result.candidateNumber;
            this.candidateName = result.candidateName;
            this.positionName = result.positionName;
            this.accountName = result.accountName;
            this.description = result.description;
            this.skills = result.skills;
            this.department = result.department;
            this.startDate = result.startDate;
            this.salary = result.salary;
            this.manager = result.manager;
            this.deadline = result.deadline;

            this.showToast("Success","Proposal saved and Job status updated successfully.", "success");

            //um tempo para carregar a página e salvar o pdf
            setTimeout(() => {

                //gerar o pdf com as infos pertinentes
                generatePDFContent({ 
                    candidateId: this.idCandidate,
                    city: this.city,
                    state: this.state,
                    country: this.country,
                    candidateNumber: this.candidateNumber,
                    candidateName: this.candidateName,
                    positionName: this.positionName,
                    accountName: this.accountName,
                    description: this.description,
                    skills: this.skills,
                    department: this.department,
                    startDate: this.startDate,
                    salary: this.salary,
                    manager: this.manager,
                    deadline: this.deadline,
                    userName: this.userName
                })
                .then((result) => {
                    this.pdfBody = result;
                    this.savePDF();
                })
                .catch((error) => {
                    console.error("Error generating PDF: ", error);
                });

                this.handleNoOkay();

            }, 2000);

        })
        .catch(error => {
            this.showToast("Error","An error occurred while updating job status or generate proposal. Alert your administrator!", "error");
            console.error("Error update job: ", error);
        });
    }
    
    //-----------//
    //função que faz a busca do Job
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

                if(result != null && result.length > 0){

                    this.isEmptyOptions = false;
                    this.isNotEmptyOptions = true;

                } else {

                    this.isEmptyOptions = true;
                    this.isNotEmptyOptions = false;

                }
            })
            .catch((error) => {
                console.log(error);
            });
    }  
}