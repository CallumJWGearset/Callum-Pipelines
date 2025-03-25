trigger HelloWorldTrigger on ArchivingObject__c(after delete) {
    System.debug('Hello World!');
}