public class sObjectClass {

    /**
        https://www.salesforce.com/us/developer/docs/apexcode/Content/apex_methods_system_sobject_describe.htm
    **/

    public sObject__c sObj;
    
    public sObjectClass(Schema.DescribeSObjectResult describeResult){
        this.sObj = new sObject__c();
        this.sObj.Name = describeResult.getLabel();
        this.sObj.API_Name__c = describeResult.getName();
    }
    
    public static void findAndInsertSObjects(){
        List<sObject__c> sObjects = new List<sObject__c>();
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        for (String sObjectName : gd.keySet()){
            Schema.DescribeSObjectResult r = gd.get(sObjectName).getDescribe();
            sObjects.add(new sObjectClass(r).sObj);
        }
        upsert sObjects API_Name__c;
    }

}