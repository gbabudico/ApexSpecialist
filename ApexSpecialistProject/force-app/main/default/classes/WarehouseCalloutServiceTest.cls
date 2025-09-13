@IsTest
public class WarehouseCalloutServiceTest {
    @IsTest
    static void testWarehouseCalloutService() {
        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        // Start test context
        Test.startTest();
        // Enqueue the callout service
        System.enqueueJob(new WarehouseCalloutService());
        // End test context
        Test.stopTest();
        // Verify that the products were inserted
        List<Product2> products = [SELECT Name, Cost__c, Current_Inventory__c, Lifespan_Months__c, Maintenance_Cycle__c, Warehouse_SKU__c FROM Product2 WHERE Warehouse_SKU__c IN ('FL-15000', 'PJ-1200', 'CB-8000')];
        System.assertEquals(3, products.size(), 'Three products should have been inserted.');

        System.assertEquals(1, products.size(), 'One product should have been inserted');
        System.assertEquals('Test Equipment', products[0].Name, 'Product name should match mock response');
        System.assertEquals(100.5, products[0].Cost__c, 'Cost should match mock response');
        System.assertEquals(10, products[0].Current_Inventory__c, 'Inventory should match mock response');
        System.assertEquals(24, products[0].Lifespan_Months__c, 'Lifespan should match mock response');
        System.assertEquals(6, products[0].Maintenance_Cycle__c, 'Maintenance period should match mock response');
        // Additional assertions can be added here to verify field values
    }       
    // implement your mock callout test here

}