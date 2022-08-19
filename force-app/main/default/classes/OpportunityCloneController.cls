public with sharing class OpportunityCloneController {

    Opportunity oppty;
    public OpportunityCloneController(ApexPages.StandardController ctl)
    {
        oppty = (Opportunity)ctl.getRecord();
        oppty=[select Id, Name, LeadSource, Contract_Required__c, AccountId, StageName, CloseDate,  Purchase_Order_Number__c from Opportunity where Id = :oppty.Id];
    }
    
    public PageReference CloneOppty(){
        sObject originalSObject = (sObject) oppty;

        List<sObject> originalSObjects = new List<sObject>{originalSObject};
              
        List<sObject> clonedSObjects = SObjectAllFieldCloner.cloneObjects(
                                              originalSobjects,
                                              originalSobject.getsObjectType());
                                             
        Opportunity clonedOppty = (Opportunity)clonedSObjects.get(0);
        //Opportunity clonedOppty = oppty.clone(false, false, false, false);
        
        Integer cloneCount = 0;
        for(AggregateResult ar : [Select count(id) cnt from Opportunity where Original_Opportunity__c = :oppty.Id and Change_of_Scope__c = true])
        {
            cloneCount = Integer.ValueOf(ar.get('cnt'));
        }
        cloneCount ++;
        clonedOppty.Change_of_Scope__c = true;
        clonedOppty.Pricebook2Id = '01sC0000000DZcd';
        clonedOppty.Name = oppty.Name+'-COS'+cloneCount;
        clonedOppty.StageName = oppty.StageName;
        clonedOppty.CloseDate = oppty.CloseDate;
        clonedOppty.AccountId = oppty.AccountId;
        clonedOppty.LeadSource = oppty.LeadSource;
        clonedOppty.Contract_Required__c = 'No';//oppty.Contract_Required__c;
        clonedOppty.Original_Opportunity__c = oppty.Id;
        clonedOppty.Amount = 0;
        insert clonedOppty;
        
        PageReference pageRef = new PageReference('/'+clonedOppty.Id); 
        return pageRef ;
        
        //PageReference p = new PageReference('/'+clonedOppty.Id+'/e');
        //p.getParameters().put('retURL', '/'+clonedOppty.Id);
        //p.setRedirect(true);
        //return p;
    
    }
    public static testMethod void testThisClass(){
        
        Account a = new Account(Name = 'UNITTEST');
        insert(a);
        Contact c = new Contact(AccountId=a.Id, FirstName='Test', LastName = 'Test');
        insert c;
        Opportunity o = new Opportunity(Name = 'UNITTEST', AccountID = a.id, StageName = 'Closed/Won',
        CloseDate = date.today().addDays(30), Amount = 1000);
        insert(o);
        
        Test.startTest();
        
        PageReference pageRef = Page.OpportunityClone;
        pageRef.getParameters().put('type','COS');
        Test.setCurrentPageReference(pageRef);
    
        //Run the test on the controller
        ApexPages.StandardController ctl = new ApexPages.StandardController(o);
        OpportunityCloneController oc = new OpportunityCloneController(ctl);
        oc.CloneOppty();
    } 
}