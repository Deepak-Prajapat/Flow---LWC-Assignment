/**
 * @description       : 
 * @author            : Deepak Prajapati (d.prajapati@concret.io)
 * @group             : 
 * @last modified on  : 05-10-2021
 * @last modified by  : Deepak Prajapati (d.prajapati@concret.io)
**/
@isTest
public with sharing class ChatterPostTest_Utility {

    public static String acccId;
    public static String testUser1;
    public static String testUser2;
    public static String acccId2;
    /**
    * @description create an account record for testing
    * @author Deepak Prajapati (d.prajapati@concret.io) | 29-09-2021 
    * @return String -> account id
    *************************************************/
    public static Id getTestAccount(Integer count) {
         Id accountId;
        if (count == 1) {
            Account acc = new Account();
            acc.Name = 'For Testing1';
            insert acc;
            accountId = acc.id;
        }else if (count == 2) {
            Account acc2 = new Account();
            acc2.Name = 'For Testing2';
            insert acc2;
            accountId = acc2.id;
        }
      return accountId;
    }


    /**
    * @description : Create a Test User
    * @author Deepak Prajapati (d.prajapati@concret.io) | 29-09-2021 
    * @return String user's Id
    **/
    public static String getTestUser1() {
        Profile p = [select id, name from Profile where name = 'Standard User' LIMIT 1];

    /* Create 2 User */
        User follower = new User();
        follower.Username = 'test78909@samp.com';
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

    /**
    * @description : Create another Test User
    * @author Deepak Prajapati (d.prajapati@concret.io) | 29-09-2021 
    * @return String user's Id
    **/
    public static String getTestUser2() {
        Profile p = [select id, name from Profile where name = 'Standard User' LIMIT 1];
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
    /**
    * @description Add user to account record's ffollower list
    * @author Deepak Prajapati (d.prajapati@concret.io) | 29-09-2021 
    **************************************/
    public static void makeFollowers() {
        /* Make User as a follower of acc */
        EntitySubscription es = new EntitySubscription();
        es.ParentId = getTestAccount(1);
        es.SubscriberId = getTestUser1();
        testUser1 = es.SubscriberId;
        acccId = es.ParentId;
        insert es;
        acccId = es.Id;
        /* Make User2 as a follower of acc */

        EntitySubscription es2 = new EntitySubscription();
        es2.ParentId = es.ParentId;
        es2.SubscriberId = getTestUser2();
        testUser2 = es2.SubscriberId;
        insert es2;

        EntitySubscription es3 = new EntitySubscription();
        es3.ParentId = getTestAccount(2);
        acccId2 = es3.ParentId;
        es3.SubscriberId = testUser2;
        insert es3;
    }

}