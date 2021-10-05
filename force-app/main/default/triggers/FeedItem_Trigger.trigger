/**
 * @description       : 
 * @author            : Deepak Prajapati (d.prajapati@concret.io)
 * @group             : 
 * @last modified on  : 04-10-2021
 * @last modified by  : Deepak Prajapati (d.prajapati@concret.io)
******************    *************/
trigger FeedItem_Trigger on FeedItem (after insert, after update) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            FeedItem_TriggerHandler.FeedItem_Trigger(Trigger.New , 'INSERT');
        }else if (Trigger.isUpdate) {
            FeedItem_TriggerHandler.FeedItem_Trigger(Trigger.New , 'UPDATE');
        }
    }
}