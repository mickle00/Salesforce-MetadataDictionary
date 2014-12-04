@isTest(seeAllData=False)
private class EmailTemplateClass_Test{
  static testMethod void shouldGetLanguageIdToEmailTemplateIdMap(){
    Folder myTestFolder = [SELECT Id, DeveloperName FROM Folder WHERE Type = 'email' LIMIT 1]; // can't do DML on folders
    system.debug(myTestFolder);
    User testUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = TRUE LIMIT 1];
    //hacktacular way of preventing mixed-dml exception for inserting setup and non-setup objects at the same time
    system.runAs(testUser){
      List<EmailTemplate> emailTemplates = new List<EmailTemplate>();
      EmailTemplate myEnglishTemplate = new EmailTemplate (Name = 'EN Test', DeveloperName = 'EN_Test', FolderId = myTestFolder.Id, templateType = 'text', Body = 'What is up, dawg?', Subject = 'Test Email');
      emailTemplates.add(myEnglishTemplate);
      EmailTemplate myFakeTemplate = new EmailTemplate (Name = 'Fake Test', DeveloperName = 'FakeTest', FolderId = myTestFolder.Id, templateType = 'text', Body = 'What is up, dawg?', Subject = 'Test Email');
      emailTemplates.add(myFakeTemplate);
      insert emailTemplates;
    }
    EmailTemplate myEnglishTemplate = [SELECT Id FROM EmailTemplate WHERE Name = 'EN Test' LIMIT 1];
    Language__c englishLanguage = new Language__c(Name = 'English', EPC_Language_Code__c = 'EN');
    insert englishLanguage;
    Language__c spanishLanguage = new Language__c(Name = 'Spanish', EPC_Language_Code__c = 'ES');
    insert spanishLanguage;

    Map<Id, Id> languageIdToTemplateIdMap = EmailTemplateClass.getLanguageIdToTemplateIdMap(myTestFolder.DeveloperName, '%Test');
    system.assertEquals(languageIdToTemplateIdMap.get(englishLanguage.id), myEnglishTemplate.Id);
    //system.assertEquals(languageIdToTemplateIdMap.get(spanishLanguage.id), NULL); // don't have a spanish template
  }

  // See: REQ-03130
  // Ensures that email templates, languages and folders are configured properly and present
  // See all data required, however only tested in Prod
  @isTest(seeAllData=True)
  static void meetsDirectDebitEmailChaserAutomationDependencies(){
    // Only testing dependencies in Production, as to not cause tests to fail in devorgs
    if (Utilities.isProductionOrg() || Utilities.isPreProductionOrg()){
      Integer NUMBER_OF_DIRECT_DEBIT_LANGUAGES_SUPPORTED = 10;
      Folder directDebitChaserFolder = [SELECT Id, DeveloperName FROM Folder WHERE DeveloperName  = 'Direct_Debit_Support' LIMIT 1];
      Map<Id, Id> languageIdToTemplateIdMap = EmailTemplateClass.getLanguageIdToTemplateIdMap(directDebitChaserFolder.DeveloperName, '%Direct_Debit_Mandate_Chase');

      system.assert(languageIdToTemplateIdMap.keySet().size() >= NUMBER_OF_DIRECT_DEBIT_LANGUAGES_SUPPORTED, 'Not all of the dependecies for the automated direct debit email chaser are met. See REQ-03130');
    }
  }
}