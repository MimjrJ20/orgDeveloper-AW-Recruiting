import { LightningElement, track, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import getPositionById from "@salesforce/apex/PositionDAO.getPositionById";
import getCandidateByCPF from "@salesforce/apex/CandidateDAO.getCandidateByCPF";
import getJobByIdCandidateAndPosition from "@salesforce/apex/JobApplicationDAO.getJobByIdCandidateAndPosition";
import getPicklistValuesCandidate from "@salesforce/apex/CandidateDAO.getPicklistValuesCandidate";
import createJobApplication from "@salesforce/apex/JobApplicationController.createJobApplication";
import createCandidate from "@salesforce/apex/CandidateController.createCandidate";

export default class CommunityButtonApplyJob extends LightningElement {
  @track bShowModalApply = false;
  @track bShowModalCandidateYes = false;
  @track bShowModalCandidateNot = false;
  @track bShowModalCandidateApply = false;

  @track cpfValue;
  @track cpfValueNotMask;

  @track idPosition;
  @track namePosition;
  @track informationPosition;

  @track idCandidate;
  @track candidate;
  @track nameCandidate;
  @track firstNameValue;
  @track lastNameValue;
  @track emailValue;
  @track countryValue = "BR - Brazil";
  @track skillsValue = "";

  @track minCEP = "8";
  @track maxCEP = "8";

  @track jobApplicationExisting = [];
  @track countryListOptions = [];

  @track progressCurrentStep = "1";
  @track progressHasError = false;

  @track disableSave = true;

  @api buttonText;

  connectedCallback() {
    this.loadPicklistValues("Country_List__c");
  }

  //função - simplificar as chamadas de toast
  showToast(title, variant, message) {
    const toastEvent = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(toastEvent);
  }

  handleChangeFirstName(event) {
    this.firstNameValue = event.detail.value;
    this.disableButtonSave();
  }

  handleChangeLastName(event) {
    this.lastNameValue = event.detail.value;
    this.disableButtonSave();
  }

  handleChangeEmail(event) {
    this.emailValue = event.detail.value;
    this.disableButtonSave();
  }

  handleChangeCountry(event) {
    this.countryValue = event.detail.value;
    if (this.countryValue === "BR - Brazil") {
      this.minCEP = "8";
      this.maxCEP = "8";
    } else {
      this.cepValue = "";
      this.minCEP = "0";
      this.maxCEP = "0";
    }
  }

  handleChangeCEP(event) {
    this.cepValue = event.detail.value;
  }

  handleChangeSkills(event) {
    this.skillsValue = event.detail.value;
  }

  //função - desabilitar o botão 'Save'
  disableButtonSave() {
    if (!this.firstNameValue || !this.lastNameValue || !this.emailValue) {
      this.disableSave = true;
    } else {
      this.disableSave = false;
    }
  }

  clickApply() {
    this.bShowModalApply = true;
    this.progressCurrentStep = 1;

    const id = this.extractIdFromUrl(window.location.href);

    if (id != null) {
      this.idPosition = id;
    }

    getPositionById({ id: this.idPosition })
      .then((result) => {
        this.namePosition = "Position: " + result.Name;
        this.informationPosition =
          result.Job_Information__c != null
            ? "More information: " + result.Job_Information__c
            : "N/A";
      })
      .catch((error) => {
        console.error("Error getPositionById: ", error);
      });
  }

  backModal() {
    this.bShowModalApply = true;
    this.bShowModalCandidateYes = false;
    this.bShowModalCandidateNot = false;
    this.bShowModalCandidateApply = false;
  }

  closeModal() {
    this.bShowModalApply = false;
    this.bShowModalCandidateYes = false;
    this.bShowModalCandidateNot = false;
    this.bShowModalCandidateApply = false;
    this.progressCurrentStep = "1";
    this.progressHasError = false;
    this.disableSave = true;
  }

  saveChanges() {
    this.progressCurrentStep = "3";
    this.cpfValueNotMask = this.removeCPFMask(this.cpfValue);

    createCandidate({
      cpf: this.cpfValueNotMask,
      firstName: this.firstNameValue,
      lastName: this.lastNameValue,
      email: this.emailValue,
      country: this.countryValue,
      cep: this.cepValue
    })
      .then((candidate) => {
        console.log("Candidate created.");
        this.candidate = candidate;
        this.idCandidate = candidate.Id;

        createJobApplication({
          idCandidate: this.idCandidate,
          idPosition: this.idPosition,
          skillsCandidate: this.skillsValue
        })
          .then(() => {
            console.log("Job Application created.");
            this.showToast("Success", "success", "Job applied successfully!");
          })
          .catch((error) => {
            this.progressHasError = true;
            console.error("Error createJobApplication: ", error);
          });
      })
      .catch((error) => {
        this.progressHasError = true;
        console.error("Error createJobApplication: ", error);
      });

    this.closeModal();
  }

  applyChanges() {
    this.progressCurrentStep = "3";

    createJobApplication({
      idCandidate: this.idCandidate,
      idPosition: this.idPosition,
      skillsCandidate: ""
    })
      .then(() => {
        console.log("Job Application created.");
        this.showToast("Success", "success", "Job applied successfully!");
      })
      .catch((error) => {
        console.error("Error createJobApplication: ", error);
      });

    this.closeModal();
  }

  continueChanges() {
    this.bShowModalApply = false;
    this.progressCurrentStep = "2";

    if (this.cpfValue) {
      this.cpfValueNotMask = this.removeCPFMask(this.cpfValue);

      getCandidateByCPF({ cpf: this.cpfValueNotMask })
        .then((candidate) => {
          this.candidate = candidate;
          this.idCandidate = candidate.Id;
          this.nameCandidate =
            candidate.First_Name__c + " " + candidate.Last_Name__c;

          getJobByIdCandidateAndPosition({
            idCandidate: this.idCandidate,
            idPosition: this.idPosition
          })
            .then((job) => {
              this.jobApplicationExisting = job;

              if (this.jobApplicationExisting.length > 0) {
                this.bShowModalCandidateApply = true;
                this.progressCurrentStep = "3";
                this.progressHasError = false;
              } else {
                this.bShowModalCandidateNot = true;
              }
            })
            .catch((error) => {
              this.progressHasError = true;
              console.error("Error getJobByIdCandidateAndPosition: ", error);
            });
        })
        .catch((error) => {
          this.bShowModalCandidateYes = true;
          this.progressHasError = true;
          console.error("Error getCandidateByCPF: ", error);
        });
    }
  }

  handleKeyDown(event) {
    if (event.key.match(/[^0-9]/)) {
      event.preventDefault();
    }
  }

  handleChangeCPF(event) {
    const value = event.target.value.replace(/\D/g, "");
    this.cpfValue = this.includeCPFMask(this.cpfValue, value);
  }

  //função - para carregar as opções do picklist
  loadPicklistValues(fieldApiName) {
    getPicklistValuesCandidate({
      fieldApiName: fieldApiName
    })
      .then((result) => {
        const options = [];
        result.forEach((value) => {
          options.push({ label: value, value });
        });

        if (fieldApiName === "Country_List__c") {
          this.countryListOptions = options;
        }
      })
      .catch((error) => {
        console.error("Error get values picklist: ", error);
      });
  }

  includeCPFMask(cpfNotMask, value) {
    if (value.length > 3) {
      cpfNotMask = value.substring(0, 3) + "." + value.substring(3);
    }
    if (value.length > 6) {
      cpfNotMask =
        value.substring(0, 3) +
        "." +
        value.substring(3, 6) +
        "." +
        value.substring(6);
    }
    if (value.length > 9) {
      cpfNotMask =
        value.substring(0, 3) +
        "." +
        value.substring(3, 6) +
        "." +
        value.substring(6, 9) +
        "-" +
        value.substring(9);
    }
    if (value.length <= 3) {
      cpfNotMask = value;
    }

    const cpfWithMask = cpfNotMask;
    return cpfWithMask;
  }

  removeCPFMask(cpfWithMascara) {
    const cpfNotMask = cpfWithMascara.replace(/[^\d]/g, "");
    return cpfNotMask;
  }

  extractIdFromUrl(url) {
    const parts = url.split("awrecruiting/s/detail/");
    if (parts.length === 2) {
      const id = parts[1].split("/s/detail/")[0];
      return id;
    }
    return "Erro: Não foi possível obter o id da url.";
  }
}
