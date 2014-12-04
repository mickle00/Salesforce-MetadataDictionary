global class ListViewClassBatch implements Database.Batchable<String>, Database.Stateful, Database.AllowsCallouts {

    global ListViewClassBatch(){
        //sessionId is null in the batch start & execute methods
        this.sessionId = UserInfo.getSessionId();
    }

    global Iterable<String> start(Database.BatchableContext BC){
        return ListViewClass.retrieveListViewNames(this.sessionId);
    }

    global void execute(Database.BatchableContext BC, List<String> listViewNames){
        List<MetadataService.ListView> listViewMetadata = ListViewClass.retrieveListViewMetadata(listViewNames, this.sessionId);
        List<ListViewClass> listViews = ListViewClass.parseListViewMetadata(listViewMetadata);
        for (ListViewClass listView : listViews){
            system.debug(listView.getName());
            system.debug(listView.getObjectName());
        }
        ListViewClass.insertWithChildren(listViews);
    }

    global void finish(Database.BatchableContext BC){}

    private string sessionId;
}