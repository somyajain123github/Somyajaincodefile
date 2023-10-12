@isTest
public class ActivtaionOfAccounthandler_Test {
    @TestSetup
    static void makeData() {
        Account acc1 = new Account();
        acc1.Name = 'Test Account 1';
        
        Account acc2 = new Account();
        acc2.Name = 'Test Account 2';
        
        List<Account> accList = new List<Account>{acc1, acc2};
            insert accList;
    }
    @isTest
    static void testAccountBeforeInsert() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser909877@test.com');
        insert u;
        System.runAs(u) {
            try {
                Account acc = new Account();
                acc.Name = 'Account Test';
                acc.Active__c = true;
                insert acc;
            }
            catch(Exception ex) {
                Boolean expectedExceptionThrown =  ex.getMessage().contains('Active account not be created') ? true : false;
                System.assertEquals(expectedExceptionThrown, true);
            }
        }
    }
    @isTest
    static void testAccountAfterInsert() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser5125315@test.com');
        insert u;
        System.runAs(u) {
            Account acc = new Account();
            acc.Name = 'Test Account';
            insert acc;
            List<SQX_Team_Members__c> getTeamMembers = [SELECT Id FROM SQX_Team_Members__c WHERE Account__c =: acc.Id];
            System.assertEquals(getTeamMembers.size() == 2, true);
        }
    }
   @isTest
    static void testAccountBeforeUpdate() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser12323646@test.com');
        insert u;
        System.runAs(u) {
            List<Account> getAccount = [SELECT Id, Active__c FROM Account];
            for(Account eachAcc : getAccount) {
                eachAcc.Active__c = true;
            }
            try {
                update getAccount;
            }
            catch(Exception ex) {
                Boolean expectedExceptionThrown =  ex.getMessage().contains('Account cannot be activated because Account_Admin PermissionSet not assigned to user') ? true : false;
                System.assertEquals(expectedExceptionThrown, true);
            }
            PermissionSetAssignment pmAssign = new PermissionSetAssignment();
            pmAssign.AssigneeId = u.Id;
            pmAssign.PermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'Account_Admin'].Id;
            insert pmAssign;
            try {
                update getAccount;
            }
            catch(Exception ex) {
                Boolean expectedExceptionThrown =  ex.getMessage().contains('Account cannot be activated because Team member with HR and Admin not found') ? true : false;
                System.assertEquals(expectedExceptionThrown, true);
            }
        }
    }
}