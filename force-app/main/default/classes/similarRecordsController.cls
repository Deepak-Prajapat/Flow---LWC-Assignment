/**
 * @description       : 
 * @author            : Deepak Prajapati (d.prajapati@concret.io)
 * @group             : 
 * @last modified on  : 26-10-2021
 * @last modified by  : Deepak Prajapati (d.prajapati@concret.io)
**/
public with sharing class similarRecordsController {
    @AuraEnabled
    public static SimiliarRecordsSettings__c getSettings(String objectName){
        try {
            return [SELECT Id,Name,Fields__c
                    FROM SimiliarRecordsSettings__c
                    WHERE Name = :objectName
                    LIMIT 1 ];
        } catch (Exception e) {
            return null;
        }
    }

    @AuraEnabled
    public static SimilarRecordsWrapper getSimiliarRecords(String jsonData) {
        Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(jsonData);

        String objectApiName = String.valueOf(data.get('objectApiName'));
        List<Object> fields = (List<Object>) data.get('fields');
        Map<String,Object> fieldsData = (Map<String,Object>) data.get('fieldsData');

        String whereClause = ' WHERE  ';
        String queryFields = 'Name, ';
        Integer count = 0;

        for (Object obj : fields) {
            Map<String, Object> objMap = (Map<String, Object>)(fieldsData.get(String.valueOf(obj)));
            
            if (String.valueOf(obj) != 'Name' && objMap.get('value') != null) {
                queryFields += String.valueOf(obj) + ' ,';

                whereClause += String.valueOf(obj) + ' = ' +  '\'' + objMap.get('value') + '\'' + ' OR ';    
            }
        }

        String query = 'SELECT ' + queryFields.removeEnd(',') + ' FROM ' + objectApiName + whereClause.substring(0, whereClause.length() - 3) + ' Limit ' + data.get('rowLimit') + ' OFFSET ' + data.get('offSet');

        System.debug('query -> ' + query);
        SimilarRecordsWrapper srWrapper = new similarRecordsWrapper();

        try {
            srWrapper.records = Database.query(query);
            System.debug(srWrapper.records.size() + '::');

            if (srWrapper.records.size() > 0) {
                srWrapper.isRecordsAvailable = true;
                return srWrapper;
            }else {
                srWrapper.isRecordsAvailable = false;
                return srWrapper;
            }
        }
        catch (Exception ex) {
            srWrapper.isRecordsAvailable = false;
            return srWrapper;
        }
    }

    public class similarRecordsWrapper {
        @AuraEnabled
        public List<SObject> records = new List<SObject>();
        @AuraEnabled
        public Boolean isRecordsAvailable = false;
    }

}
