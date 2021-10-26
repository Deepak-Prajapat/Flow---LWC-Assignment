/**                     **************                    ***
 * @description       : Helper class for FeedComment Trigger
 * @author            : Deepak Prajapati (d.prajapati@concret.io)
 * @last modified on  : 06-10-2021
 * @last modified by  : Deepak Prajapati (d.prajapati@concret.io)
**************************************************************/
public with sharing class FeedComment_TriggerHandler {
 
    public static final String ORG_URL = URL.getSalesforceBaseUrl().toExternalForm();
    
    /* TEST VARIABLE */
    @TestVisible public static List<String> testEmails;

    /**
    * @description Method for sending email to Account Followers
    * @author Deepak Prajapati (d.prajapati@concret.io) | 28-09-2021 
    * @param List<FeedItem> feedItemList --> Trigger.New  
    * @param String operationType  --> Either Insert or Update
    ****/
    public static void notifyFollowers(List<FeedComment> feedComments) {
        
        Set<Id> parentIds = new Set<Id>();
        Set<Id> parentFeeds = new Set<Id>();
        Set<Id> userIds = new Set<Id>(); // userIds for createdBy field
        
        for(FeedComment comment : feedComments) {
            parentIds.add(comment.ParentId);
            parentFeeds.add(comment.FeedItemId);
            userIds.add(comment.CreatedById);
        }

        Map<Id, Account> feedParentAccounts = new Map<Id, Account> ( ChatterPost_SOQL.getAccounts(parentIds) ); //Store Parent Accounts
        Map<Id, FeedItem> feedItemsMap = new Map<Id, FeedItem>(ChatterPost_SOQL.getFeedItems(parentFeeds)); //Store FeedItems
        Map<Id, User> usersMap = new Map<Id, User>(ChatterPost_SOQL.getUsers(userIds)); //Store Users

        /* Get Followers by Account */
        Map<Id, ChatterPost_Utility.FollowersWrapper> followersMap = ChatterPost_Utility.getFollowersByAccount(parentIds);

        /* Send Emails to the followers */
        for (FeedComment comment : feedComments) {
            if (
                feedItemsMap.get(comment.FeedItemId).Type == 'TextPost' || 
                feedItemsMap.get(comment.FeedItemId).Type == 'ContentPost' 
            ) {
                /* Getting List of mentioned users */
                List<Id> idsOfMentionedUsers = ChatterPost_Utility.commentMentionedUsers(comment.Id);
                
                /* If Account have followers then send email */
                Set<String> emails = new Set<String>();

                if (!followersMap.get(comment.ParentId).emails.isEmpty()) {
                    emails = new Set<String> (followersMap.get(comment.parentId).emails);//Store follower emails  

                    /* Remove Mentioned User  */
                    for (Id mentionedId : idsOfMentionedUsers) {
                        emails.remove(usersMap.get(mentionedId).Email);
                    }
                    
                    /* Email Formatting */
                    String subject = usersMap.get(comment.CreatedById).FirstName + ' ' + usersMap.get(comment.CreatedById).LastName + ' Commented on a post of account ' + feedParentAccounts.get(comment.ParentId).Name + ' '; 
                    String senderName = feedParentAccounts.get(comment.ParentId).CreatedBy.firstName + ' ' + feedParentAccounts.get(comment.ParentId).CreatedBy.LastName;

                    String updateOrInsert = '';
                    if (Trigger.isInsert) {
                        updateOrInsert = 'There is a new comment on a post of account';
                    }else if (Trigger.isUpdate){
                        updateOrInsert = 'A existing comments is updated on a post of account ';
                    }

                    String bodyText  =  '<p>HI, <br><br> ' + 
                                            updateOrInsert + ' <a href="' + ORG_URL + '/lightning/r/Account/' + comment.ParentId + '/view"> ' + feedParentAccounts.get(comment.ParentId).Name + ' <a/> By <a href="' + ORG_URL + '/' + comment.CreatedById + '"' +'  >' + usersMap.get(comment.CreatedById).FirstName + ' ' + usersMap.get(comment.CreatedById).LastName  + ' </a><br><br>' + 
                                            'To view/Reply click on the link <a href="' + ORG_URL + '/' + comment.FeedItemId + '">' + ORG_URL + '/' + comment.id +' </a>' +
                                        '</p>' ;   
                    
                    List<String> emailsToSend = new List<String>(emails);
                    testEmails = emailsToSend; // IGNOR: Testing Identifire
                    
                    EmailService.sendEmailToFollowers(senderName, emailsToSend, subject, bodyText);  //Send email to followers
                }
            }
        }
    }
}