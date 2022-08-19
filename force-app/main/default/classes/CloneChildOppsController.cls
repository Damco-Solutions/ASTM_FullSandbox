/**
 * Created by johnpernock from OpenGate Consulting on 2019-01-07.
 */

global without sharing class CloneChildOppsController {
    @InvocableMethod(label='CreateCloneNewYearChildren' description='')
    global static List<String> CloneChildCreate (List<CloneChildCreateRequest> requests) {
        List<String> results = new List<String>();
        try{
            for (CloneChildCreateRequest request : requests){
                String resultStr = createNewOpp(request.acctId);
                results.add(resultStr);
            }
        }catch (Exception e) {
            results.add('Error');
        }
        return results;

    }

    global class CloneChildCreateRequest {
        @InvocableVariable(required=true)
        public string acctId;
    }

    public static String createNewOpp(Id acctId){
        CloneChildOppsBatch cloneOpps = new CloneChildOppsBatch(acctId);
        Database.executeBatch(cloneOpps, 10);
        return 'Batches Created';
    }
}