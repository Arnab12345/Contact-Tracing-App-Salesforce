public with sharing class CTPersonController {


   //Method to generate Token for a Person's mobile number
    Public Static String getToken(String str){
        //using MD5 encryption to generate unique token
        Blob targetBlob = Blob.valueOf(str);
        //generat Hash out of the blob value
        Blob hash = Crypto.generateDigest('MD5', targetBlob);
        //return the string value of the hash
        String result = EncodingUtil.base64Encode(hash);
       // System.debug('Value: ' + result);
        return result;
    }


   //Method to get recent Health Changes    
    Public Static List<Person__c> getRecentHealthChanges(){
        List<Person__c> personList = [SELECT CreatedById,Health_Status__c,LastModifiedById,	Mobile__c,
                                     Name, OwnerId, Status_Update_Date__c, Token__c FROM Person__c ORDER BY Status_Update_Date__c DESC NULLS Last LIMIT 100];
        return personList;
    }


    Public Static List<Person__c> searchPeople(String searchTerm){
        searchTerm =  searchTerm + '%';
        List<Person__c> searchList = [SELECT CreatedById,Health_Status__c,LastModifiedById,	Mobile__c,
                                     Name, OwnerId, Status_Update_Date__c, Token__c FROM Person__c WHERE Name LIKE :searchTerm OR 
     Mobile__c LIKE :searchTerm OR Token__c LIKE :searchTerm];
        return searchList;
    }

    Public Static Person__c getByPersonById(String personId)
    {
        Person__c person = [SELECT CreatedById,Health_Status__c,LastModifiedById,	Mobile__c,
                            Name, OwnerId, Status_Update_Date__c, Token__c FROM Person__c WHERE Id = :personId];
        return person;
    }
    
    //Method to get Persons by Health Status
    Public Static Map<String, Integer> getHealthStatusCount()
    {
        //AggregateResult[] personList =[SELECT Health_Status__c, COUNT(Id) StatusCount FROM Person__c GROUP BY Health_Status__c];
        Map<String, Integer> personhealthStatusMap = new Map<String, Integer>();
            for(AggregateResult  person: [SELECT Health_Status__c, COUNT(Id) StatusCount 
                                         FROM Person__c GROUP BY Health_Status__c])
            {
                String Health = String.valueOf(person.get('Health_Status__c'));
                Integer NumPersons = Integer.valueOf(person.get('StatusCount'));
                if(!personhealthStatusMap.containsKey(Health))
                {
                    personhealthStatusMap.put(Health,NumPersons);
                }
                    
            }
        return personhealthStatusMap;
    } 
}