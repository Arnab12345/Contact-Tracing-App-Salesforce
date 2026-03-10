public with sharing class CTLocationTracingController 
{

    //Method to get visitors in a particular location

    Public static List<Location_Tracing__c> getVisitors(Id locationId)
    {
        List<Location_Tracing__c> visitors = [SELECT CreatedById,LastModifiedById,Location__c,Name, Person__c, Visit_Date__c FROM Location_Tracing__c 
        WHERE Location__c = :locationId ORDER BY Visit_Date__c DESC NULLS Last];
        return visitors;
    }

    //Get locations visited by a set of persons

    Public static List<Location_Tracing__c> getLocationsByPersonIds(set<Id> personIds)
    {
        List<Location_Tracing__c> locationsByPersons= new List<Location_Tracing__c>();
        for(Id personId: personIds)
        {
            List<Location_Tracing__c> currentLocationsByPersons = [SELECT Id, CreatedById, LastModifiedById, Location__c, Name, Person__c, Visit_Date__c FROM Location_Tracing__c 
                                                                WHERE Person__c =: personId 
                                                                AND Visit_Date__c >= LAST_N_DAYS:10];

            locationsByPersons.addAll(currentLocationsByPersons);
        }
        
        return locationsByPersons;
    }

    Public static List<Location_Tracing__c> getLocationsByLocationIds(set<Id> locationIds)
    {
        List<Location_Tracing__c> locationsByLocations= new List<Location_Tracing__c>();    
        for(Id locationId: locationIds)
        {
            List<Location_Tracing__c> currentLocationsByLocations = [SELECT Id, CreatedById, LastModifiedById, Location__c, Name, Person__c, Visit_Date__c FROM Location_Tracing__c 
                                                                WHERE Location__c = :locationId
                                                                AND Visit_Date__c >= LAST_N_DAYS:10
                                                                AND Person__r.Health_Status__c = 'Green'];
            locationsByLocations.addAll(currentLocationsByLocations);
        }
        return locationsByLocations;
    }


    /*
     Get Duplicate Location Tracing Records
     The below Method accepts a list of Location Tracing Records and returns
     a list of Location Tracing Records which are duplicates.
    */
    Public static List<Location_Tracing__c> checkDuplicateLocationTracing( List<Location_Tracing__c> locationTraces)
    {
        //store unique location ids
        Set<id> locationIds = new Set<id>();
        for(Location_Tracing__c locationTrace: locationTraces)
        {
            locationIds.add(locationTrace.Location__c);
        }

        //store unique person ids
        Set<id> personIds = new Set<id>();  
        for(Location_Tracing__c locationTrace: locationTraces)
        {
            personIds.add(locationTrace.Person__c);
        }
        //Create a new Map of Location Ids and corresponding set of Person Ids
        
        Map<Id, Set<Id>> locationIdVsPersonIds = new Map<Id, Set<Id>>();

        //Query Existing Location Tracing Records
        List<Location_Tracing__c> existingLocationTraces = [SELECT Id, Location__c, Name, Person__c FROM Location_Tracing__c
                                                            WHERE Location__c IN :locationIds
                                                            AND Person__c IN :personIds
                                                            ];
        //Now if exting matching Location Tracing Records are found then add them to the map
        if( existingLocationTraces!= NULL && existingLocationTraces.size() >0)
        {
            for(Location_Tracing__c existingLocationTrace: existingLocationTraces)
            {
                //If current location id is not present in the map then add it to the map
                if(!locationIdVsPersonIds.containsKey(existingLocationTrace.Location__c))
                {
                    locationIdVsPersonIds.put(existingLocationTrace.Location__c, new Set<Id>());
                }
                //Now add the New Person Id to the set of Person Ids for the current location id
                locationIdVsPersonIds.get(existingLocationTrace.Location__c).add(existingLocationTrace.Person__c);
                
            }
        }
        //Create a new List of Location Tracing Records to be returned which are duplicates
        List<Location_Tracing__c> duplicateLocationTraces = new List<Location_Tracing__c>();

        //Iterate over the new Location Tracing Records
        for(Location_Tracing__c locationTrace: locationTraces)
        {
            //Check if the Location record exists in the Map
            // and then check if any matching person id is found in the map,
            // if match found, return the record as duplicate
            if(locationIdVsPersonIds.containsKey(locationTrace.Location__c) && locationIdVsPersonIds.get(locationTrace.Location__c).contains(locationTrace.Person__c))
            {
                duplicateLocationTraces.add(locationTrace);
            }

        }
        //Finally just return the list of duplicate records.
        return duplicateLocationTraces;
    }
    
}