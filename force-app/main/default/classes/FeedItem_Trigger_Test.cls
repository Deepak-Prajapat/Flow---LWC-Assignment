/**
 * @description       : 
 * @author            : Deepak Prajapati (d.prajapati@concret.io)
 * @group             : 
 * @last modified on  : 29-09-2021
 * @last modified by  : Deepak Prajapati (d.prajapati@concret.io)
**/
@isTest(seeAllData = true)
public with sharing class FeedItem_Trigger_Test {
    @IsTest
    static void postInsertionandUpdationTest() {
        
        /* Create Users and make them account's follower */
        ChatterPostTest_Utility.makefollowers();

        /* Create a FeedItem for testing with mentioned user */
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();

        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

        mentionSegmentInput.id = ChatterPostTest_Utility.testUser1;
        messageBodyInput.messageSegments.add(mentionSegmentInput);

        textSegmentInput.text = 'Could you take a look?';
        messageBodyInput.messageSegments.add(textSegmentInput);

        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = ChatterPostTest_Utility.testAccountId;

        // Testing For Insertion
        Test.startTest();
            /* Insert Chatter Post */
            ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
            
            /* A @TestVisible-> testemails variable to assertion */
            List<String> mail = FeedItem_TriggerHelper.oneEmail;

            /* Assertions */
            System.assert(!mail.contains('test@samp.com'));
            System.assert(mail.contains('test@samp2.com'));
            System.assertEquals(1,mail.size());

        Test.stopTest();
        
    }
}
