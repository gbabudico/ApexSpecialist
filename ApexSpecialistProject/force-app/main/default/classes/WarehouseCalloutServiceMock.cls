@isTest
global class WarehouseCalloutServiceMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response   
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');  
        res.setBody('[{"name":"Forklift","cost":15000.0,"quantity":4,"lifespan":60,"maintenanceperiod":6,"sku":"FL-15000"},{"name":"Pallet Jack","cost":1200.0,"quantity":10,"lifespan":36,"maintenanceperiod":12,"sku":"PJ-1200"},{"name":"Conveyor Belt","cost":8000.0,"quantity":2,"lifespan":48,"maintenanceperiod":3,"sku":"CB-8000"}]');
        res.setStatusCode(200);
        return res;
    }
    // implement http mock callout
}