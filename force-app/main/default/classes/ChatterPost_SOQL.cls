/**
 * @description       : Query Class for Chatter Post Assignment
 * @author            : Deepak Prajapati (d.prajapati@concret.io)
 * @last modified on  : 06-10-2021
 * @last modified by  : Deepak Prajapati (d.prajapati@concret.io)
**/
public with sharing class ChatterPost_SOQL {
    public static List<Account> getAccounts(Set<Id> parentIds){
        return [  SELECT 
                        Name,
                        Id,
                        CreatedBy.FirstName,
                        CreatedBy.LastName 
                    FROM Account 
                    WHERE id IN :parentIds   ];
    }

    public static List<User> getUsers(Set<Id> userIds){
        return [SELECT 
                    Id, 
                    FirstName, 
                    LastName,
                    Email 
                FROM User 
                WHERE id IN :userIds];
    }

    public static List<FeedItem> getFeedItems(Set<Id> idsFeedItem){
        return [SELECT 
                    Id, 
                    type 
                FROM FeedItem 
                WHERE id IN: idsFeedItem];
    }
}
