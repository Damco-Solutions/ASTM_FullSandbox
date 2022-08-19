/**
 * Created by wmccu on 11/20/2020.
 */

trigger OpportunityLineItemTrigger on OpportunityLineItem (before delete, after insert, after update) {
    new OpportunityLineItemTriggerHandler().run();
}