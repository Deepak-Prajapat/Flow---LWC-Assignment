/**
 * @description       : 
 * @author            : Deepak Prajapati (d.prajapati@concret.io)
 * @last modified on  : 04-10-2021
 * @last modified by  : Deepak Prajapati (d.prajapati@concret.io)
************************************/
trigger FeedComment_Trigger on FeedComment (after insert, after update) {
    if (Trigger.isInsert) {
        FeedComment_TriggerHandler.FeedComment_Trigger(Trigger.new, 'INSERT');
    }else if (Trigger.isUpdate) {
        FeedComment_TriggerHandler.FeedComment_Trigger(Trigger.new, 'UPDATE');
    }

}