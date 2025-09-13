@isTest
private class RestrictContactByNameTest {
    @isTest
    static void testInvalidLastName() {
        // Create a Contact with an invalid last name
        Contact invalidContact = new Contact(LastName = 'INVALIDNAME');

        // Insert the contact and capture the exception
        Test.startTest();
        try {
            insert invalidContact;
            // If no exception is thrown, fail the test
            System.assert(false, 'Expected DML exception due to invalid last name');
        } catch (DmlException e) {
            // Expected exception, check the error message
            System.assert(e.getDmlMessage(0).contains('The Last Names"INVALIDNAME" is not allowed for DML'), 'Error message does not match expected');
        }
        Test.stopTest();
    }

    @isTest
    static void testValidLastName() {
        // Create a Contact with a valid last name
        Contact validContact = new Contact(LastName = 'Smith');

        // Insert the contact
        Test.startTest();
        insert validContact;
        Test.stopTest();

        // Assert that the contact was inserted successfully
        System.assertNotEquals(null, [SELECT Id FROM Contact WHERE Id = :validContact.Id]);
    }
}