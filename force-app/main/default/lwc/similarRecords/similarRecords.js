/**
 * @description       : Similar Records Component Backend
 * @author            : Deepak Prajapati (d.prajapati@concret.io)
 * @last modified on  : 27-10-2021
 * @last modified by  : Deepak Prajapati (d.prajapati@concret.io)
**/
import { LightningElement, api,wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getConfiguration from '@salesforce/apex/similarRecordsController.getConfiguration';
import getSimilarRecords from '@salesforce/apex/similarRecordsController.getSimilarRecords';


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
        getConfiguration({ objectName: this.objectApiName })
            .then(result => {
                if (result != null) {
                    
                    let fields = result.Fields__c;
                    let fieldsArray = fields.split(",");
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

    allSimilarLeads = [];
    isRecordsAvailable = false;
    getData(jsonData) {
    
        return getSimilarRecords({ jsonData: JSON.stringify(jsonData) })
            .then((result) => {
                if (result.records.length == 0) {
                    this.infiniteTable = false;
                }
                this.showSimilarRecords = true;
                result.records.forEach(record => {
                    let tempObj = record;
                    tempObj.linkUrl = '/' + record.Id;

                    if (this.recordId != record.Id) {
                        this.allSimilarLeads = [...this.allSimilarLeads, tempObj];
                    }
                })
                
                if (this.allSimilarLeads.length == 0) {
                    this.showSimilarRecords = false;    
                } 
            })
            .catch((error) => {
                this.error = error;
                this.contacts = undefined;
            });
    }

    /**
     * DATA TABLE SORTING
     */ 
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.allSimilarLeads];
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.allSimilarLeads = cloneData;
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


    /**
     *  LAZY LOADING 
     */
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