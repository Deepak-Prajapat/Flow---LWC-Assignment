/**
 * @description       : 
 * @author            : Deepak Prajapati (d.prajapati@concret.io)
 * @group             : 
 * @last modified on  : 29-09-2021
 * @last modified by  : Deepak Prajapati (d.prajapati@concret.io)
******************    *************/
trigger FeedItem_Trigger on FeedItem (after insert, after update) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            FeedItem_TriggerHelper.FeedItem_TriggerHelperAfterInsert(Trigger.New , 'INSERT');
        }else if (Trigger.isUpdate) {
            FeedItem_TriggerHelper.FeedItem_TriggerHelperAfterInsert(Trigger.New, 'UPDATE');
        }
    }
}