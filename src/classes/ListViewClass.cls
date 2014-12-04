public with sharing class ListViewClass{

    public List_View__c listViewObj;
    public MetadataService.ListView listViewMetadata;

    public ListViewClass(MetadataService.ListView listViewMetadata){
        this.listViewMetadata = listViewMetadata;
        this.listViewObj = new List_View__c(
                 Name = this.getUniqueName()
                ,sObject__r = new sObject__c(API_Name__c = this.getObjectName())
                ,Unique_Name__c = this.getUniqueName()
        );
    }

    public string getUniqueName(){
        return this.listViewMetadata.fullName;
    }

    public string getName(){
        return this.listViewMetadata.fullName.split('\\.')[1];
    }

    public string getObjectName(){
        return this.listViewMetadata.fullName.split('\\.')[0];
    }

    public static List<ListViewClass> parseListViewMetadata(List<MetadataService.ListView> listViewMetadatas){
        List<ListViewClass> listViews = new List<ListViewClass>();
        for (MetadataService.ListView listViewMetadata : listViewMetadatas){
            listViews.add(new ListViewClass(listViewMetadata));
        }

        return listViews;
    }

    public static void insertWithChildren(List<ListViewClass> listViews){
        List<List_View__c> listViewObjs = new List<List_View__c>();
        List<List_View_Field__c> listViewFields = new List<List_View_Field__c>();
        for (ListViewClass listView : listViews){
            listViewObjs.add(listView.listViewObj);
            listViewFields.addAll(ListViewFieldClass.build(listView));
        }
        // system.debug(JSON.serializePretty(listViewFields)); // Unique_Name__c;
        upsert listViewObjs Unique_Name__c;
        upsert listViewFields Unique_Name__c;
    }

    //UserInfo.getSessionId() is null when called from BatchApex
    public static List<String> retrieveListViewNames(string sessionId){
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = sessionId;
        List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();
        MetadataService.ListMetadataQuery queryListView = new MetadataService.ListMetadataQuery();
        queryListView.type_x = 'ListView';
        queries.add(queryListView);
        MetadataService.FileProperties[] fileProperties = service.listMetadata(queries, 25);

        List<String> listViewNames = new List<String>();
        for (MetadataService.FileProperties fileProperty : fileProperties){
            listViewNames.add(fileProperty.fullName);
        }
        return listViewNames;
    }

    public static List<MetadataService.ListView> retrieveListViewMetadata(List<String> listViewNames, string sessionId){
        if (listViewNames.size() > 10) throw new ListViewRetrieveLimitException('Can only retrieve 10 items or less'); 
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = sessionId;
        return (List<MetadataService.ListView>) service.readMetadata('ListView', listViewNames).getRecords();
    }

    public class ListViewRetrieveLimitException extends Exception{}
}