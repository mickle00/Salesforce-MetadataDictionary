public with sharing class ListViewFieldClass{

    public List_View_Field__c listViewFieldObj;
    public string fieldName;

    public ListViewFieldClass(ListViewClass listView, String columnName){
        this.fieldName = listView.getObjectName() + '.' + columnName;
        this.listViewFieldObj = new List_View_Field__c(
                Name = fieldName
                ,Field__r = new Field__c(Unique_Name__c = this.fieldName)
                ,List_View__r = new List_View__c(Unique_Name__c = listView.getUniqueName())
                ,Unique_Name__c = listView.getUniqueName() + '.' + fieldName + '.column'
        );
    }
    public ListViewFieldClass(ListViewClass listView, MetadataService.ListViewFilter filter){
        this.fieldName = listView.getObjectName() + '.' + filter.field;
        this.listViewFieldObj = new List_View_Field__c(
                Name = fieldName
                ,Field__r = new Field__c(Unique_Name__c = this.fieldName)
                ,List_View__r = new List_View__c(Unique_Name__c = listView.getUniqueName())
                ,Operation__c = filter.operation
                ,Value__c = filter.value
                ,Unique_Name__c = listView.getUniqueName() + '.' + fieldName + '.filter'
        );
    }

    public static List<List_View_Field__c> build(ListViewClass listView){
        List<List_View_Field__c> listViewFields = new List<List_View_Field__c>();
        listViewFields.addAll(parseColumns(listView));
        listViewFields.addAll(parseFilters(listView));

        return listViewFields;
    }

    private static boolean isCustomField(String fieldName){
        if (fieldName == null) return false;
        return fieldName.endsWith('__c');

    }
    private static boolean isCustomField(MetadataService.ListViewFilter filter){
        return isCustomField(filter.field);
    }

    private static List<List_View_Field__c> parseFilters(ListViewClass listView){
        List<List_View_Field__c> filters = new List<List_View_Field__c>();
        try {
            for (MetadataService.ListViewFilter filter : listView.listViewMetadata.filters){
                //only supporting custom fields right now, due to how standard fields are represented differently in different places.
                if (isCustomField(filter)) filters.add(new ListViewFieldClass(listView, filter).listViewFieldObj);
            }
        } catch (Exception e){
            system.debug(e);
            system.debug(JSON.serializePretty(listView));
        }
        return filters;
    }

    private static List<List_View_Field__c> parseColumns(ListViewClass listView){
        List<List_View_Field__c> columns  = new List<List_View_Field__c>();
        try {
            for (String column : listView.listViewMetadata.columns){
                //only supporting custom fields right now, due to how standard fields are represented differently in different places.
                if (isCustomField(column)) columns.add(new ListViewFieldClass(listView, column).listViewFieldObj);
            }
        } catch (Exception e){
            system.debug(e);
            system.debug(JSON.serializePretty(listView));
        }
        return columns;
    }
}