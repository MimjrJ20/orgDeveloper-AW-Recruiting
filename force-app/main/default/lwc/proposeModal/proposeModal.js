import { LightningElement } from "lwc"
import CandidateProposeModal from "c/candidateProposeModal";

export default class ProposeModal extends LightningElement {

    result;

    async handleClick(){

        var result = await CandidateProposeModal.open({
            size: "Small"
        });

        this.result = result;
    }
}