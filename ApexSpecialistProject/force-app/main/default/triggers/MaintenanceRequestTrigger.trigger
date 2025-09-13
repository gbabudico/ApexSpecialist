trigger MaintenanceRequestTrigger on Case (after update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        MaintenanceRequestTriggerHandler.handleClosedRequests(Trigger.new, Trigger.oldMap);
    }
}