global class CreateAccountAndRelated implements Schedulable {

    private RandomDataGenerator generator = new RandomDataGenerator();
    
    Id PricebookId;
    List<PriceBookEntry> PricebookEntries;
        
    RandomDataGenerator randomizer = new RandomDataGenerator();
    
    public void Initialise() {
        PricebookId = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1].Id;
        PricebookEntries = [SELECT Id, Product2Id, Product2.Id, Product2.Name FROM PriceBookEntry WHERE Pricebook2Id = :PricebookId];
    }
    
    public void FillUpInactiveAccounts(Integer targetNumber) {
        List<Id> accountIds = GetGermanAccountIds();
        
        List<Account> newAccounts = new List<Account>();
        for (Integer i=accountIds.size(); i<targetNumber; i++) {
            newAccounts.Add(CreateGermanAccount());
        }
        
        List<Opportunity> newOpps = new List<Opportunity>();
        List<Case> newCases = new List<Case>();
        List<Contact> contactsToInsert = new List<Contact>();
        Database.SaveResult[] results = Database.insert(newAccounts);
        for (Database.SaveResult result : results) {
            for (Integer i=0; i<generator.GetRandomNumber(4); i++)
            {
                newOpps.Add(CreateOpportunityOnAccount(result.Id));
            }
            for (Integer i=0; i<generator.GetRandomNumber(4); i++)
            {
                contactsToInsert.Add(CreateContactOnAccount(result.Id));
            }
            for (Integer i=0; i<generator.GetRandomNumber(4); i++)
            {
                newCases.Add(CreateRandomCase(result.Id));
            }
        }
        Database.insert(contactsToInsert);
        Database.insert(newCases);
        
        
        List<sObject> OLIsToInsert = new List<sObject>();
        Database.SaveResult[] newOppResults = Database.insert(newOpps);
        for (Database.SaveResult result : newOppResults) {
            for (Integer i=0; i<generator.GetRandomNumber(4); i++)
            {
                OLIsToInsert.Add(CreateOpportunityLineItem(result.Id));
            }
        }
        Database.insert(OLIsToInsert);
    }
    
    private List<Id> GetGermanAccountIds() {
        List<Account> accountList = [SELECT Id FROM Account WHERE BillingCountry = 'Germany'];
        
        List<Id> ids = new List<Id>();
        for (Account account: accountList) {
            ids.add(account.Id);
        }
        
        return ids;
    }
    
    private Account CreateGermanAccount() {
        Account newAccount = new Account(
            Name = generator.GenerateRandomCompany(),
            Description = generator.GenerateRandomString(20),
            CustomerPriority__c = 'Medium',
            SLAExpirationDate__c = Date.today().addYears(-3).addDays(-5),
            BillingStreet = generator.GetRandomNumber(1000) + ' ' + generator.GenerateRandomLastName() + ' Strasse',
            BillingCity = generator.GenerateRandomLastName() + 'burg',
            BillingCountry = 'Germany'
        );
        
        return newAccount;
    }
    
    private Pricebook2 GetPricebook2Id() {
        return [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
    }
    
    private PriceBookEntry GetRandomPriceBookEntryOnPricebook(Id pricebookId) {
        
        Integer priceBookEntryIndex = Math.floor(Math.random() * PricebookEntries.size()).intValue();
        return PricebookEntries.get(priceBookEntryIndex);
    }
    
    private OpportunityLineItem CreateOpportunityLineItem(Id opportunityId) {
        
        PriceBookEntry priceBookEntry = GetRandomPriceBookEntryOnPricebook(PricebookId);
        
        OpportunityLineItem newOpportunityLineItem = new OpportunityLineItem();
        newOpportunityLineItem.OpportunityId = opportunityId; 
        newOpportunityLineItem.PricebookEntryId = priceBookEntry.Id;
        newOpportunityLineItem.Quantity = 1 + randomizer.GetRandomNumber(20);
        newOpportunityLineItem.TotalPrice = 1 + randomizer.GetRandomNumber(2000);
        
        return newOpportunityLineItem;
    }
    
    
    private Opportunity CreateOpportunityOnAccount(Id accountId) {
        Opportunity newOpportunity = new Opportunity();
        newOpportunity.Description =  randomizer.GenerateRandomStringOfMaxLength(20); 
        newOpportunity.Name = randomizer.GenerateRandomCompany();
        newOpportunity.StageName = 'Stage1';
        newOpportunity.CloseDate =  date.newInstance(2020, 5, 1);
        newOpportunity.AccountId = accountId;
        newOpportunity.Pricebook2Id = PricebookId;
        
        return newOpportunity;
    }
    
    
    private Contact CreateContactOnAccount(Id accountId) {
        Contact newContact = new Contact();
        newContact.FirstName = randomizer.GenerateRandomFirstName();
        newContact.LastName = randomizer.GenerateRandomLastName();
        newContact.Description = randomizer.GenerateRandomStringOfMaxLength(20);
        newContact.AccountId = accountId;
        
        return newContact;
    }
    
    private Case CreateRandomCase(Id accountId) {
        Case newCase = new Case();
        newCase.IsEscalated = randomizer.GenerateRandomBool();
        newCase.Reason = randomizer.GenerateRandomStringOfMaxLength(10);
        newCase.AccountId = accountId;
        
        return newCase;
    }
    
    global void execute(SchedulableContext ctx) {
        Initialise();
        FillUpInactiveAccounts(50);
    }  
    
}