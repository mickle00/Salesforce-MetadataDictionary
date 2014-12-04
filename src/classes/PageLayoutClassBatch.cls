global class PageLayoutClassBatch implements Database.Batchable<String>, Database.Stateful, Database.AllowsCallouts {

    global PageLayoutClassBatch(){
        //sessionId is null in the batch start & execute methods
        this.sessionId = UserInfo.getSessionId();
    }

    global Iterable<String> start(Database.BatchableContext BC){
        return PageLayoutClass.retrieveLayoutNames(this.sessionId);
    }

    global void execute(Database.BatchableContext BC, List<String> layoutNames){
        List<MetadataService.Layout> layoutMetadata = PageLayoutClass.retrieveLayoutMetadata(layoutNames, this.sessionId);
        List<PageLayoutClass> layouts = PageLayoutClass.parseLayoutMetadata(layoutMetadata);
        for (PageLayoutClass layout : layouts){
            system.debug(layout.getName());
            system.debug(layout.getFields());
            system.debug(JSON.serializePretty(layout.layout));
        }
        PageLayoutClass.insertWithChildren(layouts);
    }

    global void finish(Database.BatchableContext BC){}

    private string sessionId;
}