/**
 * @description       : A class that contains static methods related to email service
 * @author            : Deepak Prajapati (d.prajapati@concret.io)
 * @last modified on  : 05-10-2021
 * @last modified by  : Deepak Prajapati (d.prajapati@concret.io)
**/
public with sharing class EmailService {
    /**************************************************************
    * @description Send Email to all followers accordingly for Insert operation and Update Operation for COMMENTS
    * @author Deepak Prajapati (d.prajapati@concret.io) | 28-09-2021 
    * @param List<String> emails -> All user emails
    * @param String text  -> Either INSERT or UPDATE
    * @param FeedComment_TriggerHelper.PostCommentWrapper bodyText -> Wrapper that have post's body and comment's body 
    ****************************************************************/
    public static void sendEmailToFollowers(  String senderName, 
                                    List<String> emailIds,
                                    String subject, 
                                    String bodyText ){

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSenderDisplayName(senderName);
        mail.setToAddresses(emailIds);
        mail.setSubject(subject);
        mail.setHtmlBody(bodyText);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}