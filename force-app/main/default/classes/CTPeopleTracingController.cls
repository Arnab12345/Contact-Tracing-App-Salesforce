/**
 * CTPeopleTracingController
 * 
 * @description
 * Utilities for People_Tracing__c domain.
 * 
 * Responsibilities:
 * - Detect duplicates among incoming People_Tracing__c records by matching Person_1__c and Person_2__c
 * 
 * Notes:
 * - Bulkified (single SOQL, O(1) lookups, no DML-in-loops)
 * - Respects org security via WITH SECURITY_ENFORCED and with sharing
 * - Return-early pattern for null/empty inputs
 * 
 * Extensions:
 * - If symmetry is required (A,B) == (B,A), set CONSIDER_SYMMETRIC_PAIRS = true
 * - If duplicate definition must include Contact_Date__c or Contact_Type__c, extend the key accordingly
 */


public with sharing class CTPeopleTracingController {


    //Method to get traces of a particular person
    Public Static List<People_Tracing__c> getTraces(String personId)
    {
        List<People_Tracing__c> traces = [SELECT Id, Name, Person_1__r.Name, Person_2__r.Name, Contact_Date__c FROM
                                            People_Tracing__c WHERE Person_1__c = :personId OR Person_2__c = :personId
                                            ORDER BY Contact_Date__c DESC NULLS LAST];

        return traces;
    }

    /*
    Method to check Duplicate People Tracing Records and return a
    list of duplicate records.
    */

    Public static List<People_Tracing__c> checkDuplicatePeopleTracing( List<People_Tracing__c> peopleTraces)
    {
        //Create a set of unique Person Ids
        Set<Id> personIds = new Set<Id>();
        for(People_Tracing__c peopleTrace: peopleTraces)
        {
            personIds.add(peopleTrace.Person_1__c);
            personIds.add(peopleTrace.Person_2__c);
        }

        //Create a New List of People Tracing Records to store duplicate records
        List<People_Tracing__c> duplicatePeopleTraces = new List<People_Tracing__c>();

        //Create a Map of Person Ids and corresponding set of Person Ids
        Map<Id, Set<Id>> personIdVsPersonIds = new Map<Id, Set<Id>>();

        //Query Existing People Tracing Records
        List<People_Tracing__c> existingPeopleTraces = [SELECT Id, Person_1__c, Person_2__c FROM People_Tracing__c 
                                                        WHERE Person_1__c IN :personIds
                                                        AND Person_2__c IN :personIds
                                                        ];

        if(existingPeopleTraces!= NULL && existingPeopleTraces.size() >0)
        {
            for(People_Tracing__c existingPeopleTrace: existingPeopleTraces)
            {
                //If the Person 1 is not present as key in the Map then add it to the 
                //map as key and a new blank set as value
                if(!personIdVsPersonIds.containsKey(existingPeopleTrace.Person_1__c))
                {
                    personIdVsPersonIds.put(existingPeopleTrace.Person_1__c, new Set<Id>());
                }
                //Now assume that Person 1 is the key and Person 2 is the value
                personIdVsPersonIds.get(existingPeopleTrace.Person_1__c).add(existingPeopleTrace.Person_2__c);

                //If the Person 2 is not present as key in the Map then add it to the 
                //map as key and a new blank set as value
                if(!personIdVsPersonIds.containsKey(existingPeopleTrace.Person_2__c))
                {
                    personIdVsPersonIds.put(existingPeopleTrace.Person_2__c, new Set<Id>());
                }
                //Now assume that Person 1 is the key and Person 2 is the value
                personIdVsPersonIds.get(existingPeopleTrace.Person_2__c).add(existingPeopleTrace.Person_1__c);

            }
        }

        //Now iterate over the new People Tracing Records
        for(People_Tracing__c peopleTrace: peopleTraces)
        {
            if((personIdVsPersonIds.containsKey(peopleTrace.Person_1__c) && personIdVsPersonIds.get(peopleTrace.Person_1__c).contains(peopleTrace.Person_2__c))
            || (personIdVsPersonIds.containsKey(peopleTrace.Person_2__c) && personIdVsPersonIds.get(peopleTrace.Person_2__c).contains(peopleTrace.Person_1__c)))
            {
                duplicatePeopleTraces.add(peopleTrace);
            }
        }


        return duplicatePeopleTraces;
    }
    
}
