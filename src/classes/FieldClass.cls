public class FieldClass {
    /** 
    https://www.salesforce.com/us/developer/docs/apexcode/Content/apex_methods_system_fields_describe.htm
    **/

    public Field__c fieldObj;
    
    public FieldClass(Schema.SObjectField sObjField, string objName){
        Schema.DescribeFieldResult describe = sObjField.getDescribe();
        this.fieldObj = new Field__c();
        this.fieldObj.Name = describe.getLabel();
        this.fieldObj.Unique_Name__c = objName + '.' + describe.getName();
        this.fieldObj.sObject__r = new sObject__c(API_Name__c = objName);
        this.fieldObj.Type__c = describe.getType().name();
        this.fieldObj.isCalculated__c = describe.isCalculated();
    }
    
    public static void findAndInsertSObjectFields(string sObjectName){
        List<Field__c> sObjectFields = new List<Field__c>();
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.DescribeSObjectResult r = gd.get(sObjectName).getDescribe();
        Map<String, Schema.SObjectField> fs = r.fields.getMap();
        for (String fieldName : fs.keySet()) {
            sObjectFields.add(new FieldClass(fs.get(fieldName), sObjectName).fieldObj);
        }
         
        upsert sObjectFields Unique_Name__c;
    }

}