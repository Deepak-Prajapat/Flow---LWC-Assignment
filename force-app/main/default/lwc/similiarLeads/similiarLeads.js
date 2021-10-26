/**
 * @description       : 
 * @author            : Deepak Prajapati (d.prajapati@concret.io)
 * @group             : 
 * @last modified on  : 20-10-2021
 * @last modified by  : Deepak Prajapati (d.prajapati@concret.io)
*************************/
import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getSimiliarLeads from '@salesforce/apex/similiarLeadsController.getSimiliarLeads';

const fields = [
    'Lead.Name',
    'Lead.Email',
    'Lead.Phone',
    'Lead.Company',
    'Lead.Country',
    'Lead.LeadSource',
    'Lead.ProductInterest__c'
];

const COLUMNS = [
    {
        label: 'Similar leads', fieldName: 'linkUrl', type: 'url',
        typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }
    },
    {
        label : 'Email',
        fieldName: 'Email',
        sortable: true
    },
    {
        label : 'Phone',
        fieldName: 'Phone',
        sortable: true
    },
    {
        label : 'Company',
        fieldName: 'Company',
        sortable: true
    },
    {
        label : 'Country',
        fieldName: 'Country',
        sortable: true
    },
    {
        label : 'Lead Source',
        fieldName: 'LeadSource',
        sortable: true
    },
    {
        label : 'Product Interest',
        fieldName: 'ProductInterest__c',
        sortable: true
    }
]

export default class SimiliarLeads extends LightningElement {
    @api recordId;

    lead;
    @wire(getRecord, { recordId: '$recordId', fields: fields })
    wiredAccount({ error, data }) {
        if (data) {

            let recordFields = {
                Company: data.fields.Company.value,
                Country: data.fields.Country.value,
                Name: data.fields.Name.value,
                Email: data.fields.Email.value,
                Phone: data.fields.Phone.value,
                LeadSource: data.fields.LeadSource.value,
                ProductInterest__c : data.fields.ProductInterest__c.value
            }

            this.getData(JSON.stringify(recordFields));
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.lead = undefined;
        }
    }
    
    isLeadsAvailable = false;
    get isSimiliarLeads() {
        return this.isLeadsAvailable;
    }

    allSimiliarLeads = [];
    getData(stringLead) {
        getSimiliarLeads({ jsonLead: stringLead })
            .then((result) => {
                this.isLeadsAvailable = result.isLeadsAvailable;
                
                if (this.isLeadsAvailable) {
                    result.similiarLeads.forEach(record => {
                        let tempObj = {
                            linkUrl: '/' + record.Id,
                            Name: record.Name,
                            Company: record.Company,
                            Country: record.Country,
                            LeadSource: record.LeadSource,
                            Phone: record.Phone,
                            Email: record.Email,
                            ProductInterest__c: record.ProductInterest__c
                        };
                        
                        if (this.recordId != record.Id) {
                            this.allSimiliarLeads = [...this.allSimiliarLeads, tempObj];
                        }
                    })
                }
            })
            .catch((error) => {
                this.error = error;
                this.contacts = undefined;
            });
    }

    get columnsList() {
        return COLUMNS;
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
}