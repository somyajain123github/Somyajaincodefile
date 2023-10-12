/**
 * @description       : Account Trigger
**/
trigger OnCreationofAccount on Account (before insert, after insert, before update) {
    ActivationOfAccounthandler accountTriggerObj = new ActivationOfAccounthandler();
    accountTriggerObj.runTriggerMethod();
}