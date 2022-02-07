/**
 * @File Name          : TriggerDispatcher.cls
 * @Description        : This class checks for Recurrsive and handler router only if trigger and Trigger context are on
 * @Author             : Dinesh Ramanadham
 * @Group              : 
 * @Last Modified By   : Dinesh Ramanadham
 * @Last Modified On   : 4152020, 1:28:30 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    8/28/2019, 4:39:06 PM   Dinesh Ramanadham      Initial Version
**/
public class TriggerDispatcher {
    private static Map<String, Integer> beforeInsertCounterMap = new Map<String, Integer>();
    private static Map<String, Integer> afterInsertCounterMap = new Map<String, Integer>();
    private static Map<String, Integer> beforeUpdateCounterMap = new Map<String, Integer>();
    private static Map<String, Integer> afterUpdateCounterMap = new Map<String, Integer>();
    private static Map<String, Integer> beforeDeleteCounterMap = new Map<String, Integer>();
    private static Map<String, Integer> afterDeleteCounterMap = new Map<String, Integer>();
    private static Map<String, Integer> undeleteCounterMap = new Map<String, Integer>();
    @TestVisible private static Map<String, Trigger_Settings__mdt> customMetadataTypeMap = new Map<String, Trigger_Settings__mdt>();
    
    /*
     *  This method will fire the appropriate methods on the handler depending on the Trigger context.
     */
    public static void Run(ITriggerHandler handler){
        
        String objectName = getObjectName();
        if(!customMetadataTypeMap.containsKey(objectName)){
            if (getCustomMetadataType(objectName)!=null){
                customMetadataTypeMap.put(objectName, getCustomMetadataType(objectName));
            }
        }
        if(!beforeInsertCounterMap.containsKey(objectName)){
            beforeInsertCounterMap.put(objectName, 1);
        }
        if(!afterInsertCounterMap.containsKey(objectName)){
            afterInsertCounterMap.put(objectName, 1);
        }
        if(!beforeUpdateCounterMap.containsKey(objectName)){
            beforeUpdateCounterMap.put(objectName, 1);
        }
        if(!afterUpdateCounterMap.containsKey(objectName)){
            afterUpdateCounterMap.put(objectName, 1);
        }
        if(!beforeDeleteCounterMap.containsKey(objectName)){
            beforeDeleteCounterMap.put(objectName, 1);
        }
        if(!afterDeleteCounterMap.containsKey(objectName)){
            afterDeleteCounterMap.put(objectName, 1);
        }
        if(!undeleteCounterMap.containsKey(objectName)){
            undeleteCounterMap.put(objectName, 1);
        }

        if(customMetadataTypeMap.get(objectName) != null){
            if(!customMetadataTypeMap.get(objectName).IsDisabled__c){
                if(Trigger.IsBefore && Trigger.IsInsert && beforeInsertCounterMap.get(objectName) <= customMetadataTypeMap.get(objectName).Recursive_Control__c){
                    Integer tmp = beforeInsertCounterMap.get(objectName) + 1;
                    beforeInsertCounterMap.put(objectName, tmp);
                    beforeTriggers(handler, customMetadataTypeMap.get(objectName));
                }
                if(Trigger.IsAfter && Trigger.IsInsert && afterInsertCounterMap.get(objectName) <= customMetadataTypeMap.get(objectName).Recursive_Control__c){
                    Integer tmp = afterInsertCounterMap.get(objectName) + 1;
                    afterInsertCounterMap.put(objectName, tmp);
                    afterTriggers(handler, customMetadataTypeMap.get(objectName));
                }                
                if(Trigger.IsBefore  && Trigger.IsUpdate && beforeUpdateCounterMap.get(objectName) <= customMetadataTypeMap.get(objectName).Recursive_Control__c){
                    
                    Integer tmp = beforeUpdateCounterMap.get(objectName) + 1;
                    beforeUpdateCounterMap.put(objectName, tmp);
                    beforeTriggers(handler, customMetadataTypeMap.get(objectName));
                }
                if(Trigger.IsAfter && Trigger.IsUpdate && afterUpdateCounterMap.get(objectName) <= customMetadataTypeMap.get(objectName).Recursive_Control__c){
                    Integer tmp = afterUpdateCounterMap.get(objectName) + 1;
                    afterUpdateCounterMap.put(objectName, tmp);
                    afterTriggers(handler, customMetadataTypeMap.get(objectName));
                }
                if(Trigger.IsBefore  && Trigger.IsDelete && beforeDeleteCounterMap.get(objectName) <= customMetadataTypeMap.get(objectName).Recursive_Control__c){
                    Integer tmp = beforeDeleteCounterMap.get(objectName) + 1;
                    beforeDeleteCounterMap.put(objectName, tmp);
                    beforeTriggers(handler, customMetadataTypeMap.get(objectName));
                }
                if(Trigger.IsAfter && Trigger.IsDelete && afterDeleteCounterMap.get(objectName) <= customMetadataTypeMap.get(objectName).Recursive_Control__c){
                    Integer tmp = afterDeleteCounterMap.get(objectName) + 1;
                    afterDeleteCounterMap.put(objectName, tmp);
                    afterTriggers(handler, customMetadataTypeMap.get(objectName));
                }
                if(Trigger.isUndelete && undeleteCounterMap.get(objectName) <= customMetadataTypeMap.get(objectName).Recursive_Control__c){
                    Integer tmp = undeleteCounterMap.get(objectName) + 1;
                    undeleteCounterMap.put(objectName, tmp);
                    afterTriggers(handler, customMetadataTypeMap.get(objectName));
                }
            }
        }
        
    }
    
