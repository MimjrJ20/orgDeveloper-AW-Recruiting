import { api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import LightningModal from "lightning/modal";
import searchJobByIdCandidateAndInterview from "@salesforce/apex/JobApplicationDAO.searchJobByIdCandidateAndInterview";

export default class CandidateProposeModal extends LightningModal{

    @api idCandidate; 

    @track value;
    @track options = [];

    @track name;
    @track firstName;
    @track lastName;
    @track stateProvince;
    @track country;

    @track skills;
    @track positionName;
    @track department;
    @track accountName;
    @track description;


    //função para gerar o pdf
    handleGeneratePdfClick() {;

        const visualforceUrl = `/apex/CandidatePDF?idCandidate=${this.idCandidate}
                                &name=${this.name}&firstName=${this.firstName}&lastName=${this.lastName}&skills=${this.skills}
                                &stateProvince=${this.stateProvince}&country=${this.country}
                                &positionName=${this.positionName}&description=${this.description}
                                &accountName=${this.accountName}&department=${this.department}`;
        window.open(visualforceUrl, "_blank");
        this.close("okay");
    }

    //função para fechar o modal
    handleNoOkay() {
        this.close("okay");
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

                if (result && result.length > 0) {
                    const candidate = result[0].Candidate__r; 
                    this.name = candidate.Name;
                    this.firstName = candidate.First_Name__c != null ? candidate.First_Name__c : "Candidate";
                    this.lastName = candidate.Last_Name__c != null ? candidate.Last_Name__c : "";
                    this.stateProvince = candidate.State_Province__c != null ? candidate.State_Province__c : "São Paulo";
                    this.country = candidate.Country_List__c != null ? candidate.Country_List__c : "BR - Brazil";
                }

                this.options = result.map(job => ({
                    label: job.Name + " - " + job.Position__r.Name,
                    value: job.Id,
                    jobPositionName: job.Position__r.Name,
                    jobSkills: job.Position__r.Skills_Required__c,
                    jobDepartment: job.Position__r.Department__c,
                    jobAccountName: job.Position__r.Account__r.Name,
                    jobDescription: job.Position__r.Job_Description__c
                
                }));
            })

            .catch((error) => {

                console.log(error);
            });
    }

    //rastrear qual opção foi selecionada
    handleChange(event) {

        this.value = event.detail.value;
        console.log("valor selecionado : " + this.value);

        //buscar o job selecionado com base no this.value
        const selectedJob = this.options.find(job => job.value === this.value);

        if (selectedJob) {

            this.positionName = selectedJob.jobPositionName;
            this.skills = selectedJob.jobSkills != null ? selectedJob.jobSkills : "ALL";
            this.department = selectedJob.jobDepartment != null ? selectedJob.jobDepartment : "TBD";
            this.accountName = selectedJob.jobAccountName != null ? selectedJob.jobAccountName : "TBD";
            this.description = selectedJob.jobDescription != null ? selectedJob.jobDescription : "TBD";
        }
    }


    
}