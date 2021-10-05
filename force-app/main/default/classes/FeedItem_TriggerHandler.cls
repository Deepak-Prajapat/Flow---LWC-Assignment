/**********************************************************************************************
 * @description       : 
 * @author            : Deepak Prajapati (d.prajapati@concret.io)
 * @last modified on  : 05-10-2021
 * @last modified by  : Deepak Prajapati (d.prajapati@concret.io)
************************************************************************************************/
public with sharing class FeedItem_TriggerHandler {

    public static final String ORG_URL = URL.getSalesforceBaseUrl().toExternalForm();

    /* For Testing Purpose */
    @TestVisible public static Map<Integer, List<String>> testEmails = new Map<Integer,List<String>>();

    /****************
    * @description Method for sending email to Account Followers
    * @author Deepak Prajapati (d.prajapati@concret.io) | 28-09-2021 
    * @param List<FeedItem> feedItemList --> Trigger.New  
    * @param String operationType  --> Either Insert or Update
    **************************************************************/
    public static void FeedItem_Trigger(List<FeedItem> feedItemList, String operationType) {

        /* A Helper For Testing */
        Integer count = 0;

        /* Get all users */
        Map<Id, User> usersMap = new Map<Id, User>([SELECT 
                                                        Id, 
                                                        FirstName, 
                                                        LastName,
                                                        Email 
                                                    FROM User 
                                                    LIMIT 999]);
        

        /* Store Parent AccountIds and Feed Ids */
        Set<Id> parentIds = new Set<Id>();
        Set<Id> idsFeedItem = new Set<Id>();

        for (FeedItem fi : feedItemList) {
            parentIds.add(fi.ParentId);
            idsFeedItem.add(fi.id);
        }
        
        /* All FeedItems to Filter Feed Type */
            Map<Id, FeedItem> feedItemsMap = new Map<Id, FeedItem>([SELECT 
                                                                        Id, 
                                                                        type 
                                                                    FROM FeedItem 
                                                                    WHERE id IN: idsFeedItem]);

        
        Map<Id, Account> feedParentAccounts = new Map<Id, Account> ([  SELECT 
                                                                            Name,
                                                                            Id,
                                                                            CreatedBy.FirstName,
                                                                            CreatedBy.LastName 
                                                                        FROM Account 
                                                                        WHERE id IN :parentIds]);

        /* UserMap with email */
        Map<Id, ChatterPost_Utility.FollowersWrapper> followersMap = ChatterPost_Utility.getFollowersByAccount(parentIds);
        
        /* Send Emails to the followers */
        for (FeedItem feed : feedItemList) {
            if (
                feedItemsMap.get(feed.id).Type == 'TextPost' ||
                feedItemsMap.get(feed.id).Type == 'ContentPost' 
            ) {
                String senderName = feedParentAccounts.get(feed.ParentId).CreatedBy.firstName + ' ' + feedParentAccounts.get(feed.ParentId).CreatedBy.LastName;

                /* Getting List of mentioned users */
                List<ID> idsOfMentionedUsers = ChatterPost_Utility.postMentionedUsers(feed.Id);
                
                /* Followers Emails */
                Set<String> emails = new Set<String>();
                if (!followersMap.get(feed.ParentId).emails.isEmpty()) {
                    emails = new Set<String> (followersMap.get(feed.parentId).emails);
                    /* Remove Mentioned Users */
                    for (Id mentionedId : idsOfMentionedUsers) {
                        emails.remove(usersMap.get(mentionedId).Email);
                    }
                    emails.remove(usersMap.get(feed.CreatedById).Email);

                    /* Format Mail Based On Opeation */
                    String insertOrUpdate;
                    String insertOrUpdateBody;
                    if (operationType == 'INSERT') {
                        InsertOrUpdate = ' Added A Feed On ';
                        insertOrUpdateBody = ' There is a new post of account ';
                    }else {
                        insertOrUpdate = ' Updated A Feed On';
                        insertOrUpdateBody = ' An Existing post is updated on ';
                    }

                    String subject = usersMap.get(feed.CreatedById).FirstName + ' ' + usersMap.get(feed.CreatedById).LastName + insertOrUpdate + feedParentAccounts.get(feed.ParentId).Name + ' '; 
                    String bodyText =   '<p>HI,<br><br> ' + 
                                            insertOrUpdateBody  + '<a href="' + ORG_URL + '/' + feed.ParentId + '/view"> ' + feedParentAccounts.get(feed.ParentId).Name + ' <a/> By <a href="' + ORG_URL + '/' + feed.CreatedBy + '"' +'  >' + usersMap.get(feed.CreatedById).FirstName + ' ' + usersMap.get(feed.CreatedById).LastName  + ' </a><br><br> ' + 
                                            ' To view/Reply click on the link <a href="' + ORG_URL + '/' + feed.id + '">' + ORG_URL + '/' + feed.id +' </a>' +
                                        '</p>';  
                    
                    List<String> emailsToSend = new List<String>(emails);

                    /* Ignor: Testing Identifires */
                    testEmails.put(count, emailsToSend);
                    count++;

                    /* Send mail */
                    EmailService.sendEmails(senderName, emailsToSend, subject, bodyText);    
                }
            }
        }
    }
}
