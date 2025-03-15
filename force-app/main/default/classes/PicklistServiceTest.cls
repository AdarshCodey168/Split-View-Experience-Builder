@isTest
public class PicklistServiceTest {
    @testSetup
    static void setupTestData() {
        Test.startTest();
        
        // Create a test record with a picklist field value
        Account testAccount = new Account(Name = 'Test Account', Industry = 'Technology');
        insert testAccount;
        
        Test.stopTest();
    }

    @isTest
    static void testGetDynamicPicklistValues_ValidPicklistField() {
        Test.startTest();
        
        // Invoke the method with valid object and field API names
        Map<String, Object> result = PicklistService.getDynamicPicklistValues('Account', 'Industry');
        
        // Assertions
        System.assert(result != null, 'Result should not be null');
        System.assert(result.containsKey('picklistValues'), 'Result should contain picklistValues key');
        System.assert(result.containsKey('defaultPicklistValue'), 'Result should contain defaultPicklistValue key');
        
        Test.stopTest();
    }

    @isTest
    static void testGetDynamicPicklistValues_InvalidField() {
        Test.startTest();
        
        // Invoke the method with an invalid field
        try {
            PicklistService.getDynamicPicklistValues('Account', 'InvalidField');
            System.assert(false, 'Method should throw an exception for invalid field');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('Error retrieving picklist values'), 'Should catch an expected error');
        }
        
        Test.stopTest();
    }

    @isTest
    static void testGetDynamicPicklistValues_EmptyField() {
        Test.startTest();
        
        // Invoke the method with an empty field name
        Map<String, Object> result = PicklistService.getDynamicPicklistValues('Account', '');
        
        // Assertions
        System.assert(result != null, 'Result should not be null');
        System.assertEquals(1, ((List<String>) result.get('picklistValues')).size(), 'Picklist values should contain only "All"');
        System.assertEquals('All', result.get('defaultPicklistValue'), 'Default picklist value should be "All"');
        
        Test.stopTest();
    }
}