public with sharing class MaintenanceRequestTriggerHandler {
    private static Boolean isRunning = false;

    public static void handleClosedRequests(List<Case> newList, Map<Id, Case> oldMap) {
        if(isRunning) return;
        isRunning = true;

        try{
            
       


            Set<Id> closedCaseIds = new Set<Id>();

            // Step 1: Collect closed Cases of Type Repair or Routine Maintenance
            for (Case c : newList) {
                Case oldC = oldMap.get(c.Id);
                if (oldC != null && oldC.Status != 'Closed' && c.Status == 'Closed' &&
                    (c.Type == 'Repair' || c.Type == 'Routine Maintenance')) {
                    closedCaseIds.add(c.Id);
                }
            }

            if (closedCaseIds.isEmpty()) return;

            // Step 2: Query related Products via Equipment_Maintenance_Item__c
            Map<Id, List<Product2>> caseIdToProducts = new Map<Id, List<Product2>>();
            for (Equipment_Maintenance_Item__c emi : [
                SELECT Id, Maintenance_Request__c, Equipment__c, Equipment__r.Maintenance_Cycle__c 
                FROM Equipment_Maintenance_Item__c
                WHERE Maintenance_Request__c IN :closedCaseIds
            ]) {
                if (!caseIdToProducts.containsKey(emi.Maintenance_Request__c)) {
                    caseIdToProducts.put(emi.Maintenance_Request__c, new List<Product2>());
                }
                caseIdToProducts.get(emi.Maintenance_Request__c).add(emi.Equipment__r);
            }

            // Step 3: Query Accounts/Contacts for those Cases
            Map<Id, Case> caseMap = new Map<Id, Case>([
                SELECT Id, AccountId, ContactId, Vehicle__c, Date_Reported__c
                FROM Case
                WHERE Id IN :closedCaseIds
            ]);

            List<Case> newRequests = new List<Case>();

            // Step 4: Create new Routine Maintenance requests with due dates
            for (Id caseId : closedCaseIds) {
                List<Product2> products = caseIdToProducts.get(caseId);

                Integer shortestCycle;
                if (products != null) {
                    for (Product2 p : products) {
                        if (p.Maintenance_Cycle__c != null) {
                            if (shortestCycle == null || p.Maintenance_Cycle__c < shortestCycle) {
                                shortestCycle = p.Maintenance_Cycle__c.intValue();
                            }
                        }
                    }
                }

                Case parentCase = caseMap.get(caseId);

                Case routine = new Case();
                routine.Subject   = 'Auto Routine Maintenance';
                routine.Type      = 'Routine Maintenance';
                routine.Status    = 'New';
                routine.Origin    = 'Auto';
                routine.Vehicle__c = parentCase.Vehicle__c; // custom field
                routine.Date_Reported__c = Date.today(); // custom field
                routine.AccountId = parentCase.AccountId;
                routine.ContactId = parentCase.ContactId;
                routine.ParentId  = parentCase.Id;

                if (shortestCycle != null) {
                    routine.Date_Due__c = Date.today().addDays(shortestCycle);
                }

                newRequests.add(routine);
            }

            if (!newRequests.isEmpty()) {
                insert newRequests;
            }

            map<id,case> newcaseParentId = new map<id,case>();
            for(Case c : newRequests) {
                newcaseParentId.put(c.ParentId, c);
            }

            // Step 6: Prepare new Equipment_Maintenance_Item__c records for all new Cases
            List<Equipment_Maintenance_Item__c> newEMIs = new List<Equipment_Maintenance_Item__c>();
            for (Id oldCaseId : closedCaseIds) {
                Case newCase = newcaseParentId.get(oldCaseId);
                List<Product2> products = caseIdToProducts.get(oldCaseId);

                if (products != null) {
                    for (Product2 p : products) {
                        newEMIs.add(new Equipment_Maintenance_Item__c(
                            Maintenance_Request__c = newCase.Id,
                            Equipment__c = p.Id
                        ));
                    }
                }
            }

            // Step 7: Insert all junction records at once
            if (!newEMIs.isEmpty()) {
                insert newEMIs;
            }

        } finally {
            isRunning = false;
        }
    }
}