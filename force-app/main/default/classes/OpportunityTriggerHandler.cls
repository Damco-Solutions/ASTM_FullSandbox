/**
 * Created by wmccu on 9/24/2020.
 */

public without sharing class OpportunityTriggerHandler extends TriggerHandler {
    private Map<Id, Opportunity> oldOpportunityMap;
    private Map<Id, Opportunity> newOpportunityMap;
    private List<Opportunity> newOpportunityList;
    private List<Opportunity> oldOpportunityList;
    private Id astmRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('ASTM').getRecordTypeId();

    public OpportunityTriggerHandler() {
        this.oldOpportunityMap = (Map<Id, Opportunity>) Trigger.oldMap;
        this.newOpportunityMap = (Map<Id, Opportunity>) Trigger.newMap;
        this.oldOpportunityList = (List<Opportunity>) Trigger.old;
        this.newOpportunityList = (List<Opportunity>) Trigger.new;
    }

    public override void beforeInsert() {
        //set initial values
        OpportunityActions.setOpportunityValuesBeforeInsert(newOpportunityList);
        //calculate growth
        List<Opportunity> growthOpportunities = getGrowthOpportunityList();
        Map<Id, Account> accountMap = getAccountMap(growthOpportunities);
        OpportunityActions.validateNewBusiness(growthOpportunities, accountMap);
        Map<String, List<Opportunity>> opportunityMap = getOpportunitiesToSetGrowthBeforeInsert(growthOpportunities, accountMap);
//        System.debug(opportunityMap);
        if (opportunityMap.containsKey('Amount')) {
            OpportunityActions.setAmountAsGrowth(opportunityMap.get('Amount'));
        }
        if (opportunityMap.containsKey('Zero')) {
            OpportunityActions.setZeroAsGrowth(opportunityMap.get('Zero'));
        }
        if (opportunityMap.containsKey('Calculate')) {
            OpportunityActions.calculateGrowth(opportunityMap.get('Calculate'));
        }
        //set contract for change of scope opportunities
        OpportunityActions.linkContractForChangeOfScopeOpportunities(getNewOpportunitiesLinkContract(newOpportunityList));
    }
    public override void beforeUpdate() {
        //change values if needed
        List<Opportunity> changedRecordTypeId = getListFromChangedField(oldOpportunityMap, newOpportunityMap, 'RecordTypeId');
        if (changedRecordTypeId.size() > 0) {
            OpportunityActions.setPriceBookBeforeUpdate(changedRecordTypeId);
        }
        List<Opportunity> changedApprovalStatus = getListFromChangedField(oldOpportunityMap, newOpportunityMap, 'Approval_Status__c');
        if (changedApprovalStatus.size() > 0) {
            OpportunityActions.setApprovalDateBeforeUpdate(changedApprovalStatus);
        }
        //calculate growth
        List<Opportunity> growthOpportunities = getGrowthOpportunityList();
        Map<Id, Account> accountMap = getAccountMap(growthOpportunities);
        OpportunityActions.validateNewBusiness(getOpportunitiesWhereTypeChanged(newOpportunityMap, oldOpportunityMap), accountMap);
        Map<String, List<Opportunity>> opportunityMap = getOpportunitiesToSetGrowthBeforeInsert(growthOpportunities, accountMap);
//        System.debug(opportunityMap);
        if (opportunityMap.containsKey('Amount')) {
            OpportunityActions.setAmountAsGrowth(opportunityMap.get('Amount'));
        }
        if (opportunityMap.containsKey('Zero')) {
            OpportunityActions.setZeroAsGrowth(opportunityMap.get('Zero'));
        }
        if (opportunityMap.containsKey('Calculate')) {
            OpportunityActions.calculateGrowth(opportunityMap.get('Calculate'));
        }
        //set contract for change of scope opportunities
        OpportunityActions.linkContractForChangeOfScopeOpportunities(getUpdatedOpportunitiesLinkContract(newOpportunityMap, oldOpportunityMap));
        OpportunityActions.resetOpportunityFields(newOpportunityList);
    }
    public override void afterInsert() {
        OpportunityActions.addContractsForNewOpportunities(getNewOpportunitiesContractRequired(newOpportunityList));
        OpportunityActions.activateRelatedContract(getClosedWonOpportunitiesFromInserted(newOpportunityMap));
    }
    public override void afterUpdate() {
        if (System.isBatch() || System.isFuture()) {
            OpportunityActions.addContractsForUpdatedOpportunities(getUpdatedOpportunitiesContractRequired(newOpportunityMap, oldOpportunityMap));
        } else {
            OpportunityActions.addContractsForUpdatedOpportunitiesFuture(getUpdatedOpportunitiesContractRequired(newOpportunityMap, oldOpportunityMap));
        }
        OpportunityActions.activateRelatedContract(getClosedWonOpportunitiesFromUpdated(newOpportunityMap, oldOpportunityMap));
    }

    private static List<Opportunity> getNewOpportunitiesContractRequired(List<Opportunity> newOpportunities) {
        List<Opportunity> createContractOpportunities = new List<Opportunity>();
        for (Opportunity opportunity : newOpportunities) {
            if (opportunity.Contract_Required__c == 'Yes' && opportunity.Change_of_Scope__c == false) {
                createContractOpportunities.add(opportunity);
            }
        }
        return createContractOpportunities;
    }
    private static Set<Id> getUpdatedOpportunitiesContractRequired(Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap) {
        Set<Id> changedOpportunityIds = new Set<Id>();
        for (Id id : newMap.keySet()) {
            Opportunity newOpportunity = newMap.get(id);
            Opportunity oldOpportunity = oldMap.get(id);
            if (newOpportunity.Contract_Required__c == 'Yes' &&
                    newOpportunity.Contract_Required__c != oldOpportunity.Contract_Required__c &&
                    newOpportunity.Change_of_Scope__c == false) {
                changedOpportunityIds.add(id);
            }
        }
        return changedOpportunityIds;
    }
    private static List<Opportunity> getNewOpportunitiesLinkContract(List<Opportunity> newOpportunities) {
        List<Opportunity> linkContractOpportunities = new List<Opportunity>();
        for (Opportunity opportunity : newOpportunities) {
            if (opportunity.Contract_Required__c == 'Yes' && opportunity.Change_of_Scope__c == true) {
                linkContractOpportunities.add(opportunity);
            }
        }
        return linkContractOpportunities;
    }
    private static List<Opportunity> getUpdatedOpportunitiesLinkContract(Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap) {
        List<Opportunity> linkContractOpportunities = new List<Opportunity>();
        for (Id id : newMap.keySet()) {
            Opportunity newOpportunity = newMap.get(id);
            Opportunity oldOpportunity = oldMap.get(id);
            if (newOpportunity.Contract_Required__c == 'Yes' &&
                    newOpportunity.Contract_Required__c != oldOpportunity.Contract_Required__c &&
                    newOpportunity.Change_of_Scope__c == true) {
                linkContractOpportunities.add(newOpportunity);
            }
        }
        return linkContractOpportunities;
    }
    @TestVisible
    private static Map<String, List<Opportunity>> getOpportunitiesToSetGrowthBeforeInsert(List<Opportunity> opportunities, Map<Id, Account> accountMap) {
//        System.debug(opportunities);
        Map<String, List<Opportunity>> mapGrowthOpportunities = new Map<String, List<Opportunity>>();
        for (Opportunity opportunity : opportunities) {
            Account currentAccount = accountMap.get(opportunity.AccountId);
            String growthType = getGrowthCalculationType(opportunity, currentAccount);
            if (mapGrowthOpportunities.containsKey(growthType)) {
                List<Opportunity> addOpportunities = mapGrowthOpportunities.get(growthType);
                addOpportunities.add(opportunity);
                mapGrowthOpportunities.put(growthType, addOpportunities);
            } else {
                List<Opportunity> newOpportunities = new List<Opportunity>();
                newOpportunities.add(opportunity);
                mapGrowthOpportunities.put(growthType, newOpportunities);
            }
        }
        return mapGrowthOpportunities;
    }
    private static Map<Id, Account> getAccountMap(List<Opportunity> opportunities) {
        Set<Id> accountIds = new Set<Id>();
        for (Opportunity opportunity : opportunities) {
            if (!accountIds.contains(opportunity.AccountId)) {
                accountIds.add(opportunity.AccountId);
            }
        }
        return new Map<Id, Account> ([SELECT Id, Account_Mgt__c FROM Account WHERE Id IN:accountIds]);
    }
    @TestVisible
    private static String getGrowthCalculationType(Opportunity opportunity, Account account) {
        GrowthCalculationMap growthMap = GrowthCalculationMap.getInstance();
        String growthType = 'NoMatch';
        String accountManagement = String.isNotBlank(account.Account_Mgt__c) ? account.Account_Mgt__c.trim() : '';
        String subscriptionType = String.isNotBlank(opportunity.Type) ? opportunity.Type.trim() : '';
        String keyValue = accountManagement + subscriptionType;
        if (growthMap.growthCalculationMapStringsByStrings.containsKey(keyValue)) {
            growthType = growthMap.growthCalculationMapStringsByStrings.get(keyValue);
        }
        return growthType;
    }
    private static Set<Id> getClosedWonOpportunitiesFromInserted(Map<Id, Opportunity> newMap) {
        Set<Id> closedWon = new Set<Id>();
        for (Id id : newMap.keySet()) {
            if (newMap.get(id).StageName == 'Closed Won') {
                closedWon.add(id);
            }
        }
        return closedWon;
    }
    private static Set<Id> getClosedWonOpportunitiesFromUpdated(Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap) {
        Set<Id> closedWon = new Set<Id>();
        for (Id id : newMap.keySet()) {
            String currentStageName = newMap.get(id).StageName;
            if (oldMap.get(id).StageName != currentStageName && currentStageName == 'Closed Won') {
                closedWon.add(id);
            }
        }
        return closedWon;
    }
    private static List<Opportunity> getOpportunitiesWhereTypeChanged(Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap) {
        List<Opportunity> typeChanged = new List<Opportunity>();
        for (Id id : newMap.keySet()) {
            String currentType = newMap.get(id).StageName;
            if (oldMap.get(id).Type != currentType && currentType == 'New Business') {
                typeChanged.add(newMap.get(id));
            }
        }
        return typeChanged;
    }
    private static List<Opportunity> getListFromChangedField(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap, String changedFieldName) {
        List<Opportunity> objects = new List<SObject>();
        for (Id id : newMap.keySet()) {
            Opportunity oldRecord = oldMap?.get(id);
            Opportunity newRecord = newMap.get(id);
            if (oldRecord != null) {
                if (oldRecord.get(changedFieldName) != newRecord.get(changedFieldName)) {
                    objects.add(newRecord);
                }
            }
        }
        return objects;
    }
    private List<Opportunity> getGrowthOpportunityList() {
        List<Opportunity> growthOpportunities = new List<Opportunity>();
        for (Opportunity opportunity : newOpportunityList) {
            if (opportunity.RecordTypeId == astmRecordTypeId) {
                growthOpportunities.add(opportunity);
            }
        }
        return growthOpportunities;
    }
    //newtest
        //Country Code for Opportunity
        public static void SetCountryLookup(List<Opportunity> Opps) {
        //assumes Before context in trigger

        //get a list of 2 letter codes for our query on Country__c
        List<String> country2Letter = new List<String>();
        for(Opportunity acc: Opps) {
            if(!country2Letter.contains(acc.Account_Country__c)) {
                if(acc.Account_Country__c!= null) {
                    country2Letter.add(acc.Account_Country__c);
                }
            }               
        }
        System.debug(country2Letter);
    
        //Get a map of 2 letter codes to Country__c to set fields on Opportunity
        Map<String, Country__c> mapCountries = new Map<String, Country__c>();
        List<Country__c> countries = [SELECT Id, Name, country2Letter__c, Region__c  FROM Country__c WHERE country2Letter__c IN: country2Letter];
        for (Country__c country: countries) {
            mapCountries.put(country.country2Letter__c, country);
        }
        //loop through our Opps and update the fields
        for (Opportunity a: Opps) {
            if(a.Account_Country__c != null) {
                Country__c cntry = mapCountries.get(a.Account_Country__c);
                if(cntry != null) {
                    a.Country__c = cntry.Id;
                }
            }
        }
    } //new
    
}