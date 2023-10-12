/**
* @description       : Account Creation
**/
public class ActivationOfAccounthandler {
    /**
* @description this method is used to call the trigger events method
**/
    public void runTriggerMethod() {
        if(Trigger.isBefore && Trigger.isInsert) {
            checkActiveAccount(Trigger.new);
        }
        else if(Trigger.isAfter && Trigger.isInsert) {
            createdtwoteamMembers(Trigger.new);
        }
        else if(Trigger.isBefore && Trigger.isUpdate) {
            Map<Id, Account> newMap = (Map<Id, Account>) Trigger.newMap;
            beforeUpdate(Trigger.new, newMap);
        }
    }
    /**
* @description execute on before insert to validate any active account should not to be inserted
* @param Account_List new account list from trigger.new
**/
    static void checkActiveAccount(List<Account> Account_List) {
        for(Account each : Account_List) {
            if(each.Active__c) {
                each.addError('Active account not be created');
            }
        }
    }
    /**
* @description execute on after insert to create two associated Team Members of account
* @param Account_List new account list from trigger.new
**/
    static void createdtwoteamMembers(List<Account> Account_List){
        try {
            List<SQX_Team_Members__c> memberList = new List<SQX_Team_Members__c>();
            for(Account eachAcc : Account_List) {
                memberList.add(New SQX_Team_Members__c(Name='Team Member 1',Account__c=eachAcc.id));
                memberList.add(New SQX_Team_Members__c(Name='Team Member 2',Account__c=eachAcc.id));
                
            }
            if(!memberList.isEmpty()) {
                insert memberList;
            }
        } catch(Exception e) {
            System.debug('Message>>' + e.getMessage() + ' at line>>'+e.getLineNumber());
            throw e;
        }
    }
    /**
* @description execute on before update which prevent account should not be activated those have not permission set assigned and if assigned then the related team member of account should have HR and Admin in member type
* @param Account_List new account list from trigger.new
* @param newAccMap new account map from trigger.newMap
**/
    static void beforeUpdate(List<Account> Account_List, Map<Id, Account> newAccMap) {
        try{
            Map<Id, Set<String>> accountAndMemberType = new Map<Id, Set<String>>();
            for(SQX_Team_Members__c eachMem : [SELECT Id, Account__c, Member_Type__c FROM SQX_Team_Members__c WHERE Account__c IN :newAccMap.keySet()]) {
                if(!accountAndMemberType.containsKey(eachMem.Account__c)) {
                    accountAndMemberType.put(eachMem.Account__c, new Set<String>());
                }
                accountAndMemberType.get(eachMem.Account__c).add(eachMem.Member_Type__c);
            }
            List<PermissionSetAssignment> getAssignment = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSet.Name = 'Account_Admin'];
            for(Account eachAcc : Account_List) {
                if(eachAcc.Active__c && getAssignment.isEmpty()) {
                    eachAcc.addError('Account cannot be activated because Account_Admin PermissionSet not assigned to user');
                }
                else if(eachAcc.Active__c && (!accountAndMemberType.get(eachAcc.Id).contains('HR') || !accountAndMemberType.get(eachAcc.Id).contains('Admin'))) {
                    eachAcc.addError('Account cannot be activated because Team member with HR and Admin not found');
                }
            }
        } catch(Exception e) {
            System.debug('Message>>' + e.getMessage());
            throw e;
        }
    }
}