/**
 * @description       : 
 * @author            : Deepak Prajapati (d.prajapati@concret.io)
 * @group             : 
 * @last modified on  : 26-10-2021
 * @last modified by  : Deepak Prajapati (d.prajapati@concret.io)
**/
import { LightningElement, api,wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getSettings from '@salesforce/apex/similarRecordsController.getSettings';
import getSimiliarRecords from '@salesforce/apex/similarRecordsController.getSimiliarRecords';


export default class SimilarRecords extends LightningElement {
    @api objectApiName;
    @api recordId;
    


    fields = []; //with objectApiName. + field
    fieldNames = [
        'Name'
    ];
    objectFields = [];

    componentTitle;

    //componentTitle = 'Similar ' + this.objectApiName;
    showSimilarRecords = false;
    objectName;
    

    columns = [
        {
            label: 'Name', fieldName: 'linkUrl', type: 'url',
            typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }
        }
    ]

    connectedCallback() {
        this.componentTitle = 'Similar ' + this.objectApiName
        getSettings({ objectName: this.objectApiName })
            .then(result => {
                if (result != null) {
                    
                    let feilds = result.Fields__c;
                    let fieldsArray = feilds.split(",");
                    fieldsArray.forEach(field => {
                        if (field != 'Name') {
                            this.fields.push(this.objectApiName + '.' + field);
                            this.fieldNames.push(field);
                        }
                    })

                    this.fieldNames.forEach(element => {
                        let tempObj = undefined;
                        if (element != 'Name' ) {
                            tempObj = {
                                label: element,
                                fieldName: element,
                                sortable: true
                            }
                        }

                        if (tempObj) {
                            this.columns = [...this.columns, tempObj];
                        }
                        
                    })
                }
                this.fields.push(this.objectApiName + '.Name');

                this.objectFields = this.fields;
            })
            .catch(error => {
                console.error(error);
                // TODO Error handling
            });
    }

    /**
     *  Get Record Details for Similarity
     */
    dataFields;
    @wire(getRecord, { recordId: '$recordId', fields: '$objectFields' })
    wiredAccount({ error, data }) {
    // you have created fieldNames, convert them to object 
        if (data) {
            this.dataFields = data.fields;

            let jsonData = {
                objectApiName: this.objectApiName,
                fields: this.fieldNames,
                fieldsData: this.dataFields,
                offSet: this.offSet,
                rowLimit: this.rowLimit
            }

            this.getData(jsonData);
            this.error = undefined;
        } else if (error) {
            console.log(error);
            this.error = error;
            this.lead = undefined;
        }
    }

    allSimiliarLeads = [];
    isRecordsAvailable = false;
    getData(jsonData) {
    
        return getSimiliarRecords({ jsonData: JSON.stringify(jsonData) })
            .then((result) => {
                if (result.records.length == 0) {
                    this.infiniteTable = false;
                }
                this.showSimilarRecords = true;
                result.records.forEach(record => {
                    let tempObj = record;
                    tempObj.linkUrl = '/' + record.Id;

                    if (this.recordId != record.Id) {
                        this.allSimiliarLeads = [...this.allSimiliarLeads, tempObj];
                    }
                })

                
                if (this.allSimiliarLeads.length == 0) {
                    this.showSimilarRecords = false;    
                } 
                
                
            })
            .catch((error) => {
                this.error = error;
                this.contacts = undefined;
            });
    }


    /**
     * DATATABLE SORTING
     */ 
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.allSimiliarLeads];
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.allSimiliarLeads = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }
    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) { return primer(x[field]);}
            : function(x) {  return x[field]; };
        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }


    /* LAZY LOADING */
    maxRecord = 0;
    infiniteTable = true;
    rowLimit = 20;
    offSet = 0;
    loadMoreData(event) {
        console.log('loadMoreData ');
        try {
            const { target } = event;
            target.isLoading = true;
            if (this.maxRecord > (this.inputValue - this.rowLimit)) {
                this.rowLimit = this.inputValue - this.maxRecord;
            } else {
                this.maxRecord += this.rowLimit;
            }
            this.offSet = this.offSet + this.rowLimit;
        
            let jsonData = {
                objectApiName: this.objectApiName,
                fields: this.fieldNames,
                fieldsData: this.dataFields,
                offSet: this.offSet,
                rowLimit: this.rowLimit,
                event: event,
                isOnLoad: true
            }

            this.getData(jsonData)
                .then(() => {
                    target.isLoading = false;
            })
        } catch (error) {
            console.error(error.message);
        }
    }


}