global class FieldClassBatch implements Database.Batchable<sObject>, Database.Stateful {

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id, Name, API_Name__c FROM sObject__c]);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject__c> sObjects){
        for (sObject__c sObj : sObjects){
            FieldClass.findAndInsertSObjectFields(sObj.API_Name__c);
        }
    }
    
    global void finish(Database.BatchableContext BC){}
}