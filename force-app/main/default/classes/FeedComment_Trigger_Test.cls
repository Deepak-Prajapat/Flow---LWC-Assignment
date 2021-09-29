/**
 * @description       : 
 * @author            : Deepak Prajapati (d.prajapati@concret.io)
 * @group             : 
 * @last modified on  : 29-09-2021
 * @last modified by  : Deepak Prajapati (d.prajapati@concret.io)
**/
@isTest(seeAllData = true)
public with sharing class FeedComment_Trigger_Test {
    @isTest
     static void FeedComment_Trigger_Test() {
        ChatterPostTest_Utility.makeFollowers();
        FeedItem feedPost = new FeedItem();
        feedPost.body = '<p><b>FeedItem</b></p>';
        feedPost.createdById = ChatterPostTest_Utility.testUser1;
        feedPost.ParentId = ChatterPostTest_Utility.testAccountId;
        feedPost.isRichText = true;
        try {
            insert feedPost;
        } catch (Exception e) {
            System.debug(e);
        }

        String communityId = null;
        String feedElementId = feedPost.Id;
        System.debug(feedPost.id);
        ConnectApi.CommentInput commentInput = new ConnectApi.CommentInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();

        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

        textSegmentInput.text = 'Does anyone in this group have an idea? ';
        messageBodyInput.messageSegments.add(textSegmentInput);

        mentionSegmentInput.id = ChatterPostTest_Utility.testUser1;
        messageBodyInput.messageSegments.add(mentionSegmentInput);
        commentInput.body = messageBodyInput;
        Test.startTest();
        try {
            ConnectApi.Comment commentRep = ConnectApi.ChatterFeeds.postCommentToFeedElement(communityId, feedPost.Id, commentInput, null);
        } catch (Exception w) {
            System.debug(w);
        }
        Test.stopTest();

        /* A @TestVisible-> testemails variable to assertion */
        List<String> mail = FeedComment_TriggerHelper.testemails;

        /* Assertions */
        System.assert(!mail.contains('test@samp.com'));
        System.assert(mail.contains('test@samp2.com'));
        System.assertEquals(1,mail.size());
    }
}
