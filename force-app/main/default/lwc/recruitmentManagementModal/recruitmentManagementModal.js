import LightningModal from "lightning/modal";
import { LightningElement, track, api } from "lwc";

export default class RecruitmentManagementModal extends LightningModal {
    
    //
    @api selectedRowsIds = [];


    //
    open(options) {
        this.selectedRowsIds = options.selectedRowsIds;
    }
    


    //
    saveChanges() {
        console.log("Selected IDs modal: ", this.selectedRowsIds);
        this.close();
    }

    
}
