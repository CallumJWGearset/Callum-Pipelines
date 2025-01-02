global class CreateRecords implements Schedulable {
    
    private RandomDataGenerator generator = new RandomDataGenerator();
    
    private Integer c_ExpectedAccounts = 50;
    
    public void FillUpInactiveCasesAndTasks(Integer targetNumberOfCases, Integer targetNumberOfTasks) {
        List<Id> inativeAccountIds = FillUpInactiveAccounts(c_ExpectedAccounts);
        
        // Cases
        List<Id> casesOnInactiveAccount = GetCasesOnInactiveAccountIds();
        
        List<Case> newCases = new List<Case>();
        for (Integer i=casesOnInactiveAccount.size(); i<targetNumberOfCases; i++) {
            Id accountId = inativeAccountIds[Math.Mod(i, inativeAccountIds.size())];
            newCases.Add(CreateCase(accountId));
        }
        
        Database.SaveResult[] results = Database.insert(newCases);
        
        List<Id> newCaseIds = new List<Id>();
        for(Database.SaveResult result : results) {
            newCaseIds.Add(result.Id);
            casesOnInactiveAccount.Add(result.Id);
        }
        
        AttachFilesForRecords(newCaseIds);
        
        // Tasks
        List<Id> tasksOnInactiveAccount = GetTasksOnAccounts();
        
        List<Task> newTasks = new List<Task>();
        for (Integer i=tasksOnInactiveAccount.size(); i<targetNumberOfTasks; i++) {
            Id accountId = inativeAccountIds[Math.Mod(i, inativeAccountIds.size())];
            newTasks.Add(CreateTask(accountId));
        }
        Database.insert(newTasks);
    }
    
    private List<Id> FillUpInactiveAccounts(Integer targetNumber) {
        List<Id> inativeAccountIds = GetInactiveAccountIds();
        
        List<Account> newAccounts = new List<Account>();
        for (Integer i=inativeAccountIds.size(); i<targetNumber; i++) {
            newAccounts.Add(CreateInactiveAccount());
        }
        
        Database.SaveResult[] results = Database.insert(newAccounts);
        for (Database.SaveResult result : results) {
            inativeAccountIds.add(result.Id);
        }
        
        return inativeAccountIds;
    }
    
    private List<Id> GetInactiveAccountIds() {
        List<Account> accountList = [SELECT Id FROM Account WHERE Active__c = 'No'];
        
        List<Id> ids = new List<Id>();
        for (Account account: accountList) {
            ids.add(account.Id);
        }
        
        return ids;
    }
    
    private List<Id> GetCasesOnInactiveAccountIds() {
        List<Case> casesList = [SELECT Id FROM Case WHERE Account.Active__c = 'No'];
        
        List<Id> ids = new List<Id>();
        for (Case caseResult: casesList) {
            ids.add(caseResult.Id);
        }
        
        return ids;
    }
    
    private List<Id> GetTasksOnAccounts() {
        List<Task> tasksList = [SELECT Id FROM Task WHERE What.Type = 'Account'];
        
        List<Id> ids = new List<Id>();
        for (Task result: tasksList) {
            ids.add(result.Id);
        }
        
        return ids;
    }
    
    private Account CreateInactiveAccount() {
        Account newAccount = new Account(
            Name = generator.GenerateRandomCompany(),
            Description = generator.GenerateRandomString(20),
            CustomerPriority__c = 'Medium',
            Active__c = 'No',
            SLAExpirationDate__c = Date.today().addYears(-2).addDays(-5)
        );
        
        return newAccount;
    }
    
    private Case CreateCase(Id accountId) {
        Case newCase = new Case(
            Subject = 'Problem with ' + generator.GenerateRandomString(3) + generator.GetRandomNumber(1000),
            Description = generator.GenerateRandomString(20),
            Priority = 'Medium',
            Status = 'New', // Setting a default status for new cases,
            AccountId = accountId
        );
        
        return newCase;
    }
    
    private Task CreateTask(Id whatId) {
        Task newTask = new Task(
                Subject = 'Task for ' + generator.GenerateRandomFullName() + generator.GetRandomNumber(1000),
                Status = 'Not Started',
                Priority = 'Normal',
                ActivityDate = Date.today().addYears(-2),
                WhatId = whatId, // Reference the specific record
                OwnerId = UserInfo.getUserId() // Assigning to the current user
            );
        
        return newTask;
    }
    
    private void AttachFilesForRecords(Id[] ids) {
        Integer numIds = ids.size();
        
        List<ContentVersion> files = new List<ContentVersion>();
        for (Integer i = 0; i < numIds; i++) {
            files.add(generator.CreateFile());
        }
        Database.SaveResult[] fileResults = Database.insert(files);
        
        List<Id> fileIds = new List<Id>();
        for (Database.SaveResult fileResult : fileResults) {
            fileIds.add(fileResult.getId());
        }
        
        ContentVersion[] insertedContentVersions = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :fileIds];
        
        List<ContentDocumentLink> cdls = new List<ContentDocumentLink>();
        for (Integer i = 0; i < insertedContentVersions.size(); i++)
        {
            ContentDocumentLink contentDocumentLink = new ContentDocumentLink(
                ContentDocumentId = insertedContentVersions[i].ContentDocumentId,
                LinkedEntityId = ids[i]
            );
        	cdls.add(contentDocumentLink);
        }
        Database.insert(cdls);
    }
    
    global void execute(SchedulableContext ctx) {
        FillUpInactiveCasesAndTasks(100,100);
    } 

}