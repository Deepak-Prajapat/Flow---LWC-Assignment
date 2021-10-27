/**
 * @description       : SimilarRecordsSetting Component Backend Class
 * @author            : Deepak Prajapati (d.prajapati@concret.io)
 * @last modified on  : 26-10-2021
 * @last modified by  : Deepak Prajapati (d.prajapati@concret.io)
**/
public with sharing class SimiliarRecordsSettingsController {
    /**
    * @description: to get all object labels  api names for Query Editor
    * @author Deepak Prajapati (d.prajapati@concret.io) | 29-06-2021 
    * @return List<apiAndLabelWrapper> (List Of Wrapper, (Wrapper includes label and api name of sobject))
    **/
    @AuraEnabled
    Public static List<apiAndLabelWrapper> getObjList(){

        System.debug('Log Generated');
        List<apiAndLabelWrapper> objects = new List<apiAndLabelWrapper>();
        try {
            List<Schema.SObjectType> objList = Schema.getGlobalDescribe().Values();
            for(Schema.SObjectType obj : objList){
                apiAndLabelWrapper objWrapper = new apiAndLabelWrapper();
                if(obj.getDescribe().getLabel().contains('__MISSING LABEL__')) continue;
                objWrapper.apiName = obj.getDescribe().getName();
                objWrapper.Label = obj.getDescribe().getLabel();
                objects.add(objWrapper);
            }
        } catch(Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
        }
       objects.sort();
       return objects;
    }

    
    public class apiAndLabelWrapper implements Comparable {
        @AuraEnabled
        public String apiName {get;set;}
        @AuraEnabled
        public String Label {get;set;}

        public Integer compareTo(Object compareTo) {
            apiAndLabelWrapper compareToEmp = (apiAndLabelWrapper)compareTo;
            if (Label == compareToEmp.Label) return 0;
            if (Label > compareToEmp.Label) return 1;
            return -1;        
        }
    }
    /**
    * @description to get fields of a particular object
    * @author Deepak Prajapati (d.prajapati@concret.io) | 29-06-2021 
    * @param String objname (object name from client side)
    * @return List<apiAndLabelWrapper> (All fields names in List of wrapper)
    ************************************/
    @AuraEnabled
    public static List<apiAndLabelWrapper> getFields(String objname) {
        List<apiAndLabelWrapper> fields = new List<apiAndLabelWrapper>();
        map<string,schema.sobjecttype> describe = schema.getglobaldescribe();
        if(describe.containskey(objname)) {
            map<string,schema.sobjectfield> fieldmap = describe.get(objname).getdescribe().fields.getmap();
            for(string fi:fieldmap.keyset()) {
                apiAndLabelWrapper wrp = new apiAndLabelWrapper();
                wrp.Label = fieldmap.get(fi).getdescribe().getLabel();
                wrp.apiName = fieldmap.get(fi).getdescribe().getName();
                fields.add(wrp);
            }
        }
        fields.sort();
        return fields;
    }


    /**
    * @description To get already available configuration in custom settings
    * @author Deepak Prajapati (d.prajapati@concret.io) | 26-10-2021 
    * @return AvailableSettingsWrapper
    **/
    @AuraEnabled
    public static AvailableSettingsWrapper getAvailableSettings(){
        AvailableSettingsWrapper asWrapper = new AvailableSettingsWrapper();
        try {
            List<SimiliarRecordsSettings__c> similarSettings = [SELECT  Id, 
                                                                        Name, 
                                                                        Fields__c
                                                                FROM SimiliarRecordsSettings__c];
            asWrapper.similarSettings = similarSettings;
            if(similarSettings.size() > 0){
                asWrapper.isAvailable = true;
            }else{
                asWrapper.isAvailable = false;
            }
            
            return asWrapper;
        } catch (Exception e) {
            asWrapper.isAvailable = false;
            return asWrapper;
        }
    }

    public class AvailableSettingsWrapper{
        @AuraEnabled
        public List<SimiliarRecordsSettings__c> similarSettings = new List<SimiliarRecordsSettings__c>();
        @AuraEnabled
        public Boolean isAvailable = false;

    }

    /**
    * @description insert custom setting record
    * @author Deepak Prajapati (d.prajapati@concret.io) | 26-10-2021 
    * @param String jsonPerameters (data object in json)
    * @return Boolean 
    **/
    @AuraEnabled
    public static Boolean insertSettings(String jsonPerameters){

        Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(jsonPerameters);
        String selectedObject = String.valueOf(data.get('selectedObject'));
        List<Object> columns = (List<Object>) data.get('columnsList');

        System.debug('in debug');
        String fieldsText = '';
        SimiliarRecordsSettings__c srSettings = new SimiliarRecordsSettings__c();
        srSettings.Name = selectedObject;
        
        for (Object column : columns) {
            fieldsText += String.valueOf(column) + ',';
        }   

        srSettings.fields__c = fieldsText.removeEnd(',');
        try {
            upsert srSettings Name;
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    /**
    * @description delete particular custom setting record
    * @author Deepak Prajapati (d.prajapati@concret.io) | 26-10-2021 
    * @param Id recordId (custom setting recordId)
    * @return Boolean 
    **/
    @AuraEnabled
    public static Boolean deleteSettings(Id recordId){
        System.debug(recordId);
        try {
            List<SimiliarRecordsSettings__c> s = [select id,Name from SimiliarRecordsSettings__c where id =:recordId];
            System.debug(s);
            delete s;
            return true;
        } catch (Exception e) {
            return false;
        }
    }
}
