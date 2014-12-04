public with sharing class EmailTemplateFieldClass{

    public Email_Template_Field__c emailTemplateFieldObj;
    public MergeField mergeField;
    public String emailTemplateDevName;

    public EmailTemplateFieldClass(string emailTemplateDevName, MergeField mergeField){
        this.mergeField = mergeField;
        this.emailTemplateDevName = emailTemplateDevName;
        this.emailTemplateFieldObj = new Email_Template_Field__c(
                Name = 'Test'
               ,Email_Template__r = new Email_Template__c(Unique_Name__c = emailTemplateDevName)
               ,Field__r = new Field__c(Unique_Name__c = this.mergeField.getFieldKey())
               ,Unique_Key__c = this.getUniqueKey()
        );
    }

    public string getUniqueKey(){
        return this.emailTemplateDevName + mergeField.getFieldKey();
    }

    public static List<Email_Template_Field__c> buildTemplateFields(EmailTemplateClass emailTemplate){
        List<MergeField> mergeFields = parseTemplate(emailTemplate);
        List<Email_Template_Field__c> emailTemplateFields = new List<Email_Template_Field__c>();
        for (MergeField mergeField : mergeFields){
            EmailTemplateFieldClass emailTemplateField = new EmailTemplateFieldClass(
                    emailTemplate.getUniqueName(), mergeField);
            emailTemplateFields.add(emailTemplateField.emailTemplateFieldObj);
        }

        return emailTemplateFields;
    }

    public static List<MergeField> parseTemplate(EmailTemplateClass emailTemplate){
        Set<String> mergeStrings = new Set<String>();
        List<MergeField> mergeFields = new List<MergeField>();
        string MERGE_FIELD_REGEX = '\\{\\!(\\w+\\.\\w+)\\}';
        Pattern p = Pattern.compile(MERGE_FIELD_REGEX);
        //TODO: Parse Subject & HTML as well
        Matcher m;
        if (emailTemplate.emailTemplate.HtmlValue != null){
            m = p.matcher(emailTemplate.emailTemplate.HtmlValue);
            while (m.find()){
                mergeStrings.add(m.group(1));
            }
        }
        if (emailTemplate.emailTemplate.Body != null){
            m = p.matcher(emailTemplate.emailTemplate.Body);
            while (m.find()){
                mergeStrings.add(m.group(1));
            }
        }
        if (emailTemplate.emailTemplate.Subject != null){
            m = p.matcher(emailTemplate.emailTemplate.Subject);
            while (m.find()){
                mergeStrings.add(m.group(1));
            }
        }
        for (String mergeString : mergeStrings){
            if(mergeString.endsWith('__c')){
                mergeFields.add(new MergeField(mergeString));
            }
        }
        return mergeFields;
    }

    public class MergeField{
        public string sObjectName;
        public string fieldName;

        public MergeField(string fullMergeField){
            this.sObjectName = fullMergeField.split('\\.')[0];
            this.fieldName = fullMergeField.split('\\.')[1];
        }

        public MergeField(string sObjectName, string fieldName){
            this.sObjectName = sObjectName;
            this.fieldName = fieldName;
        }

        public string getFieldKey(){
            return this.sObjectName + '.' + this.fieldName;
        }
    }
}