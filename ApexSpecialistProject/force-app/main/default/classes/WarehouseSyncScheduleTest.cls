@isTest
public with sharing class WarehouseSyncScheduleTest {
    // implement scheduled code here
    @isTest
    static void testExecute() {
        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        // Start test context
        Test.startTest();
        // Schedule the job
        String cronExp = '0 0 0 ? * MON-FRI'; // Every weekday at midnight
        String jobId = System.schedule('Test Warehouse Sync Schedule', cronExp, new WarehouseSyncSchedule());
        // End test context
        Test.stopTest();
        // Verify that the products were inserted
        List<Product2> products = [SELECT Name, Cost__c, Current_Inventory__c, Lifespan_Months__c, Maintenance_Cycle__c, Warehouse_SKU__c FROM Product2 WHERE Warehouse_SKU__c IN ('FL-15000', 'PJ-1200', 'CB-8000')];
        System.assertEquals(3, products.size(), 'Three products should have been inserted.');
    }       
    // implement your mock callout test here    
}