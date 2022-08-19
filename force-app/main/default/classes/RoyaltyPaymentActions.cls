/**
 * Created by johnpernock from OpenGate Consulting on 11/11/19.
 */

public without sharing class RoyaltyPaymentActions {
    //TODO Remove this method - switched to using Opportunity as the royalty request on 2021-02-01
    @InvocableMethod(Label='Create Payments from Requests')
    public static void createPaymentsFromRequests() {
        List<Royalty_Request__c> requests = [
                SELECT Id, Royalty_Payment__c, Royalty_Amount__c, Account__c, Account__r.OwnerId, Payment_Date__c, Payment_Frequency__c
                FROM Royalty_Request__c
                WHERE Approval_Status__c = 'Approved' AND Royalty_Payment__c = NULL AND Approval_Date__c = THIS_MONTH
        ];
        //Set up Lists / Sets for Use Later
        Set<Id> resellerIds = new Set<Id>();
        List<Royalty_Payment__c> paymentsToInsert = new List<Royalty_Payment__c>();
        List<Royalty_Request__c> requestsToUpdate = new List<Royalty_Request__c>();
        //Create Set of Royalty Request Accounts (For Resellers on Payments)
        for (Royalty_Request__c request : requests) {
            if (!resellerIds.contains(request.Account__c)) {
                resellerIds.add(request.Account__c);
            }
        }
        for (Id reseller : resellerIds) {
            Decimal totalPayment = 0.0;
            Id ownerId = null;
            //Add together royalty payments for each request to only create one Payment Object.
            for (Royalty_Request__c request : requests) {
                if (request.Account__c == reseller && request.Royalty_Amount__c > 0) {
                    totalPayment = totalPayment + request.Royalty_Amount__c; if (ownerId == null) {
                        ownerId = request.Account__r.OwnerId;
                    }
                }
            }
            //Create Royalty Payment for Reseller
            Royalty_Payment__c payment = new Royalty_Payment__c();
            payment.Reseller__c = reseller;
            payment.Type__c = 'Subscription';
            payment.Royalty_Amount__c = totalPayment;
            payment.Status__c = 'New';
            payment.Owner__c = ownerId;
            //Add Payment Object to List for Bulkification
            paymentsToInsert.add(payment);
        }
        //Insert Payment Objects
        insert paymentsToInsert;
        //Loop Through and Update Requests with Payment Id after Insert
        for (Id reseller : resellerIds) {
            Id paymentId = null;
            for (Royalty_Payment__c payment : paymentsToInsert) {
                System.debug(payment);
                if (payment.Reseller__c == reseller) {
                    paymentId = payment.Id;
                    break;
                }
            }
            for (Royalty_Request__c request : requests) {
                if (request.Account__c == reseller && paymentId != null) {
                    //Updated Payment Date for next Royalty Run
                    if (request.Payment_Date__c != null && request.Payment_Frequency__c != null) {
                        if (request.Payment_Frequency__c == 'Annually') {
                            request.Payment_Date__c = request.Payment_Date__c.addYears(1);
                        } else if (request.Payment_Frequency__c == 'Quarterly') {
                            request.Payment_Date__c = request.Payment_Date__c.addMonths(3);
                        } else if (request.Payment_Frequency__c == 'Monthly') {
                            request.Payment_Date__c = request.Payment_Date__c.addMonths(1);
                        }
                    }
                    request.Royalty_Payment__c = paymentId;
                    //Update Request into List for Bulkification
                    requestsToUpdate.add(request);
                }
            }
        }
        //Update Request List
        update requestsToUpdate;

    }
    public static void createPaymentsForResellers(Set<Id> accountIds, Date asOfDate) {
        Date today = asOfDate != null ? asOfDate : Date.today();
        Date firstDayOfCurrentMonth = today.toStartOfMonth();
        Date lastDayOfPreviousMonth = getEndOfLastMonth(today);
        Date firstDayOfPreviousMonth = lastDayOfPreviousMonth.toStartOfMonth();
        Date twoYearAgoDate = firstDayOfCurrentMonth.addYears(-2);
        Map<Id, List<Opportunity>> opportunitiesByAccountIds = new Map<Id, List<Opportunity>>();
        List<Opportunity> opportunities = [
                SELECT Id, AccountId, Royalty_Payment__c, Royalty_Amount__c, Account.OwnerId,
                        Account.Royalty_Processing_Date__c, Account.Royalty_Processing__c, Payment_Date__c,
                        Payment_Frequency__c, Approval_Date__c, Amount
                FROM Opportunity
                WHERE Approval_Status__c = 'Approved'
                AND Royalty_Payment__c = NULL
                AND Approval_Date__c < :firstDayOfCurrentMonth
                AND Approval_Date__c >= :twoYearAgoDate
                AND RecordType.Name = 'Royalty'
                AND AccountId IN :accountIds
        ];
        for (Opportunity opportunity : opportunities) {
            if (opportunitiesByAccountIds.containsKey(opportunity.AccountId)) {
                List<Opportunity> currentOpportunities = opportunitiesByAccountIds.get(opportunity.AccountId);
                currentOpportunities.add(opportunity);
                opportunitiesByAccountIds.put(opportunity.AccountId, currentOpportunities);
            } else {
                List<Opportunity> addOpportunities = new List<Opportunity>();
                addOpportunities.add(opportunity);
                opportunitiesByAccountIds.put(opportunity.AccountId, addOpportunities);
            }
        }
        //process map and remove opportunities that don't fall within the date range for the reseller
        for (Id id : opportunitiesByAccountIds.keySet()) {
            List<Opportunity> currentOpportunities = opportunitiesByAccountIds.get(id);
            opportunitiesByAccountIds.remove(id);
            Opportunity firstOpportunity = currentOpportunities[0];
            ResellerPayDates currentPayDates = getResellerPayDates(firstOpportunity.Account.Royalty_Processing__c,
                    firstOpportunity.Account.Royalty_Processing_Date__c, firstDayOfPreviousMonth, lastDayOfPreviousMonth, today);
            if (currentPayDates.shouldPay) {
                List<Opportunity> opportunitiesToPay = new List<Opportunity>();
                for (Opportunity opportunity : currentOpportunities) {
                    if (opportunity.Approval_Date__c >= currentPayDates.startDate && opportunity.Approval_Date__c <= currentPayDates.endDate) {
                        opportunitiesToPay.add(opportunity);
                    }
                }
                opportunitiesByAccountIds.put(id, opportunitiesToPay);
            }
        }
        List<Royalty_Payment__c> royaltyPayments = new List<Royalty_Payment__c>();
        for (Id id : opportunitiesByAccountIds.keySet()) {
            List<Opportunity> relatedOpportunities = opportunitiesByAccountIds.get(id);
            if (relatedOpportunities.size() > 0) {
                Id accountOwnerId = relatedOpportunities[0].Account.OwnerId;
                //Create Royalty Payment for Reseller
                Royalty_Payment__c payment = new Royalty_Payment__c();
                payment.Reseller__c = id;
                payment.Type__c = 'Subscription';
                payment.Royalty_Amount__c = getSumOfOpportunities(relatedOpportunities);
                payment.Status__c = 'New';
                payment.Owner__c = accountOwnerId;
                royaltyPayments.add(payment);
            }
        }
        insert royaltyPayments;
        //get map of royalty payments to set field on opportunity
        Map<Id, Royalty_Payment__c> royaltyPaymentByAccountId = new Map<Id, Royalty_Payment__c>();
        for (Royalty_Payment__c royaltyPayment : royaltyPayments) {
            if (!royaltyPaymentByAccountId.containsKey(royaltyPayment.Reseller__c)) {
                royaltyPaymentByAccountId.put(royaltyPayment.Reseller__c, royaltyPayment);
            }
        }
        System.debug(royaltyPaymentByAccountId);
        //update Royalty_Payment__c field on Opportunities
        List<Opportunity> updateOpportunities = new List<Opportunity>();
        for (Id id : opportunitiesByAccountIds.keySet()) {
            List<Opportunity> currentOpportunities = opportunitiesByAccountIds.get(id);
            for (Opportunity opportunity : currentOpportunities) {
                updateOpportunities.add(new Opportunity(
                        Id = opportunity.Id,
                        Royalty_Payment__c = royaltyPaymentByAccountId.get(opportunity.AccountId).Id
                ));
            }
        }
        TriggerHandler.bypass('OpportunityTriggerHandler');
        update updateOpportunities;
        TriggerHandler.clearBypass('OpportunityTriggerHandler');
    }
    private static ResellerPayDates getResellerPayDates(String royaltyProcessing, Date royaltyProcessingDate, Date firstDateLastMonth, Date lastDateLastMonth, Date today) {
        ResellerPayDates resellerPayDates = new ResellerPayDates();
        //set return to last month since this is the default case
        resellerPayDates.shouldPay = true;
        resellerPayDates.startDate = firstDateLastMonth;
        resellerPayDates.endDate = lastDateLastMonth;
        if (String.isNotBlank(royaltyProcessing) && royaltyProcessingDate != null) {
            //check for quarterly or annually
            if (royaltyProcessing == 'Quarterly' && royaltyProcessingDate != null) {
                if (today < royaltyProcessingDate.addMonths(3)) {
                    resellerPayDates.shouldPay = false;
                    return resellerPayDates;
                } else {
                    //do we pay this quarterly reseller
                    if (doWePay(today, royaltyProcessingDate, royaltyProcessing)) {
                        resellerPayDates.shouldPay = true;
                        resellerPayDates.startDate = firstDateLastMonth.addMonths(-2);
                        resellerPayDates.endDate = lastDateLastMonth;
                        return resellerPayDates;
                    }
                }
            } else if (royaltyProcessing == 'Annually' && royaltyProcessingDate != null) {
                if (today < royaltyProcessingDate.addYears(1)) {
                    resellerPayDates.shouldPay = false;
                    return resellerPayDates;
                } else {
                    if (doWePay(today, royaltyProcessingDate, royaltyProcessing)) {
                        resellerPayDates.shouldPay = true;
                        resellerPayDates.startDate = lastDateLastMonth.addMonths(-12);
                        resellerPayDates.endDate = lastDateLastMonth;
                        return resellerPayDates;
                    }
                }
            } else {
                return resellerPayDates;
            }
        }
        return resellerPayDates;
    }
    @TestVisible
    private static Boolean doWePay(Date today, Date royaltyProcessingDate, String payPeriod) {
        Boolean shouldPay = false;
        Integer todayMonth = today.month();
        Integer royaltyMonth = royaltyProcessingDate.month();
        if (payPeriod == 'Quarterly') {
            Set<Integer> payMonths = getQuarterlyPayMonthsFromStartMonth(royaltyMonth);
            if (payMonths.contains(todayMonth)) {
                shouldPay = true;
            }
        } else if (payPeriod == 'Annually') {
            if (royaltyMonth == 12 && todayMonth == 1) {
                shouldPay = true;
            } else if (todayMonth - royaltyMonth == 1) {
                shouldPay = true;
            }
        }
        return shouldPay;
    }
    private static Date getEndOfLastMonth(Date input) {
        return input.toStartOfMonth().addDays(-1);
    }
    @TestVisible
    private static Set<Integer> getQuarterlyPayMonthsFromStartMonth(Integer startMonth) {
        Set<Integer> payMonths = new Set<Integer>();
        Integer i = startMonth <= 12 ? startMonth : 1;
        do {
            payMonths.add(i);
            i = i + 3;
        } while (i <= 12);
        if (payMonths.size() != 4) {
            Integer firstMember = (Integer) payMonths.iterator().next();
            System.debug(firstMember);
            do {
                firstMember = firstMember - 3;
                if (!payMonths.contains(firstMember)) {
                    payMonths.add(firstMember);
                }
            } while (payMonths.size() != 4);
        }
        return payMonths;
    }
    private static Decimal getSumOfOpportunities(List<Opportunity> opportunities) {
        Decimal sumOfOpportunities = 0;
        for (Opportunity opportunity : opportunities) {
            sumOfOpportunities += opportunity.Amount;
        }
        return sumOfOpportunities;
    }
    private class ResellerPayDates {
        Boolean shouldPay;
        Date startDate;
        Date endDate;
    }

}