public with sharing class EmailTemplateClass{
  public static Map<Id, Id> getLanguageIdToTemplateIdMap(String folderDevName, String uniqueNameLike){
    Map<Id, Id> languageIdToTemplateIdMap = new Map<Id, Id>();
    Map<String, Id> languageCodeToLanguageIdMap = LanguageClass.getLanguageCodeToLanguageIdMap();
    List<EmailTemplate> emailTemplates = [SELECT Id, DeveloperName FROM EmailTemplate WHERE Folder.DeveloperName = :folderDevName AND DeveloperName LIKE :uniqueNameLike];
    for (EmailTemplate myEmailTemplate : emailTemplates){
      string languageCode = getLanguageCodeFromEmailTemplateName(myEmailTemplate.DeveloperName);
      if (String.isNotEmpty(languageCode)){
        languageCode = languageCode.toLowerCase();
        Id languageId = languageCodeToLanguageIdMap.get(languageCode);
        if (languageId != null){
          languageIdToTemplateIdMap.put(languageId, myEmailTemplate.Id);
        }
      }
    }
    return languageIdToTemplateIdMap;
  }

  private static string getLanguageCodeFromEmailTemplateName(String developerName){
    return developerName.substringBefore('_');
  }

  public EmailTemplate emailTemplate;
  public Email_Template__c emailTemplateObj;

  public EmailTemplateClass(EmailTemplate emailTemplate){
      this.emailTemplate = emailTemplate;
      this.emailTemplateObj = new Email_Template__c(
          Name = this.getName()
          ,Unique_Name__c = this.getUniqueName()
          //TODO: Cache LastUsedDate & TimesUsed in Fields with History Tracked
      );
  }

  public string getName(){
      return this.emailTemplate.Name;
  }

  public string getUniqueName(){
      return this.emailTemplate.DeveloperName;
  }

  public static void insertWithChildren(List<EmailTemplate> templates){
      List<EmailTemplateClass> emailTemplates = new List<EmailTemplateClass>();
      for (EmailTemplate emailTemplate : templates){
          emailTemplates.add(new EmailTemplateClass(emailTemplate));
      }
      List<Email_Template__c> emailTemplateObjs = new List<Email_Template__c>();
      List<Email_Template_Field__c> emailTemplateFieldObjs = new List<Email_Template_Field__c>();
      for (EmailTemplateClass emailTemplate : emailTemplates){
          emailTemplateObjs.add(emailTemplate.emailTemplateObj);
          emailTemplateFieldObjs.addAll(EmailTemplateFieldClass.buildTemplateFields(emailTemplate));
      }
      upsert emailTemplateObjs Unique_Name__c;
      upsert emailTemplateFieldObjs Unique_Key__c;
  }
}