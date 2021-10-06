/**
 * @description       : FeedItem Trigger
 * @author            : Deepak Prajapati (d.prajapati@concret.io)
 * @last modified on  : 06-10-2021
 * @last modified by  : Deepak Prajapati (d.prajapati@concret.io)
******************    *************/
trigger FeedItem_Trigger on FeedItem (after insert, after update) {
    if (Trigger.isInsert) {
        FeedItem_TriggerHandler.notifyFollowers(Trigger.New);
    }else if (Trigger.isUpdate) {
        FeedItem_TriggerHandler.notifyFollowers(Trigger.New );
    }
}