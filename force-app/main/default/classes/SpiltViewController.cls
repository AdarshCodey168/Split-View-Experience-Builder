public with sharing class SpiltViewController {
    
    @AuraEnabled(cacheable=true)
    public static list<listView> fetchListView(String sObjectName) {
        System.debug('sObjectName=='+sObjectName);
        list<listView> lstListView = [SELECT Id, Name, DeveloperName, SobjectType FROM ListView
                                      WHERE sobjectType =:sObjectName ORDER by DeveloperName Asc];
        return lstListView;
    }
    
    // Apex Class Changes
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getFilteredMessages(String filterField, String filterValue, String objectName, List<String> fieldApiNames, Integer offset, Integer pageSize, String sortField, String sortOrder) {
        system.debug('getFilteredMessages check called');
        system.debug('offset =='+offset);
        system.debug('pageSize=='+pageSize);
        system.debug('sortField=='+sortField);
        system.debug('filterValue=='+filterValue);
        
        if (String.isBlank(objectName) || !Schema.getGlobalDescribe().containsKey(objectName)) {
            throw new AuraHandledException('Invalid object name.');
        }
        
        if (fieldApiNames == null || fieldApiNames.isEmpty()) {
            throw new AuraHandledException('Field API names cannot be null or empty.');
        }
        
        String selectedFields = 'Id';
        for (String field : fieldApiNames) {
            if (String.isNotBlank(field)) {
                selectedFields += ', ' + field;
            }
        }
        
        String query = 'SELECT ' + selectedFields + ' FROM ' + objectName;
        
        if (String.isNotBlank(filterField) && String.isNotBlank(filterValue)) {
            query += ' WHERE ' + filterField + ' = :filterValue';
        }
        
        Integer totalCount = Database.query(query).size();
        
        if (String.isNotBlank(sortField)) {
            query += ' ORDER BY ' + sortField + ' ' + (sortOrder == 'DESC' ? 'DESC' : 'ASC');
        } else {
            query += ' ORDER BY LastModifiedDate DESC';
        }
        
        query += ' LIMIT :pageSize OFFSET :offset';
        
        system.debug('query=='+query);
        List<SObject> results = Database.query(query);
        
        Map<String, Object> response = new Map<String, Object>{
            'records' => results,
                'totalCount' => totalCount
                };
                 system.debug('totalCount=='+totalCount);   
                    return response;
    }
    
    // Helper class for pagination
    public class PaginatedResult {
        @AuraEnabled public List<SObject> records;
        @AuraEnabled public Integer totalCount;
        
        public PaginatedResult(List<SObject> records, Integer totalCount) {
            this.records = records;
            this.totalCount = totalCount;
        }
    }
    
    
    @AuraEnabled
    public static List<SObject> getListViewRecords(String objectName, String filterName) {
        List<SObject> result = new List<SObject>();
        List<SObject> records = new List<SObject>();
        Integer results = 0;
        
        String baseUrl = URL.getOrgDomainUrl().toExternalForm();
        system.debug('baseUrl=='+baseUrl);
        HttpRequest req = new HttpRequest();
        String endPoinURL = baseUrl + '/services/data/v60.0/sobjects/' + objectName + '/listviews/' + filterName + '/describe';
        req.setEndpoint(endPoinURL);
        req.setMethod('GET');
        
        String sessionId = UserInfo.getSessionId();
        //   System.debug('sessionId==' + sessionId);
        
        req.setHeader('Authorization', 'Bearer ' + sessionId);
        Http http = new Http();
        
        try {
            HttpResponse response = http.send(req);
            System.debug('Response Status: ' + response.getStatus());
            System.debug('Response Body: ' + response.getBody());
            if (response.getStatusCode() == 200) {
                Map<String, Object> tokenResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                String query = (String) tokenResponse.get('query');
                System.debug(query);
                result = Database.query(query);
            } else {
                throw new AuraHandledException('Failed to retrieve list view records. Status: ' + response.getStatus());
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error occurred while fetching list view records: ' + e.getMessage());
        }
        
        return result;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getFieldLabel(String objectName, String fieldName) {
        try {
            Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
            if (fieldsMap.containsKey(fieldName)) {
                return fieldsMap.get(fieldName).getDescribe().getLabel();
            }
            return 'Field not found';
        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static String getPluralLabel(String objectName) {
        try {
            if (Schema.getGlobalDescribe().containsKey(objectName)) {
                return Schema.getGlobalDescribe().get(objectName).getDescribe().getLabelPlural();
            }
            return 'Object not found';
        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }
    }
    
    
    
}