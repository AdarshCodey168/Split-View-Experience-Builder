public with sharing class PicklistService {
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getDynamicPicklistValues(String objectApiName, String fieldApiName) {
        Map<String, Object> result = new Map<String, Object>();
        List<String> picklistValues = new List<String>();
        String defaultPicklistValue = null;
        
        try {
            if(fieldApiName!=NULL && fieldApiName != ''){
                system.debug('inside if block=='+fieldApiName);
                Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectApiName);
                Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
                Schema.DescribeFieldResult fieldDescribe = objDescribe.fields.getMap().get(fieldApiName).getDescribe();
                
                if (fieldDescribe != null && fieldDescribe.getType() == Schema.DisplayType.PICKLIST) {
                    for (Schema.PicklistEntry entry : fieldDescribe.getPicklistValues()) {
                        picklistValues.add(entry.getValue());
                        if (entry.isDefaultValue()) {  
                            defaultPicklistValue = entry.getValue();
                        }
                    }
                }
                
                result.put('picklistValues', picklistValues);
                result.put('defaultPicklistValue', defaultPicklistValue);
            }
            else {
                List<String> picklistValues2 = new List<String>();
                String defaultPicklistValue2 = 'All';
                
                picklistValues.add('All');
                
                result.put('picklistValues', picklistValues2);
                result.put('defaultPicklistValue', defaultPicklistValue2);
            }
            
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving picklist values: ' + e.getMessage());
        }
        
        return result;
    }
    
}