@isTest
private class MaintenanceRequestTriggerTest {
    @isTest
    static void testBulkMaintenanceRequestCreation() {
        // Setup Account + Contact
        Account acc = new Account(Name='Bulk Test Account');
        insert acc;

        Contact con = new Contact(
            FirstName='Bulk',
            LastName='User',
            AccountId=acc.Id,
            Email='bulk@example.com'
        );
        insert con;

        // Setup valid Equipment (Product2 records)
        Product2 prod1 = new Product2(
            Name='Generator',
            Maintenance_Cycle__c=30,
            IsActive=true,
            Replacement_Part__c=true,
            Cost__c=1000,
            Current_Inventory__c=10,
            Warehouse_SKU__c='SKU-001'
        );

        Product2 prod2 = new Product2(
            Name='Cooling Fan',
            Maintenance_Cycle__c=60,
            IsActive=true,
            Replacement_Part__c=true,
            Cost__c=500,
            Current_Inventory__c=5,
            Warehouse_SKU__c='SKU-002'
        );

        insert new List<Product2>{ prod1, prod2 };

        // Create Maintenance Requests (Cases)
        List<Case> requests = new List<Case>();
        for (Integer i = 0; i < 2; i++) {
            Case c = new Case();
            c.Subject = 'Test Case ' + i;
            c.Status = 'New';
            c.Type = 'Repair';
            c.AccountId = acc.Id;
            c.ContactId = con.Id;
            requests.add(c);
        }
        insert requests;

        // Link Equipment to Cases using Equipment_Maintenance_Item__c
        List<Equipment_Maintenance_Item__c> emis = new List<Equipment_Maintenance_Item__c>();
        emis.add(new Equipment_Maintenance_Item__c(
            Maintenance_Request__c = requests[0].Id,
            Equipment__c = prod1.Id
        ));
        emis.add(new Equipment_Maintenance_Item__c(
            Maintenance_Request__c = requests[1].Id,
            Equipment__c = prod2.Id
        ));
        insert emis;

        // Update Cases to Closed (this should fire the trigger)
        for (Case c : requests) {
            c.Status = 'Closed';
        }
        update requests;

        // Query all new Routine Maintenance Cases
        List<Case> relatedCases = [
            SELECT Id, Subject, Type, Status, ParentId, Date_Due__c
            FROM Case
            WHERE ParentId IN :requests
        ];

        System.assertEquals(2, relatedCases.size(),
            'One Routine Maintenance request should be created for each closed request');

        for (Case rc : relatedCases) {
            System.assertEquals('Routine Maintenance', rc.Type);
            System.assertEquals('New', rc.Status);
            System.assertNotEquals(null, rc.Date_Due__c,
                'Routine Maintenance request should have a calculated due date');
        }

        // Verify new EMIs are created for new Routine Maintenance Cases
        List<Equipment_Maintenance_Item__c> newEmis = [
            SELECT Id, Maintenance_Request__c, Equipment__c
            FROM Equipment_Maintenance_Item__c
            WHERE Maintenance_Request__c IN :relatedCases
        ];

        System.assertEquals(2, newEmis.size(),
            'Each new maintenance request should have related Equipment_Maintenance_Item__c');
    }
}