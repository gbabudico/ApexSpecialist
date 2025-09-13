public with sharing class WarehouseCalloutService implements Queueable, Database.AllowsCallouts{
    public WarehouseCalloutService() {

    }

    public void execute(QueueableContext context){
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://th-superbadge-apex.herokuapp.com/equipment');
        req.setMethod('GET');
        Http http = new Http();
        HttpResponse res = http.send(req);
        System.debug('Response Body: ' + res.getBody());
        list<Object> apiResponse = (List<Object>) JSON.deserializeUntyped(res.getBody());
        system.debug('check the response +++'+apiResponse);

        list<Product2> equipmentsToUpsert = new list<Product2>();
        for(object rec: apiResponse){            
            Map<String, Object> indivResponse = (Map<String, Object>) rec;
            system.debug('check the map ---'+indivResponse);
            Product2 equip = new Product2();
            equip.Replacement_Part__c = true;
            equip.Cost__c = (Decimal) indivResponse.get('cost');
            equip.Name = (String) indivResponse.get('name');
            equip.Current_Inventory__c = (Integer) indivResponse.get('quantity');
            equip.Lifespan_Months__c = (Integer) indivResponse.get('lifespan');
            equip.Maintenance_Cycle__c = (Integer) indivResponse.get('maintenanceperiod');
            equip.Warehouse_SKU__c = (String) indivResponse.get('sku');
            equipmentsToUpsert.add(equip);
        }

        system.debug('check the list of equipments to upsert ---'+equipmentsToUpsert);
        upsert equipmentsToUpsert Warehouse_SKU__c;
    }
}