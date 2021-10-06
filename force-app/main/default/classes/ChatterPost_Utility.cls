/**
 * @description       : An helper class for Chatter Post Assignment
 * @author            : Deepak Prajapati (d.prajapati@concret.io)
 * @last modified on  : 06-10-2021
 * @last modified by  : Deepak Prajapati (d.prajapati@concret.io)
**************************/
public with sharing class ChatterPost_Utility {

    /******
     * Wrapper for store users and emails 
     **********************/
    public class FollowersWrapper{
         public List<String> emails = new List<String>();
         public Set<Id> users = new Set<Id>();
    }

    /**********************************************
    * @description Get Followers Details in a Grouped form
    * @author Deepak Prajapati (d.prajapati@concret.io) | 04-10-2021 
    * @param Set<Id> parentIds ----> In This Case Account Ids
    * @return Map<Id, FollowersWrapper> ----> Id: AccountId, FollowerWrapper: That Contains userid list and follower emails 
    *************************************************/
    public static Map<Id, FollowersWrapper> getFollowersByAccount(Set<Id> parentIds){

        Map<Id, FollowersWrapper> followersMap = new Map<Id, FollowersWrapper>();
        Set<Id> idsSubscriber = new Set<Id>();

        for (ID parentId : parentIds) {
            followersMap.put(parentId, new FollowersWrapper());
        }
    
        List<EntitySubscription> followers = [  SELECT  SubscriberId,
                                                        ParentId,
                                                        id 
                                                FROM EntitySubscription 
                                                WHERE ParentId IN :parentIds LIMIT 999 ];
        for (EntitySubscription follower : followers) {
            idsSubscriber.add(follower.SubscriberId);
        }
        
        /* All Subscribers */
        Map<Id, User> subscribersMap = new Map<Id, User>([  SELECT  Id, 
                                                                    Email 
                                                            FROM User 
                                                            WHERE Id IN :idsSubscriber]);

        for (EntitySubscription es : followers) {
            followersMap.get(es.ParentId).users.add(es.SubscriberId);
            followersMap.get(es.ParentId).emails.add(subscribersMap.get(es.SubscriberId).Email);
        }
        return followersMap;
    }


    public static List<Id> postMentionedUsers(Id feedId){
        List<ID> idsOfMentionedUsers = new List<ID>();
        ConnectApi.FeedElement feedItem = ConnectApi.ChatterFeeds.getFeedElement(null, feedId);
        List<ConnectApi.MessageSegment> messageSegments = FeedItem.body.messageSegments;
        for (ConnectApi.MessageSegment messageSegment : messageSegments) {
            if (messageSegment instanceof ConnectApi.MentionSegment) {
                ConnectApi.MentionSegment mentionSegment = (ConnectApi.MentionSegment) messageSegment;
                idsOfMentionedUsers.add(mentionSegment.record.id);
            }
        }
        return idsOfMentionedUsers;
    }

    public static List<Id> commentMentionedUsers(Id commentId){
        List<ID> idsOfMentionedUsers = new List<ID>();
        ConnectApi.Comment comment = ConnectApi.ChatterFeeds.getComment(null, commentId);
        List<ConnectApi.MessageSegment> messageSegments = comment.body.messageSegments;
        for (ConnectApi.MessageSegment messageSegment : messageSegments) {
            if (messageSegment instanceof ConnectApi.MentionSegment) {
                ConnectApi.MentionSegment mentionSegment = (ConnectApi.MentionSegment) messageSegment;
                idsOfMentionedUsers.add(mentionSegment.record.id);
            }
        }
        return idsOfMentionedUsers;
    }
}