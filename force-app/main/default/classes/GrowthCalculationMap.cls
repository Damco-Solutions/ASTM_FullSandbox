/**
 * Created by wmccu on 9/26/2020.
 */

public with sharing class GrowthCalculationMap {
    private static GrowthCalculationMap instance = null;
    public Map<String, String> growthCalculationMapStringsByStrings { get; private set; }

    private GrowthCalculationMap() {
        growthCalculationMapStringsByStrings = new Map<String, String>{
                'Non Managed AccountNew Business' => 'Amount',
                'Non Managed AccountRenewal' => 'Zero',
                'Non Managed AccountRenewal with Upgrade' => 'Calculate',
                'Non Managed AccountExpansion on Existing Account' => 'Amount',
                'Managed AccountNew Business' => 'Amount',
                'Managed AccountRenewal' => 'Calculate',
                'Managed AccountRenewal with Upgrade' => 'Calculate',
                'Managed AccountExpansion on Existing Account' => 'Amount'
        };
    }
    public static GrowthCalculationMap getInstance() {
        if (instance == null) {
            instance = new GrowthCalculationMap();
        }
        return instance;
    }
}