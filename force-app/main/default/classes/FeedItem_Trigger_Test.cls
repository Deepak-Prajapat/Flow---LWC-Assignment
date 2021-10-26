/**
 * @description       : 
 * @author            : Deepak Prajapati (d.prajapati@concret.io)
 * @group             : 
 * @last modified on  : 05-10-2021
 * @last modified by  : Deepak Prajapati (d.prajapati@concret.io)
******************************************************/
@isTest(seeAllData = true)
public with sharing class FeedItem_Trigger_Test {
    @IsTest
    static void postInsertionandUpdationTest() {
        /* Create Users and make them account's follower */
        ChatterPostTest_Utility.makefollowers();
        Account tempAcc = [select id from account where name = 'For Testing1' limit 1];
        Account tempAcc2 = [select id from account where name = 'For Testing2' limit 1];

        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();

        for (Integer i = 0; i < 5; i++) {

            ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
            ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
            ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
            ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();

            messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

            /* To Test Bulk Changes */
            if (i < 1) {
                mentionSegmentInput.Id = ChatterPostTest_Utility.testUser2;
            }else {
                mentionSegmentInput.Id = ChatterPostTest_Utility.testUser1;
            }
            
            messageBodyInput.messageSegments.add(mentionSegmentInput);

            textSegmentInput.text = 'My laptop is not working, Could you take a look?' + i ;
            messageBodyInput.messageSegments.add(textSegmentInput);

            feedItemInput.body = messageBodyInput;
            
            if (i < 1) {
                feedItemInput.subjectId = tempAcc.id;
            }else {
                feedItemInput.subjectId = tempAcc2.id;
            }

            batchInputs.add(new ConnectApi.BatchInput(feedItemInput));
        }

        Test.startTest();
            ConnectApi.BatchResult[] feedElement = ConnectApi.ChatterFeeds.postFeedElementBatch(null, batchInputs);
        Test.stopTest();  
        List<String> emailsToTest = FeedItem_TriggerHandler.testEmails.get(0);
        List<String> emailsToTest2 = FeedItem_TriggerHandler.testEmails.get(1);

        System.assert(!emailsToTest.contains('test@samp2.com'));
        System.assert(!emailsToTest2.contains('test@samp.com'));
    }
}