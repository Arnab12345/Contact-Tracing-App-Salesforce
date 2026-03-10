public with sharing class CTLocationController {

    // Method to get recent Location Changes
  Public Static List<Location__c> getRecentLocations(){ 
    List<Location__c> locationList = [SELECT Address__c, CreatedById,LastModifiedById, Name, OwnerId, Pincode__c, Red_Score__c,Status__c,
                                      Status_Update_Date__c FROM Location__c ORDER BY Status_Update_Date__c DESC NULLS Last LIMIT 100];
                                  return locationList;
}

//Method to search Locations with a Key word.
  Public Static List<Location__c> searchLocations(String searchTerm)
  {
    searchTerm =  searchTerm + '%';
    List<Location__c> searchList =  [SELECT Address__c, CreatedById,LastModifiedById, Name, OwnerId, Pincode__c, Red_Score__c,Status__c,
                                      Status_Update_Date__c FROM Location__c WHERE Name LIKE :searchTerm OR Address__c LIKE :searchTerm OR Pincode__c LIKE :searchTerm];
    return searchList;
  }

  //Method to Search a Location by Id

  Public Static Location__c getByLocationById(String locationId){
    List<Location__c> locations =  [SELECT Address__c, CreatedById,LastModifiedById, Name, OwnerId, Pincode__c, Red_Score__c,Status__c,
                                      Status_Update_Date__c FROM Location__c WHERE Id = :locationId];
    if(locations != NULL && locations.size() > 0){
      return locations[0];
    }
    return NULL;
  }

  //Method to get Persons by Health Status
    Public Static Map<String, Integer> getStatusCount()
    {
        //AggregateResult[] personList =[SELECT Health_Status__c, COUNT(Id) StatusCount FROM Person__c GROUP BY Health_Status__c];
        Map<String, Integer> locationhealthStatusMap = new Map<String, Integer>();
            for(AggregateResult  location: [SELECT Status__c, COUNT(Id) StatusCount 
                                         FROM Location__c GROUP BY Status__c])
            {
                String Health = String.valueOf(location.get('Status__c'));
                Integer numLocations = Integer.valueOf(location.get('StatusCount'));
                if(!locationhealthStatusMap.containsKey(Health))
                {
                    locationhealthStatusMap.put(Health,numLocations);
                }
                    
            }
        return locationhealthStatusMap ;
    } 
}