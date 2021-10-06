/**
 * @description       : 
 * @author            : Deepak Prajapati (d.prajapati@concret.io)
 * @last modified on  : 06-10-2021
 * @last modified by  : Deepak Prajapati (d.prajapati@concret.io)
************************************/
trigger FeedComment_Trigger on FeedComment (after insert, after update) {
    if (Trigger.isInsert) {
        FeedComment_TriggerHandler.notifyFollowers(Trigger.new);
    }else if (Trigger.isUpdate) {
        FeedComment_TriggerHandler.notifyFollowers(Trigger.new);
    }
}