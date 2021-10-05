/**                     **************                    ***
 * @description       : Helper class for FeedComment Trigger
 * @author            : Deepak Prajapati (d.prajapati@concret.io)
 * @last modified on  : 05-10-2021
 * @last modified by  : Deepak Prajapati (d.prajapati@concret.io)
**************************************************************/
public with sharing class FeedComment_TriggerHandler {

    Public static final String ORG_URL = URL.getSalesforceBaseUrl().toExternalForm();
    
    /* TEST VARIABLE */
    @TestVisible public static List<String> testEmails;

    /****************
    * @description Method for sending email to Account Followers
    * @author Deepak Prajapati (d.prajapati@concret.io) | 28-09-2021 
    * @param List<FeedItem> feedItemList --> Trigger.New  
    * @param String operationType  --> Either Insert or Update
    ***************************************/
    public static void FeedComment_Trigger(List<FeedComment> feedComments, String operationType) {

        /* Get All Parent Account Ids  */
        Set<Id> parentIds = new Set<Id>();
        Set<Id> parentFeeds = new Set<Id>();
        
        for(FeedComment comment : feedComments) {
            if ( !parentIds.contains( comment.parentId ) ) {
                parentIds.add(comment.ParentId);
            }
            parentFeeds.add(comment.FeedItemId);
        }

        Map<Id, Account> feedParentAccounts = new Map<Id, Account> ([  SELECT 
                                                                            Name,
                                                                            Id,
                                                                            CreatedBy.FirstName,
                                                                            CreatedBy.LastName 
                                                                        FROM Account 
                                                                        WHERE id IN :parentIds]);

        Map<Id, FeedItem> feedItemsMap = new Map<Id, FeedItem>([SELECT 
                                                                    Id, 
                                                                    type 
                                                                FROM FeedItem 
                                                                WHERE id IN: parentFeeds]);

        /* Get all users */
        Map<Id, User> usersMap = new Map<Id, User>([SELECT Id, FirstName, LastName, Email FROM User]);

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

                    emails = new Set<String> (followersMap.get(comment.parentId).emails);  
                    /* Remove Mentioned User  */
                    for (Id mentionedId : idsOfMentionedUsers) {
                        emails.remove(usersMap.get(mentionedId).Email);
                    }
                    
                    /* Email Formatting */
                    String subject = usersMap.get(comment.CreatedById).FirstName + ' ' + usersMap.get(comment.CreatedById).LastName + ' Commented on a post of account ' + feedParentAccounts.get(comment.ParentId).Name + ' '; 
        
                    String senderName = feedParentAccounts.get(comment.ParentId).CreatedBy.firstName + ' ' + feedParentAccounts.get(comment.ParentId).CreatedBy.LastName;

                    String updateOrInsert = '';
                    if (operationType == 'INSERT') {
                        updateOrInsert = 'There is a new comment on a post of account';
                    }else if (operationType == 'UPDATE'){
                        updateOrInsert = 'A existing comments is updated on a post of account ';
                    }

                    String bodyText =   '<p>HI, <br><br> ' + 
                                            updateOrInsert + ' <a href="' + ORG_URL + '/lightning/r/Account/' + comment.ParentId + '/view"> ' + feedParentAccounts.get(comment.ParentId).Name + ' <a/> By <a href="' + ORG_URL + '/' + comment.CreatedById + '"' +'  >' + usersMap.get(comment.CreatedById).FirstName + ' ' + usersMap.get(comment.CreatedById).LastName  + ' </a><br><br>' + 
                                            'To view/Reply click on the link <a href="' + ORG_URL + '/' + comment.FeedItemId + '">' + ORG_URL + '/' + comment.id +' </a>' +
                                        '</p>' ;   
                    
                    List<String> emailsToSend = new List<String>(emails);
                    testEmails = emailsToSend;
                    EmailService.sendEmails(senderName, emailsToSend, subject, bodyText);  
                }
            }
        }
    }
}