/**
 * @description       : An helper class for Chatter Post Assignment
 * @author            : Deepak Prajapati (d.prajapati@concret.io)
 * @group             : 
 * @last modified on  : 28-09-2021
 * @last modified by  : Deepak Prajapati (d.prajapati@concret.io)
**************************/
public with sharing class ChatterPostHelper {
    /**
    * @description -> To get the Set of ids of all followers from a chatter's parent
    * @author Deepak Prajapati (d.prajapati@concret.io) | 28-09-2021 
    * @param String parentIdOfObj -> Parent Id (Account) from Chatter
    * @return Set<ID> -> All follower's Ids
    **/
    public static Set<ID> getFollowerIdsForChatter(String parentIdOfObj){
        List<EntitySubscription> followers = [  SELECT SubscriberId,
                                                       id 
                                                FROM EntitySubscription 
                                                WHERE ParentId =: parentIdOfObj ];
        
        Set<ID> idsOfFollowers = new Set<ID>();    
        for(EntitySubscription follower: followers){
                idsOfFollowers.add( follower.SubscriberId );
        }
        return idsOfFollowers;
    }

    /**
    * @description -> To Get emails in a list of string from user Ids
    * @author Deepak Prajapati (d.prajapati@concret.io) | 28-09-2021 
    * @param Set<Id> userIds 
    * @return List<String> -> Emails of users
    **/
    public static List<String> getEmailsOfUsers(Set<Id> userIds){
        List<User> userFollowers = [SELECT Email FROM User WHERE Id IN :userIds];
        
        List<String> emailsOfFollowers = new List<String>();
        For(User u: userFollowers){
            emailsOfFollowers.add(u.Email);
        }

        return emailsOfFollowers;
    }

    // public static List<ID> getMentionedUsers(String feedId){
    //     List<ID> idsOfMentionedUsers = new List<ID>();

    //     ConnectApi.FeedElement feedItem = ConnectApi.ChatterFeeds.getFeedElement(null, feedId);
    //     List<ConnectApi.MessageSegment> messageSegments = FeedItem.body.messageSegments;
    //     for (ConnectApi.MessageSegment messageSegment : messageSegments) {
    //         if (messageSegment instanceof ConnectApi.MentionSegment) {
    //             ConnectApi.MentionSegment mentionSegment = (ConnectApi.MentionSegment) messageSegment;
    //             idsOfMentionedUsers.add(mentionSegment.record.id);
    //         }
    //     }

    //     return idsOfMentionedUsers;
    // }
}
