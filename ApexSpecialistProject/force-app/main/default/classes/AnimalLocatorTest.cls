@isTest
private class AnimalLocatorTest {
    @isTest
    static void testGetAnimalNameByIdLion() {
        Test.setMock(HttpCalloutMock.class, new AnimalLocatorMock());
        String animalName = AnimalLocator.getAnimalNameById(1);
        System.assertEquals('mock lion', animalName, 'Expected mock lion');
    }

    @isTest
    static void testGetAnimalNameByIdRabbit() {
        Test.setMock(HttpCalloutMock.class, new AnimalLocatorMock());
        String animalName = AnimalLocator.getAnimalNameById(2);
        System.assertEquals('mock rabbit', animalName, 'Expected mock rabbit');
    }

    @isTest
    static void testGetAnimalNameByIdNotFound() {
        Test.setMock(HttpCalloutMock.class, new AnimalLocatorMock());

        try {
            // This will deserialize into AnimalResult, but JSON won't match
            String animalName = AnimalLocator.getAnimalNameById(999);
            System.assertEquals(null, animalName, 'Should return null when not found');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('System.JSONException'), 'Expected JSON exception for 404 body');
        }
    }
}