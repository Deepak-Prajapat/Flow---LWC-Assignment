/**                     **************                     ***
 * @description       : Helper class for FeedComment Trigger
 * @author            : Deepak Prajapati (d.prajapati@concret.io)
 * @last modified on  : 29-09-2021
 * @last modified by  : Deepak Prajapati (d.prajapati@concret.io)
**************************************************************/
public with sharing class FeedComment_TriggerHelper {
    @TestVisible public static List<String> testemails;
    /*****************
    * @description a method tha basically filter fetch followers and filter mentioned users from followers
    * @author Deepak Prajapati (d.prajapati@concret.io) | 28-09-2021 
    * @param List<FeedComment> feedComments -> Trigger
    * @return List<String> -> it will return emails of users after filter them by removing mentioned users
    ***************************************/
    public static List<String> FeedComment_TriggerHelperAfterInsert(List<FeedComment> feedComments) {

        /* Parent Post Of Comment */
        FeedItem FI = [ SELECT Title,
                               body,
                               ParentId 
                        FROM FeedItem 
                        WHERE id=: feedComments[0].feedItemId LIMIT 1 ];

        /* Get Followers */
        Set<ID> idsOfFollowers = ChatterPostHelper.getFollowerIdsForChatter(FI.ParentId);

        /* Get Mentioned Users */
        List<ID> idsOfMentionedUsers = new List<ID>();
        ConnectApi.Comment comment = ConnectApi.ChatterFeeds.getComment(null, feedComments[0].Id);
        List<ConnectApi.MessageSegment> messageSegments = comment.body.messageSegments;
        for (ConnectApi.MessageSegment messageSegment : messageSegments) {
            if (messageSegment instanceof ConnectApi.MentionSegment) {
                ConnectApi.MentionSegment mentionSegment = (ConnectApi.MentionSegment) messageSegment;
                idsOfMentionedUsers.add(mentionSegment.record.id);
            }
        }

        /* Filter mentioned user and comment owner */
        idsOfFollowers.removeAll(idsOfMentionedUsers);
        idsOfFollowers.remove(feedComments[0].CreatedById);

        /* Get Email of users that should be updated for comments */
        List<String> emailsOfUsers = ChatterPostHelper.getEmailsOfUsers(idsOfFollowers); 
        testemails = emailsOfUsers;      
        return emailsOfUsers;
    }

    /**************************************************************************
    * @description -> To Get Comment Body and Parent Post Text
    * @author Deepak Prajapati (d.prajapati@concret.io) | 28-09-2021 
    * @param List<FeedComment> feedComments 
    * @return PostCommentWrapper -> A Wrapper that includes 
                                                postBody -> Body Text of POST
                                                commentBody -> Body Of Comment
    *****************************************************************************/
    public static PostCommentWrapper getCommentBody(List<FeedComment> feedComments){

        /* POST BODY */
        ConnectApi.FeedElement feedItem = ConnectApi.ChatterFeeds.getFeedElement(null, feedComments[0].feedItemId);
        List<ConnectApi.MessageSegment> messageBody = FeedItem.body.messageSegments;
        PostCommentWrapper pcw = new PostCommentWrapper();
        pcw.postBody = Feeditem.body.text;

        /* Comment Body */
        ConnectApi.Comment comment = ConnectApi.ChatterFeeds.getComment(null, feedComments[0].Id);
        List<ConnectApi.MessageSegment> messageSegments = comment.body.messageSegments;
        pcw.commentBody = comment.body.text;

        return pcw;
    }

    /********
     *  Wrapper Class For FeedComment and PostBody 
     * *******************/
    public class PostCommentWrapper{
        String postBody;
        String commentBody;
    }

    /**************************************************************
    * @description Send Email to all followers accordingly for Insert operation and Update Operation for COMMENTS
    * @author Deepak Prajapati (d.prajapati@concret.io) | 28-09-2021 
    * @param List<String> emails -> All user emails
    * @param String text  -> Either INSERT or UPDATE
    * @param FeedComment_TriggerHelper.PostCommentWrapper bodyText -> Wrapper that have post's body and comment's body 
    ****************************************************************/
    public static void sendCommentEmailToFollowers(List<String> emails,String text, FeedComment_TriggerHelper.PostCommentWrapper bodyText ){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        System.debug(emails + text + bodyText);
            mail.setSenderDisplayName(bodyText.postBody);
            mail.setToAddresses(emails);
            mail.setSubject(text);
            mail.setPlainTextBody(bodyText.commentBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}
