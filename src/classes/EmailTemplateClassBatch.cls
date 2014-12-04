global class EmailTemplateClassBatch implements Database.Batchable<sObject>, Database.Stateful {

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id, Body, Subject, DeveloperName, Name, HtmlValue FROM EmailTemplate]);
    }
    
    global void execute(Database.BatchableContext BC, List<EmailTemplate> templates){
        EmailTemplateClass.insertWithChildren(templates);
    }
    
    global void finish(Database.BatchableContext BC){}
}