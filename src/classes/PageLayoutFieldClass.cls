public with sharing class PageLayoutFieldClass{

    public static List<Page_Layout_Field__c> build(PageLayoutClass layout){
        List<Page_Layout_Field__c> pageLayoutFields = new List<Page_Layout_Field__c>();
        for (String field : layout.getFields()){
            if (isCustomField(field)){
                pageLayoutFields.add(
                    new Page_Layout_Field__c(
                         Name = layout.getName() + '-' + field
                        ,Unique_Name__c = layout.getName() + '-' + field 
                        ,Page_Layout__r = new Page_Layout__c(Unique_Name__c = layout.getName())
                        ,Field__r = new Field__c(Unique_Name__c = layout.getObjectName() + '.' + field)
                    )
                );
            }
        }

        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.allowFieldTruncation = true;

        for (Page_Layout_Field__c plf : pageLayoutFields){
            plf.setOptions(dmo);
        }
        return pageLayoutFields;
    }

    private static boolean isCustomField(string fieldName){
        if (fieldName == null) return false;
        if (fieldName == 'null') return false;
        return fieldName.endsWith('__c');
    }
}