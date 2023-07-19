trigger updateSerial on Contact (before insert) {
    if(trigger.isBefore){
        if(trigger.isInsert){
            contactSerialNoHandler.insertOprSerial(trigger.new);
        }
    }
}