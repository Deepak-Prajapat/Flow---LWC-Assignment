/**
 * @description       : Query Class for Chatter Post Assignment
 * @author            : Deepak Prajapati (d.prajapati@concret.io)
 * @last modified on  : 06-10-2021
 * @last modified by  : Deepak Prajapati (d.prajapati@concret.io)
**/
public with sharing class ChatterPost_SOQL {
    /**
    * @description Qyery Account Details 
    * @author Deepak Prajapati (d.prajapati@concret.io) | 06-10-2021 
    * @param Set<Id> idsAccount  -> ids of required accounts
    * @return List<Account> 
    **/
    public static List<Account> getAccounts(Set<Id> idsAccount){
        return [  SELECT 
                        Name,
                        Id,
                        CreatedBy.FirstName,
                        CreatedBy.LastName 
                    FROM Account 
                    WHERE id IN :idsAccount   ];
    }

    /**
    * @author Deepak Prajapati (d.prajapati@concret.io) | 06-10-2021 
    * @param Set<Id> userIds 
    * @return List<User> 
    **/
    public static List<User> getUsers(Set<Id> userIds){
        return [SELECT 
                    Id, 
                    FirstName, 
                    LastName,
                    Email 
                FROM User 
                WHERE id IN :userIds];
    }

    /**
    * @description get feedItem with Id and Type 
    * @author Deepak Prajapati (d.prajapati@concret.io) | 06-10-2021 
    * @param Set<Id> idsFeedItem 
    * @return List<FeedItem> 
    **/
    public static List<FeedItem> getFeedItems(Set<Id> idsFeedItem){
        return [SELECT 
                    Id, 
                    type 
                FROM FeedItem 
                WHERE id IN: idsFeedItem];
    }
}