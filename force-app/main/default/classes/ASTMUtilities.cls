/**
 * Created by wmccu on 9/30/2020.
 */

public without sharing class ASTMUtilities {
    public static Map<String, List<SObject>> convertToListMap(List<SObject> sObjectList, String idKey) {
        Map<String, List<SObject>> keyToListValues = new Map<String, List<SObject>>();
        for (SObject sObj : sObjectList) {
            String key = (String) sObj.get(idKey);
            if (String.isBlank(key)) {
                continue;
            } else if (keyToListValues.containsKey(key)) {
                keyToListValues.get(key).add(sObj);
            } else {
                keyToListValues.put(key, new List<SObject>{
                        sObj
                });
            }
        }
        return keyToListValues;
    }
    public static Set<Id> getSetIdFromList(List<SObject> sObjects, String fieldName) {
        Set<Id> objectIds = new Set<Id>();
        for (SObject currentObject : sObjects) {
            Id currentId = (Id) currentObject.get(fieldName);
            if (currentId != null && !objectIds.contains(currentId)) {
                objectIds.add(currentId);
            }
        }
        return objectIds;
    }
}