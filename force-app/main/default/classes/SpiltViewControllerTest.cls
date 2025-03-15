@isTest
public class SpiltViewControllerTest {
    
    @testSetup
    static void setupTestData() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 10; i++) {
            accounts.add(new Account(Name = 'Test Account ' + i));
        }
        insert accounts;
    }
    
    @isTest
    static void testGetFilteredMessages() {
        Test.startTest();
        
        Map<String, Object> response = SpiltViewController.getFilteredMessages(
            'Name', 'Test Account 1', 'Account', new List<String>{'Name'}, 0, 5, 'Name', 'ASC'
        );
        
        System.assertNotEquals(null, response, 'Response should not be null');
        System.assert(response.containsKey('records'), 'Response should contain records key');
        System.assert(response.containsKey('totalCount'), 'Response should contain totalCount key');
        
        List<SObject> records = (List<SObject>) response.get('records');
        System.assert(records.size() > 0, 'Records should not be empty');
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetFilteredMessagesWithNoSortField() {
        Test.startTest();
        
        Map<String, Object> response = SpiltViewController.getFilteredMessages(
            'Name', 'Test Account 1', 'Account', new List<String>{'Name'}, 0, 5, '', 'ASC'
        );
        
        System.assertNotEquals(null, response, 'Response should not be null');
        System.assert(response.containsKey('records'), 'Response should contain records key');
        System.assert(response.containsKey('totalCount'), 'Response should contain totalCount key');
        
        List<SObject> records = (List<SObject>) response.get('records');
        System.assert(records.size() > 0, 'Records should not be empty');
        
        Test.stopTest();
    }
    
   
    
    @isTest
    static void testGetFieldLabel() {
        Test.startTest();
        String label = SpiltViewController.getFieldLabel('Account', 'Name');
        System.assertEquals('Account Name', label, 'Field label should match expected value');
        Test.stopTest();
    }
    
    @isTest
    static void testGetFieldLabelInvalidField() {
        Test.startTest();
        String label = SpiltViewController.getFieldLabel('Account', 'InvalidField');
        System.assertEquals('Field not found', label, 'Should return Field not found for invalid fields');
        Test.stopTest();
    }
    
    @isTest
    static void testGetPluralLabel() {
        Test.startTest();
        String label = SpiltViewController.getPluralLabel('Account');
        System.assertEquals('Accounts', label, 'Plural label should match expected value');
        Test.stopTest();
    }
    
    @isTest
    static void testGetPluralLabelInvalidObject() {
        Test.startTest();
        String label = SpiltViewController.getPluralLabel('InvalidObject');
        System.assertEquals('Object not found', label, 'Should return Object not found for invalid objects');
        Test.stopTest();
    }
}