/**********************************************************************************************
 * @description       : 
 * @author            : Deepak Prajapati (d.prajapati@concret.io)
 * @group             : 
 * @last modified on  : 29-09-2021
 * @last modified by  : Deepak Prajapati (d.prajapati@concret.io)
************************************************************************************************/
public with sharing class FeedItem_TriggerHelper {
    @TestVisible public static List<String> oneEmail;
    /**
    * @description Method for sending email to Account Followers
    * @author Deepak Prajapati (d.prajapati@concret.io) | 28-09-2021 
    * @param List<FeedItem> feedItemList --> Trigger.New  
    * @param String operationType  --> Either Insert or Update
    ***************************/
    public static void FeedItem_TriggerHelperAfterInsert(List<FeedItem> feedItemList, String operationType) {
        String accId = feedItemList[0].ParentId;
        Account acc = [ SELECT ID,Name FROM Account WHERE ID =: accId ];
        ID feedId = feedItemList[0].id;

        /* Get List of Mentioned Users */
        List<ID> idsOfMentionedUsers = new List<ID>();

        ConnectApi.FeedElement feedItem = ConnectApi.ChatterFeeds.getFeedElement(null, feedId);
        List<ConnectApi.MessageSegment> messageSegments = FeedItem.body.messageSegments;
        for (ConnectApi.MessageSegment messageSegment : messageSegments) {
            if (messageSegment instanceof ConnectApi.MentionSegment) {
                ConnectApi.MentionSegment mentionSegment = (ConnectApi.MentionSegment) messageSegment;
                idsOfMentionedUsers.add(mentionSegment.record.id);
            }
        }

        /* Get Followers */
        Set<ID> idsOfFollowers = ChatterPostHelper.getFollowerIdsForChatter(accId);
        idsOfFollowers.removeAll(idsOfMentionedUsers);
        idsOfFollowers.remove(feedItemList[0].CreatedById);

         List<String> emailsOfUsers = ChatterPostHelper.getEmailsOfUsers(idsOfFollowers);
         oneEmail = emailsOfUsers; 
         if(!emailsOfUsers.isEmpty()){
            if (operationType == 'INSERT') {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setSenderDisplayName(acc.Name);
                    mail.setToAddresses(emailsOfUsers);
                    mail.setSubject('A new post is available on ' + acc.Name + ' that you followed');
                    mail.setPlainTextBody(FeedItem.body.text);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }else if (operationType == 'UPDATE') {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setSenderDisplayName(acc.Name);
                    mail.setToAddresses(emailsOfUsers);
                    mail.setSubject('A post is updated available on ' + acc.Name + ' that you followed');
                    mail.setPlainTextBody(FeedItem.body.text);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
         }
        
    }
}
