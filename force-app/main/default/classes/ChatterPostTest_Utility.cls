/**
 * @description       : 
 * @author            : Deepak Prajapati (d.prajapati@concret.io)
 * @group             : 
 * @last modified on  : 29-09-2021
 * @last modified by  : Deepak Prajapati (d.prajapati@concret.io)
**/
@isTest
public with sharing class ChatterPostTest_Utility {
    Public static String testAccountId = getTestAccount();
    Public static String testUser1 = getTestUser1();
    Public static String testUser2 = getTestUser2();

    public static String getTestAccount() {
        Account acc = new Account();
        acc.Name = 'For Testing';
        insert acc;
        return acc.id;
    }


    public static String getTestUser1() {
        Profile p = [select id, name from Profile where name = 'Standard User' LIMIT 1];
        System.debug('profile ' + p);

        /* Create 2 User */
            User follower = new User();
            follower.Username = 'test7890@samp.com';
            follower.LastName = 'lastName';
            follower.Email = 'test@samp.com';
            follower.Alias = 'tsamp';
            follower.ProfileId = p.Id;
            follower.IsActive = true;  // here we are creating inactive user account
            follower.TimeZoneSidKey = 'America/Los_Angeles'; 
            follower.LocaleSidKey = 'en_US';
            follower.LanguageLocaleKey = 'en_US';
            follower.EmailEncodingKey = 'ISO-8859-1'; 
            insert follower;  // insert the user record
            return follower.Id;
        }
    
    public static String getTestUser2() {
        Profile p = [select id, name from Profile where name = 'Standard User' LIMIT 1];
        System.debug('profile ' + p);
        User follower2 = new User();
            follower2.Username = 'test7890@samp2.com';
            follower2.LastName = 'lastName';
            follower2.Email = 'test@samp2.com';
            follower2.Alias = 'tsamp';
            //follower.UserRoleId = ur.id;
            follower2.ProfileId = p.Id;
            follower2.IsActive = true;  // here we are creating inactive user account
            follower2.TimeZoneSidKey = 'America/Los_Angeles'; 
            follower2.LocaleSidKey = 'en_US';
            follower2.LanguageLocaleKey = 'en_US';
            follower2.EmailEncodingKey = 'ISO-8859-1'; 
            insert follower2;  
            return follower2.id;
    }
    public static void makeFollowers() {
        /* Make User as a follower of acc */
        EntitySubscription es = new EntitySubscription();
        es.ParentId = testAccountId;
        es.SubscriberId = testUser1;
        insert es;
        
        /* Make User2 as a follower of acc */
        EntitySubscription es2 = new EntitySubscription();
        es2.ParentId = testAccountId;
        es2.SubscriberId = testUser2;
        insert es2;
    }
}
