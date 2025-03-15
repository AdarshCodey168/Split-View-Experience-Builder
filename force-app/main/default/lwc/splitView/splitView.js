import { LightningElement, wire, track, api } from "lwc";
import { refreshApex } from "@salesforce/apex";
import getFilteredMessages from "@salesforce/apex/SpiltViewController.getFilteredMessages";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { publish, MessageContext } from "lightning/messageService";
import MESSAGE_CHANNEL from "@salesforce/messageChannel/splitViewMessageChannel__c";
import getDynamicPicklistValues from "@salesforce/apex/PicklistService.getDynamicPicklistValues";
import getFieldLabel from '@salesforce/apex/SpiltViewController.getFieldLabel';
import getPluralLabel from '@salesforce/apex/SpiltViewController.getPluralLabel';


export default class SplitView extends LightningElement {
    @api ObjName;
    @track statusOptions = [];
    @track error;
    @api selectedStatus; // Default value
    @track messages = [];
    @track isDropdownOpen = false;
    objRecordType;
    @api fieldApiNames = "";
    offset = 0;
    @api pageSize = 10;
    @track currentPage = 1;
    @track totalRecords = 0;
    @track isLoading = false;
    @api fieldApiName = ''; // The field API name passed dynamically
    @track showSpinner = false;
    @api sortOrder = '';
    @api sortFieldAPIName = '';
    @track fieldLabel;
    @track pluralLabel;
    @api iconName;


    renderedCallback() {
        // Wait for the DOM to fully render before attaching event listeners
        setTimeout(() => {
            this.addClickListeners();
        }, 0);
    }


    addClickListeners() {
        this.template.querySelectorAll('.slds-dropdown__item a').forEach(item => {
            item.addEventListener('click', (event) => {
                const selectedValue = event.currentTarget.getAttribute('data-value');
                console.log('Selected:', selectedValue);
            });
        });
    }


    @wire(getDynamicPicklistValues, {
        objectApiName: "$ObjName",
        fieldApiName: "$fieldApiName"
    })
    picklistResults({ error, data }) {
        if (data) {
            let picklistValues = data.picklistValues || [];
            
            this.statusOptions = picklistValues.map(option => ({
                label: option,
                value: option,
                isSelected: option === this.selectedStatus
            }));


            // Store the resolved default picklist value
         //   this.selectedStatus = defaultPicklistValue;

           
            this.error = undefined;
        } else if (error) {
            console.log('some error');
            this.error = error;
            this.statusOptions = [];
        }
    }

    get filterFieldName() {
        return this.fieldApiName;
    }

    fetchPluralLabel() {
        getPluralLabel({ objectName: this.ObjName })
            .then(result => {
                this.pluralLabel = result;
            })
            .catch(error => {
                console.error('Error fetching plural label:', error);
                this.pluralLabel = 'Error retrieving plural label';
            });
    }

    fetchFieldLabel() {
        getFieldLabel({ objectName: this.ObjName, fieldName: this.sortFieldAPIName })
            .then(result => {
                this.fieldLabel = result;
            })
            .catch(error => {
                console.error('Error fetching field label:', error);
                this.fieldLabel = 'Error retrieving label';
            });
    }


    toggleDropdown() {
        this.isDropdownOpen = !this.isDropdownOpen;
    }

    connectedCallback() {
        if (typeof this.fieldApiNames === 'string') {
            this.fieldApiNames = this.fieldApiNames.split(',').map(field => field.trim());
        }
        this.fetchFieldLabel();
        this.fetchPluralLabel();

        this.fetchMessages();


    }

    handleOptionSelect(event) {
        event.preventDefault(); // Prevent default anchor behavior
        const selectedValue = event.currentTarget.dataset.value;
        this.selectedStatus = selectedValue;
        this.currentPage = 1;
        this.offset = 0;

        // Close the dropdown after selection
        this.isDropdownOpen = false;
        this.fetchMessages();
        // Recreate the options to exclude the selected value from the dropdown
        this.statusOptions = this.statusOptions.map(option => ({
            ...option,
            isSelected: option.value === this.selectedStatus
        }));
    }

    get filteredOptions() {
        // Exclude the selected status from the options
        return this.statusOptions.filter(option => option.value !== this.selectedStatus);
    }

    @wire(getObjectInfo, { objectApiName: "$ObjName" })
    results({ error, data }) {
        if (data) {

            this.objRecordType = data.defaultRecordTypeId;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.accountRecordTypeId = undefined;
        }
    }

    get totalPages() {
        return Math.ceil(this.totalRecords / this.pageSize);
    }

    get isFirstPage() {
        return this.currentPage === 1;
    }

    get isLastPage() {
        return this.currentPage === this.totalPages;
    }

    get sortIcon() {
        return this.sortOrder === 'ASC' ? 'utility:arrowup' : 'utility:arrowdown';
    }

    fetchMessages() {
        this.isLoading = true;
        getFilteredMessages({
            filterField: this.fieldApiName,
            filterValue: this.selectedStatus,
            objectName: this.ObjName,
            fieldApiNames: this.fieldApiNames,
            offset: this.offset,
            pageSize: this.pageSize,
            sortField: this.sortFieldAPIName,
            sortOrder: this.sortOrder
        })
            .then((data) => {
                this.messages = data.records.map((record) => {
                    const dynamicFields = {};
                    this.fieldApiNames.forEach((field) => {
                        dynamicFields[field] = record[field] || null;
                    });
                    return { ...record, dynamicFields };
                });
                this.totalRecords = data.totalCount;
                this.isLoading = false;
            })
            .catch((error) => {
                console.error('Error fetching records: ', error);
                this.isLoading = false;
            });
    }


    handleSort(event) {
        console.log('is hadleSort called');
        const field = event.currentTarget.dataset.field;
        this.sortOrder = this.sortOrder === 'ASC' ? 'DESC' : 'ASC';
        this.sortField = field;
        this.fetchMessages();
    }
    goToFirstPage() {
        if (this.currentPage > 1) {
            this.currentPage = 1;
            this.offset = 0;
            this.fetchMessages();
        }
    }

    previousPage() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.offset -= this.pageSize;
            this.fetchMessages();
        }
    }

    nextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
            this.offset += this.pageSize;
            this.fetchMessages();
        }
    }

    goToLastPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage = this.totalPages;
            this.offset = (this.totalPages - 1) * this.pageSize;
            this.fetchMessages();
        }
    }

    async handleRefresh() {
        this.showSpinner = true;
        try {
            await refreshApex(this.messages);
        } catch (error) {
            console.error("Error refreshing messages:", error);
        } finally {
            setTimeout(() => {
                this.showSpinner = false;
            }, 500);
        }
    }

    get messagesForTemplate() {
        console.log('finding the issue before messagesForTemplate');

        return this.messages.map((message) => {
            const flatFields = {};
            if (message.dynamicFields) {
                this.fieldApiNames.forEach((field, index) => {
                    flatFields[`field${index}`] = message.dynamicFields[field] || null; // Use unique keys for dynamic fields
                });
            } else {
                console.warn(`dynamicFields is missing for message with Id: ${message.Id}`);
            }
            return { ...message, flatFields }; // Add flatFields for template usage
        });
    }

    @wire(MessageContext)
    messageContext;

    handleRecordClick(event) {
        const recordId = event.currentTarget.dataset.id;
        const objName1 = this.ObjName;
        publish(this.messageContext, MESSAGE_CHANNEL, { recordId, objName1 });
    }
}