    /*
     * Detect the beforeTriggers context and fire the relevant methods on the Trigger handler:
     */
    
    private static void beforeTriggers(ITriggerHandler handler, Trigger_Settings__mdt triggerSettings){
        if (Trigger.IsInsert && triggerSettings.BeforeInsert__c){
            handler.BeforeInsert();
        }
        if (Trigger.IsUpdate && triggerSettings.BeforeUpdate__c){
            handler.BeforeUpdate();
        }
        if (Trigger.IsDelete && triggerSettings.BeforeDelete__c){
            handler.BeforeDelete();
        }
    }
    
    /*
     * Detect the afterTriggers context and fire the relevant methods on the Trigger handler:
     */
    
    private static void afterTriggers(ITriggerHandler handler, Trigger_Settings__mdt triggerSettings){
        if (Trigger.IsInsert && triggerSettings.AfterInsert__c){
            handler.AfterInsert();
        }
        if (Trigger.IsUpdate && triggerSettings.AfterUpdate__c){
            handler.AfterUpdate();
        }
        if (Trigger.IsDelete && triggerSettings.AfterDelete__c){
            handler.AfterDelete();
        }
        if (Trigger.isUndelete && triggerSettings.AfterUndelete__c){
            handler.AfterUndelete();
        }
    }
    
    /*
     * Detect the object
     * Description: Using a getDescribe to get the name of the object.
     *              Using the try and catch block to capture the name ob the object when 
     *              the Trigger is old (deleted)
     */
    
    private static String getObjectName(){
        String objectName = null;
        try{
            objectName = Trigger.new[0].getSObjectType().getDescribe().getName();
        }catch(NullPointerException npe){
            objectName = Trigger.old[0].getSObjectType().getDescribe().getName();
        }
        return objectName;
    }
    
    /*
     * @Gather the custom setting values to handle object events
     */
    
    private static Trigger_Settings__mdt getCustomMetadataType(String objectName){
        Trigger_Settings__mdt objTrigSetting = new Trigger_Settings__mdt();
        List<Trigger_Settings__mdt> lstTrigSetting = [Select AfterDelete__c,AfterInsert__c,AfterUndelete__c,AfterUpdate__c,BeforeDelete__c,BeforeInsert__c,BeforeUpdate__c,IsDisabled__c,Object_API_Name__c,Recursive_Control__c from Trigger_Settings__mdt where Object_API_Name__c =:objectName limit 1];
        if(lstTrigSetting.size()>0) objTrigSetting = lstTrigSetting[0];
        return objTrigSetting;
    }
}