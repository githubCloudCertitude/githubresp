public class PropertySumTriggerHandler {
    public static Map<ID, Schema.RecordTypeInfo> rtyMap = Schema.SObjectType.Person__c.getRecordTypeInfosById();
    public static Map<Id,Person__c> PersonaMap = new Map<Id,Person__c>();
    public static Set<Id> grndIds = new Set<Id>();
    
    /*public static void updateThePropertySum(Set<Id> parntLookupIds, Set<Id> childLookupIds){
        
        if(!childLookupIds.isEmpty()){
            for(AggregateResult P_agr : [SELECT Person__c, Sum(My_Property__c)prSum from Person__c WHERE Person__c In: childLookupIds GROUP BY Person__c]){
                Person__c pr = new Person__c();
                pr.Id = (Id) P_agr.get('Person__c');
                system.debug('pr.Id  '+pr.Id);
                pr.Child_Property_Sum__c = (Decimal) P_agr.get('prSum');
                PersonaMap.put(pr.Id,pr);
            }
            system.debug('PersonaMap====> '+PersonaMap.keySet());
            
            if(!PersonaMap.isEmpty()){
                update PersonaMap.Values();
                
                for(Person__c pr : [SELECT Id, Person__c FROM Person__c WHERE Id In : PersonaMap.KeySet()]){
                    grndIds.add(pr.Person__c);
                }
                system.debug('grndIds '+grndIds);
            }            
            if(!grndIds.isEmpty()){
                PersonaMap.clear();
                for(AggregateResult G_agr : [SELECT Person__c, Sum(Child_Property_Sum__c)chSum from Person__c WHERE Person__c In : grndIds GROUP BY Person__c]){
                    Person__c pr = new Person__c();
                    pr.Id = (Id) G_agr.get('Person__c');
                    pr.Child_Grand_Child_Property_Sum__c = (Decimal) G_agr.get('chSum');
                    PersonaMap.put(pr.Id,pr);
                }
            }
            if(!PersonaMap.isEmpty())
                update PersonaMap.Values();
        }
        
        if(!parntLookupIds.isEmpty()){
            PersonaMap.clear();
            for(AggregateResult G_agr : [SELECT Person__c, Sum(My_Property__c)chSum from Person__c WHERE Person__c In: parntLookupIds GROUP BY Person__c]){
                Person__c pr = new Person__c();
                pr.Id = (Id) G_agr.get('Person__c');
                pr.Child_Property_Sum__c = (Decimal) G_agr.get('chSum');
                PersonaMap.put(pr.Id,pr);
            }
            if(!PersonaMap.isEmpty())
                update PersonaMap.Values();
        }
        
    }*/
    
    public static void updatePropertySumAfter(Set<Id> parntLookupIds, Set<Id> childLookupIds){
        if(!childLookupIds.isEmpty()){
            PersonaMap.clear();
            Map<Id,Decimal> ParentMap = new Map<Id,Decimal>();
            Set<Id> GrandIds = new Set<Id>();
            for(Person__c pr : [SELECT Id, Child_Property_Sum__c, Person__c, (SELECT Id, My_Property__c, Person__c FROM Persons__r) FROM Person__c WHERE Id In: childLookupIds]){
                if(!pr.Persons__r.isEmpty()){
                    for(Person__c ch : pr.Persons__r){
                        Decimal ps = ch.My_Property__c != null ? ch.My_Property__c : 0.00;
                        if(ParentMap.containsKey(ch.Person__c))
                            ParentMap.put(ch.Person__c, ParentMap.get(ch.Person__c) + ps);
                        else
                            ParentMap.put(ch.Person__c,ps);
                    }
                    pr.Child_Property_Sum__c = ParentMap.get(pr.Id);
                    PersonaMap.put(pr.Id,pr);
                }else{
                    pr.Child_Property_Sum__c = 0.00;
                    PersonaMap.put(pr.Id,pr);
                }
                GrandIds.add(pr.Person__c);
            }
            
            if(!PersonaMap.isEmpty()){
                update PersonaMap.values();
                if(!GrandIds.isEmpty()){
                    PersonaMap.clear();
                    Map<Id,Decimal> GrandMap = new Map<Id,Decimal>();
                    for(Person__c Gpr : [SELECT Id, Child_Grand_Child_Property_Sum__c, (SELECT Id, Child_Property_Sum__c, Person__c FROM Persons__r) FROM Person__c WHERE Id In: GrandIds]){
                        if(!Gpr.Persons__r.isEmpty()){
                            for(Person__c pr : Gpr.Persons__r){
                                Decimal cps = pr.Child_Property_Sum__c != null ? pr.Child_Property_Sum__c : 0.00;
                                if(GrandMap.containsKey(pr.Person__c))
                                    GrandMap.put(pr.Person__c, GrandMap.get(pr.Person__c) + cps);
                                else
                                    GrandMap.put(pr.Person__c, cps);
                            }
                            Gpr.Child_Grand_Child_Property_Sum__c = GrandMap.get(Gpr.Id);
                            PersonaMap.put(Gpr.Id,Gpr);
                        }else{
                            Gpr.Child_Grand_Child_Property_Sum__c = 0.00;
                            PersonaMap.put(Gpr.Id,Gpr);
                        }
                    }
                    if(!PersonaMap.isEmpty())
                        update PersonaMap.values();
                    
                }
            }
        }
        if(!parntLookupIds.isEmpty()){
            PersonaMap.clear();
            Map<Id,Decimal> GrandMap = new Map<Id,Decimal>();
            Map<Id,Decimal> GrandChildMap = new Map<Id,Decimal>();
            for(Person__c Gpr : [SELECT Id, Child_Grand_Child_Property_Sum__c,Child_Property_Sum__c, (SELECT Id, Child_Property_Sum__c, My_Property__c, Person__c FROM Persons__r) FROM Person__c WHERE Id In: parntLookupIds]){
                if(!Gpr.Persons__r.isEmpty()){
                    for(Person__c pr : Gpr.Persons__r){
                        Decimal cps = pr.Child_Property_Sum__c != null ? pr.Child_Property_Sum__c : 0.00;
                        if(GrandChildMap.containsKey(pr.Person__c))
                            GrandChildMap.put(pr.Person__c, GrandChildMap.get(pr.Person__c) + cps);
                        else
                            GrandChildMap.put(pr.Person__c, cps);
                        
                        Decimal ps = pr.My_Property__c != null ? pr.My_Property__c : 0.00;
                        if(GrandMap.containsKey(pr.Person__c))
                            GrandMap.put(pr.Person__c, GrandMap.get(pr.Person__c) + ps);
                        else
                            GrandMap.put(pr.Person__c, ps);
                        
                    }
                    Gpr.Child_Grand_Child_Property_Sum__c = GrandChildMap.get(Gpr.Id);
                    Gpr.Child_Property_Sum__c = GrandMap.get(Gpr.Id);
                    PersonaMap.put(Gpr.Id,Gpr);
                }else{
                    Gpr.Child_Grand_Child_Property_Sum__c = 0.00;
                    Gpr.Child_Property_Sum__c = 0.00;
                    PersonaMap.put(Gpr.Id,Gpr);
                }
            }
            if(!PersonaMap.isEmpty())
                update PersonaMap.values();
        }
        
    }
}