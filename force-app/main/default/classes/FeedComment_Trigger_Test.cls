/**
 * @description       : 
 * @author            : Deepak Prajapati (d.prajapati@concret.io)
 * @group             : 
 * @last modified on  : 05-10-2021
 * @last modified by  : Deepak Prajapati (d.prajapati@concret.io)
************************************************************/
@isTest(seeAllData = true)
public with sharing class FeedComment_Trigger_Test {

    public static Final String COMMUNITY_ID = null;

    @isTest
     static void FeedComment_Trigger_Test() {
         /* Create Required Data and Assign followers */
        ChatterPostTest_Utility.makeFollowers();

        Account tempAcc = [select id from account where name = 'For Testing1' limit 1];

        FeedItem feed = new FeedItem (
            parentid = tempAcc.id,
            type = 'ContentPost',
            Body = 'Sample Feed Body'
        );  
        insert feed;

        ConnectApi.CommentInput commentInput = new ConnectApi.CommentInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();

        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

        textSegmentInput.text = 'Sample Text ? ';
        messageBodyInput.messageSegments.add(textSegmentInput);

        mentionSegmentInput.id = ChatterPostTest_Utility.testUser1;
        messageBodyInput.messageSegments.add(mentionSegmentInput);

        commentInput.body = messageBodyInput;

        Test.startTest();
            ConnectApi.Comment commentRep = ConnectApi.ChatterFeeds.postCommentToFeedElement(COMMUNITY_ID, feed.Id, commentInput, null);    
        Test.stopTest();      

        System.assert(!FeedComment_TriggerHandler.testemails.contains('test@samp.com'));
        System.assert(FeedComment_TriggerHandler.testemails.contains('test@samp2.com'));
    }
}