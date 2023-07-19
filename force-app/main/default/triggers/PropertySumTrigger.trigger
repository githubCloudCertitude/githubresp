trigger PropertySumTrigger on Person__c (after insert, after update, after delete, after undelete) {
    public static Map<ID, Schema.RecordTypeInfo> rtyMap = Schema.SObjectType.Person__c.getRecordTypeInfosById();
    public static Set<Id> parntLookupIds = new Set<Id>();
    public static Set<Id> childLookupIds = new Set<Id>();
    Map<Id,Id> recTypMap = new Map<Id,Id>();
    list<Id> parentIds = new list<Id>();
    if(trigger.isAfter){
        if(trigger.isInsert || trigger.isUpdate || trigger.isUndelete){
            for(Person__c pr :  trigger.New){
                if(pr.Person__c != null)
                    parentIds.add(pr.Person__c);
            }
            if(!parentIds.isEmpty())
                for(Person__c pr : [Select Id, RecordTypeId FROM Person__c WHERE Id In : parentIds]){
                    recTypMap.put(pr.Id,pr.RecordTypeId);
                }
        }
        if(trigger.isInsert || trigger.isUndelete){
            for(Person__c pr :  trigger.New){
                if(rtyMap.containsKey(pr.RecordTypeId) && pr.Person__c != null){
                    if(rtyMap.get(pr.RecordTypeId).getName() == 'Parent'){
                        if(rtyMap.get(recTypMap.get(pr.Person__c)).getName() == 'Grand Parent')
                            parntLookupIds.add(pr.Person__c);
                        else
                            pr.Person__c.addError('You Can olny Select Grand Parent Record');
                    }else if(rtyMap.get(pr.RecordTypeId).getName() == 'Child'){
                        if(rtyMap.get(recTypMap.get(pr.Person__c)).getName() == 'Parent')
                            childLookupIds.add(pr.Person__c);
                        else
                            pr.Person__c.addError('You Can olny Select Parent Record');
                    }
                }
            }
            if(!parntLookupIds.isEmpty() || !childLookupIds.isEmpty())
                PropertySumTriggerHandler.updatePropertySumAfter(parntLookupIds,childLookupIds);
        }
        
        if(trigger.isUpdate){
            for(Person__c pr : trigger.New){
                if(rtyMap.get(pr.RecordTypeId).getName() == 'Parent'){
                    if(rtyMap.get(recTypMap.get(pr.Person__c)).getName() == 'Grand Parent'){
                        parntLookupIds.add(pr.Person__c);
                        if(trigger.oldMap.get(pr.Id).Person__c != pr.person__c)
                            parntLookupIds.add(trigger.oldMap.get(pr.Id).Person__c);
                    }else
                        pr.Person__c.addError('You Can olny Select Grand Parent Record');
                    
                }else if(rtyMap.get(pr.RecordTypeId).getName() == 'Child'){
                    if(rtyMap.get(recTypMap.get(pr.Person__c)).getName() == 'Parent'){
                        childLookupIds.add(pr.Person__c);
                        if(trigger.oldMap.get(pr.Id).Person__c != pr.person__c)
                            childLookupIds.add(trigger.oldMap.get(pr.Id).Person__c);
                    }else
                        pr.Person__c.addError('You Can olny Select Parent Record');
                }
            }
            
            if(!parntLookupIds.isEmpty() || !childLookupIds.isEmpty())
                PropertySumTriggerHandler.updatePropertySumAfter(parntLookupIds,childLookupIds);
        }
        
        if(trigger.isDelete){
            for(Person__c pr : trigger.Old){
                if(rtyMap.containsKey(pr.RecordTypeId) && pr.Person__c != null){
                    if(rtyMap.get(pr.RecordTypeId).getName() == 'Parent'){
                        parntLookupIds.add(pr.Person__c);
                    }else if(rtyMap.get(pr.RecordTypeId).getName() == 'Child'){
                        childLookupIds.add(pr.Person__c);
                    }
                }
            }
            if(!parntLookupIds.isEmpty() || !childLookupIds.isEmpty())
                PropertySumTriggerHandler.updatePropertySumAfter(parntLookupIds,childLookupIds);
        }
    }
}