import { LightningElement, api, wire, track } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import MESSAGE_CHANNEL from '@salesforce/messageChannel/splitViewMessageChannel__c';
import { getObjectInfo } from "lightning/uiObjectInfoApi";

export default class DualRecordForm extends LightningElement {
    @api editableFieldList = "";
    @api nonEditableFieldList = "";
    showEditField = false;
    @api recordId;
    @api objectApiName;
    objLabel;

    handleSuccess(event) {
        this.showEditField = false;
    }
    @wire(getObjectInfo, { objectApiName: "$objectApiName" })
    results({ error, data }) {
        if (data) {
            this.objLabel = data.label + ' Form';

            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.accountRecordTypeId = undefined;
        }
    }

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        console.log('connected call back called');
        setTimeout(() => {
            this.subscription = subscribe(
                this.messageContext,
                MESSAGE_CHANNEL,
                (message) => this.handleMessage(message)
            );
        }, 0);

        if (typeof this.editableFieldList === 'string') {
            this.editableFieldList = this.editableFieldList.split(',').map(field => field.trim());
        } else {
        }
        if (typeof this.nonEditableFieldList === 'string') {
            this.nonEditableFieldList = this.nonEditableFieldList.split(',').map(field => field.trim());
        } else {
        }
    }
    handleEdit() {
        this.showEditField = !this.showEditField;
    }

    handleMessage(message) {
        if (message.recordId) {
            
            this.recordId = message.recordId;
            this.objectApiName = message.objName1;

        } else {
            this.recordId = null;
        }
    }
    handleReset(event) {
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {

            inputFields.forEach(field => {
                field.reset();
            });
        }
        this.showEditField = !this.showEditField;
    }
}