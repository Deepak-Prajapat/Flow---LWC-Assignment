/**
 * @description       : 
 * @author            : Deepak Prajapati (d.prajapati@concret.io)
 * @group             : 
 * @last modified on  : 20-10-2021
 * @last modified by  : Deepak Prajapati (d.prajapati@concret.io)
**/
public with sharing class similiarLeadsController {
    @AuraEnabled(cacheable=true)
    public static SimiliarLeadsWrapper getSimiliarLeads(String jsonLead){
        SimiliarLeadsWrapper slWrapper = new SimiliarLeadsWrapper();
        Map<String, Object> leads = (Map<String, Object>) JSON.deserializeUntyped(jsonLead);

        String Email, Country, Company, LeadSource, ProductInterest,Phone;

        Boolean allBlank = true;
        String query =  'SELECT  Id,' + 
                                'Name, ' + 
                                'Email, ' + 
                                'Company,' + 
                                'Country,' + 
                                'LeadSource,' + 
                                'ProductInterest__c,' + 
                                'Phone' +
                        ' FROM Lead ' + 
                        ' WHERE Name = ' + '\'' + leads.get('Name') + '\'';

        if (String.isNotEmpty( String.valueOf(leads.get('Email')) )) {
            query += ' OR Email = ' + '\'' + String.valueOf(leads.get('Email')) + '\'';
            allBlank = false;
        }

        if (String.isNotEmpty(String.valueOf(leads.get('Phone')))) {
            query += ' OR Phone = ' + '\'' + String.valueOf(leads.get('Phone')) + '\'';
            allBlank = false;
        }

        if (String.isNotEmpty(String.valueOf(leads.get('Country')))) {
            query += ' OR Country = ' + '\'' + String.valueOf(leads.get('Country')) + '\'';
            allBlank = false;
        }

        if (String.isNotEmpty(String.valueOf(leads.get('Company')))) {
            query += ' OR Company = ' + '\'' + String.valueOf(leads.get('Company')) + '\'';
            allBlank = false;
        }

        if (String.isNotEmpty(String.valueOf(leads.get('LeadSource')))) {
            query += ' OR LeadSource = '+ '\'' + String.valueOf(leads.get('LeadSource')) + '\'';
            allBlank = false;
        }
        
        if (String.isNotEmpty( String.valueOf(leads.get('ProductInterest__c'))) ) {
            query += ' OR ProductInterest__c = ' + '\'' + String.valueOf(leads.get('ProductInterest__c')) + '\'';
            allBlank = false;
        }

        System.debug(query);

        if (allBlank) {
            slWrapper.isLeadsAvailable = false;
            return slWrapper;
        }else {
            slWrapper.similiarLeads = Database.query(query);
            
            if(slWrapper.similiarLeads.size() > 0){
                slWrapper.isLeadsAvailable = true;
            }
            else {
                slWrapper.isLeadsAvailable = false;
            }
        }

        return slWrapper;
    }

    public class SimiliarLeadsWrapper{
        @AuraEnabled
        public List<Lead> similiarLeads = new List<Lead>();
        @AuraEnabled
        public Boolean isLeadsAvailable = false;
    }
}