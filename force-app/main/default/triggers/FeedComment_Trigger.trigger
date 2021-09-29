/**
 * @description       : 
 * @author            : Deepak Prajapati (d.prajapati@concret.io)
 * @last modified on  : 29-09-2021
 * @last modified by  : Deepak Prajapati (d.prajapati@concret.io)
************************************/
trigger FeedComment_Trigger on FeedComment (after insert, after update) {
    
    String INSERTED_COMMENT = 'A New Comment Has Been Added';
    String UPDATED_COMMENT = 'A Comment Has Been Updated';

    /* Get All Followers Email exept mentioned users */
    List<String> allEmails = FeedComment_TriggerHelper.FeedComment_TriggerHelperAfterInsert(Trigger.new);

    /* Get Comment Body and Post Body */
    FeedComment_TriggerHelper.PostCommentWrapper bodyText = FeedComment_TriggerHelper.getCommentBody(Trigger.new);
    if (!allEmails.isEmpty()) {
        if (Trigger.isInsert) {
            FeedComment_TriggerHelper.sendCommentEmailToFollowers(allEmails,INSERTED_COMMENT,bodyText);
        }else if (Trigger.isUpdate) {
            FeedComment_TriggerHelper.sendCommentEmailToFollowers(allEmails,UPDATED_COMMENT,bodyText);
        }
    }
}