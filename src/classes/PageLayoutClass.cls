public with sharing class PageLayoutClass{

    public MetadataService.Layout layout;
    public Page_Layout__c layoutObj;
    public PageLayoutClass(MetadataService.Layout layout){
        this.layout = layout;
        this.layoutObj = new Page_Layout__c(
                Name = this.getName()
                ,sObject__r = new sObject__c(API_Name__c = this.getObjectName())
                ,Unique_Name__c = this.getName()
        );
    }

    // system.debug(JSON.serializePretty(layout.layoutSections[0].layoutColumns[0].layoutItems[0].field));
    public List<String> getFields(){
        List<String> fields = new List<String>();
        if (this.layout.layoutSections == null) return fields;
        for (MetadataService.LayoutSection section : this.layout.layoutSections){
            if (section.LayoutColumns != null){
                for(MetadataService.LayoutColumn column : section.layoutColumns){
                    if (column.layoutItems != null){
                        for(MetadataService.LayoutItem item : column.layoutItems){
                            fields.add(item.field);
                        }
                    }
                }
            }
        }
        return fields;
    }

    public string getName(){
        return this.layout.fullName;
    }

    public string getObjectName(){
        system.debug('PAGE LAYOUT: ' + this.getName());
        String layoutPrefix = this.getName().split('-')[0];
        if (layoutPrefix == 'CaseClose') return 'Case';
        if (layoutPrefix == 'CaseInteraction') return 'Case';
        return layoutPrefix;
    }

    public static void insertWithChildren(List<PageLayoutClass> layouts){
        List<Page_Layout__c> layoutObjs = new List<Page_Layout__c>();
        List<Page_Layout_Field__c> layoutFields = new List<Page_Layout_Field__c>();
        for (PageLayoutClass layout : layouts){
            layoutObjs.add(layout.layoutObj);
            layoutFields.addAll(PageLayoutFieldClass.build(layout));
        }
        // system.debug(JSON.serializePretty(layoutFields)); // Unique_Name__c;
        upsert layoutObjs Unique_Name__c;
        upsert layoutFields Unique_Name__c;
    }

    public static List<PageLayoutClass> parseLayoutMetadata(List<MetadataService.Layout> layoutMetadatas){
        List<PageLayoutClass> layouts = new List<PageLayoutClass>();
        for (MetadataService.Layout layoutMetadata : layoutMetadatas){
            layouts.add(new PageLayoutClass(layoutMetadata));
        }

        return layouts;
    }

    //UserInfo.getSessionId() is null when called from BatchApex
    public static List<String> retrieveLayoutNames(string sessionId){
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = sessionId;
        List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();
        MetadataService.ListMetadataQuery queryLayout = new MetadataService.ListMetadataQuery();
        queryLayout.type_x = 'Layout';
        queries.add(queryLayout);
        MetadataService.FileProperties[] fileProperties = service.listMetadata(queries, 25);

        List<String> layoutNames = new List<String>();
        for (MetadataService.FileProperties fileProperty : fileProperties){
            layoutNames.add(fileProperty.fullName);
        }
        return layoutNames;
    }

    public static List<MetadataService.Layout> retrieveLayoutMetadata(List<String> layoutViewNames, string sessionId){
        if (layoutViewNames.size() > 10) throw new LayoutRetrieveLimitException('Can only retrieve 10 items or less'); 
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = sessionId;
        return (List<MetadataService.Layout>) service.readMetadata('Layout', layoutViewNames).getRecords();
    }

    public class LayoutRetrieveLimitException extends Exception{}
}