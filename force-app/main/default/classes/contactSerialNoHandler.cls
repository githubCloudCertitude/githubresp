public class contactSerialNoHandler {
	public static void insertOprSerial(list<Contact> conList){
		set<Id> AccIds = new Set<Id>();
		Map<Id,Decimal> mapConAcc = new Map<Id,Decimal>();
        list<Contact> newConList = new list<contact>();
		for(Contact c : conList){
			if(c.AccountId != null){
				AccIds.add(c.AccountId);
			}
		}
		
		if(!AccIds.isEmpty()){
            for(Account Acc : [SELECT Id, maxCon__c FROM Account WHERE Id IN : AccIds]){
                if(Acc.maxCon__c == null)
                    Acc.maxCon__c = 0;
                
                 mapConAcc.put(Acc.Id,Acc.maxCon__c);
            }
			
			for(contact c : conList){
                if(c.AccountId != null){
                    if(mapConAcc.containsKey(c.AccountId)){
                        c.SerialNo__c = mapConAcc.get(c.AccountId) + 1;
                        mapConAcc.put(c.AccountId,c.SerialNo__c);
                    }else{
                        c.SerialNo__c = 1;
                        mapConAcc.put(c.AccountId,c.SerialNo__c);
                    }
                }
			}
            
            if(!mapConAcc.keySet().isEmpty()){
                list<Account> AccList = new List<Account>();
                for(Id AcId : mapConAcc.keySet()){
                    Account Acc = new Account();
                    Acc.Id = AcId;
                    Acc.maxCon__c = mapConAcc.get(AcId);
                    AccList.add(Acc);
                } 
                
                if(!AccList.isEmpty()){
                    update AccList;
                }
            }
		}
		
	}
}