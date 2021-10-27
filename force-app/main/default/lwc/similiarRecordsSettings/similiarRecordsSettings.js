/**
 * @description       : Similar Records Component
 * @author            : Deepak Prajapati (d.prajapati@concret.io)
 * @group             : 
 * @last modified on  : 27-10-2021
 * @last modified by  : Deepak Prajapati (d.prajapati@concret.io)
**/
import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getObjects from '@salesforce/apex/SimiliarRecordsSettingsController.getObjects';
import getfields from '@salesforce/apex/SimiliarRecordsSettingsController.getFields';
import getAvailableConfiguration from '@salesforce/apex/SimiliarRecordsSettingsController.getAvailableConfiguration';
import insertConfiguration from '@salesforce/apex/SimiliarRecordsSettingsController.insertConfiguration';
import deleteConfiguration from '@salesforce/apex/SimiliarRecordsSettingsController.deleteConfiguration';

export default class SimiliarRecordsSettings extends LightningElement {
    @track selectedObject;
    objectSelected = false;

    /* SETUP OBJECTS */
    @track items = [];
    get objects() {
        if (this.editMode) {
            return this.allObjects;
        } else {
            return this.items;
        }
    }

    availableSettings = undefined;
    alreadyAvailable = false;
    avalConfigurationLabels = []

    allObjects = []
    connectedCallback() {
        this.avalSetting();
        this.getAllObjects();
    }


    /**
     * Fetch available configurationo
     */
    avalSetting() {
        this.avalConfigurationLabels = []
        getAvailableConfiguration()
            .then(result => {
                if (result.isAvailable) {
                    console.log('result --> ', result)
                    this.availableSettings = result;
                    this.alreadyAvailable = true;

                    result.similarSettings.forEach(ele => {
                        this.avalConfigurationLabels.push(ele.Name);
                    })
                }
            })
            .catch(error => {
                // TODO Error handling
                console.error(error);
            });
    }

    /**
     * Get Objects
     */
    getAllObjects() {
        this.items = [];
        this.allObjects = [];
        getObjects() 
            .then((result) => {
                result.forEach(element => {
                    if (!this.avalConfigurationLabels.includes(element.apiName)) {
                        this.items = [...this.items, { value: element.apiName, label: element.Label }];    
                    }
                    this.allObjects = [...this.allObjects, { value: element.apiName, label: element.Label }];
                });
                this.items.unshift({ value: 'NULL', label: '--  Select Object  --' });
            this.handleObjectChange();
            })
            .catch((error) => {
                this.error = error;
            });
    }

    /* SETUP FIELDS */
    get allFields() {
        return this.values;
    }

    get settings() {
        return this.availableSettings;
    }

    editMode = false;
    @track values = [];
    CheckAllFields = false;

    /**
     * Backend after object selected by users
     */
    handleObjectChange(event) {
        this.selectedFields = [];
        this.values = [];
        if (this.editMode == false) {
            this.selectedObject = event.detail.value;
        }

        getfields({ objname: this.selectedObject }).then((result) => {
            this.CheckAllFields = true;
            result.forEach(field => {
                this.values = [...this.values, { value: field.apiName, label: field.Label, }];
            });
            this.objectSelected = true;
        }).catch((err) => {
            console.error('Error While Getting Fields' , err)
        });
    }

    /* Selected Fields : create dynamic columns*/
    columns = [];
    selectedFields;
    onSelectField(event) {
        this.selectedFields = event.detail.value;

        this.columns = [];
        this.selectedFields.forEach(element => {
            this.clm = {
                label: element,
                fieldName: element,
                sortable: true
            }
            this.columns = [...this.columns, this.clm];

            if (this.columns.length > 0) {
                this.saveActivated = true;
            }
        });
    }


    /** 
     * Backend after click on save settings
     * */
    saveActivated = false;
    handleSaveSettings() {
        let fields = [];
        this.columns.forEach(column => {
            fields.push(column.fieldName);
        })

        let jsonPerameters = {
            selectedObject: this.selectedObject,
            columns: fields
        }

        insertConfiguration({jsonPerameters: JSON.stringify(jsonPerameters) })
            .then(result => {
                if (result) {
                    this.newConfiguration = false;
                    const evt = new ShowToastEvent({
                        title: 'Inserted',
                        message: 'Your Setings Successfully Inserted',
                        variant: 'success',
                    });
                    this.dispatchEvent(evt);

                    this.selectedObject = 'NULL';
                    this.objectSelected = false;
                }
                this.avalSetting();
                this.getAllObjects();
            })
            .catch(error => {
                console.error(error);
            });

    }

    newConfiguration = false;
    handleClose() {
        this.resetData();
    }
    handleCancel() {
        this.resetData();
    }

    resetData() {
        this.newConfiguration = false;
        this.values = [];
        this.editMode = false;
        this.selectedObject = 'NULL';
        this.selectedFieldValues = [];
    }

    get displayNew() {
        return this.newConfiguration;
    }

    handleAdd() {
        this.selectedObject = 'NULL';
        this.headerText = 'Add New Configuration';
        this.newConfiguration = true;
    }

    headerText = 'Add New Filter';

    handleDeleteClick(event){
        if (confirm("Are you sure, you want to delete?") == true) {
            this.handleDelete(event);
        }
    }

    handleDelete(event) {
        deleteConfiguration({recordId:  event.target.value})
            .then(result => {
                if (result == true) {
                    const evt = new ShowToastEvent({
                        title: 'Deleted',
                        message: 'Deleted Successfully',
                        variant: 'success',
                    });
                    this.dispatchEvent(evt);
                }
                this.avalSetting();
                this.getAllObjects();
            })
            .catch(error => {
                console.error(error);
            });
    }


    selectedFieldValues = [];
    get editing() {
        return this.editMode;
    }

    get selectedObj() {
        return this.selectedObject;
    }
    
    handleEdit(event) {
        this.newConfiguration = false;
        let obj = Object.values(this.availableSettings.similarSettings).filter(obj => obj.Id == event.target.value);
       this.selectedObject = obj[0].Name;
    
        this.headerText = 'Customize ' + this.selectedObject;

        try {
            let fields = JSON.stringify(obj[0].Fields__c);
            fields = fields.substring(1, fields.length - 1);
            let arr = fields.split(',');
            this.selectedFieldValues = arr;
        } catch (error) {
            console.log(error.message)
        }

        this.editMode = true;
        this.newConfiguration = true;
        this.handleObjectChange();
    }
}