public without sharing class ECO_TriggerSettings {

	private static Map<String, ECO_TriggerSettings__c> triggerSettingsMap; // Eventually could get rid of to save some heap size
	private static System.LoggingLevel debugLevel = LoggingLevel.DEBUG;
	private static Map<String, Boolean> triggerSettingsOverrideMap = new Map<String, Boolean>();

	private static Set<String> bypassedMethods;
	private static Set<String> executedMethods;
	private static Set<String> bypassedSettingMethods;
	private static Set<String> bypassedObjects;
	private static Set<String> overrideMethods;
	private static Set<Id> objectsProcessed;

	static {
		triggerSettingsMap = ECO_TriggerSettings__c.getAll();
		bypassedSettingMethods = new Set<String>();
		bypassedObjects = new Set<String>();
		bypassedMethods = new Set<String>();
		executedMethods = new Set<String>();
		overrideMethods = new Set<String>();
		
		// Cache all bypassed methods
		for (ECO_TriggerSettings__c setting : triggerSettingsMap.values()) {
			if (!setting.IsEnabled__c) {
				bypassedSettingMethods.add(setting.Name);
			}
		}
	}

	public static void bypassTrigger(String objectPrefix) {
		bypassedObjects.add(objectPrefix);
	}

	public static void bypass(String methodName) {
		bypassedMethods.add(methodName);
	}

	// Use to override object level trigger bypass
	public static void bypassOverride(String methodName) {
		// Check to see if it was bypassed by a trigger or previous bypass call since we only want to override the globals
		if (bypassedMethods.contains(methodName)) return;

		// Otherwise we can add it to the overrides
		overrideMethods.add(methodName);
	}

	public static void clearOverride(String methodName) {
		overrideMethods.remove(methodName);
	}

	public static void clearBypass(String methodName) {
		bypassedMethods.remove(methodName);
	}

	public static void clearBypassTrigger(String objectPrefix) {
		bypassedObjects.remove(objectPrefix);
	}

	public static Boolean isBypassed(String methodName) {

		if(bypassedSettingMethods.contains(methodName) || bypassedMethods.contains(methodName)) return true;

		if(overrideMethods.contains(methodName)) return false;		

		/*
		if (!executedMethods.contains(methodName)) {
			executedMethods.add(methodName);
		} else {
			return true;
		}
		*/
		return bypassedObjects.contains(methodName.left(2));
	}

	public static void clearAllBypasses() {
		// We still want to retain custom settings bypass
		bypassedMethods.clear();
		overrideMethods.clear();
		bypassedObjects.clear();
	}


	public static void overrideTriggerSetting(String triggerName, Boolean isEnabled) {
		triggerSettingsOverrideMap.put(triggerName, isEnabled);
	}


	public static Boolean getIsTriggerEnabled (String triggerName) {
		ECO_TriggerSettings__c thisTriggerSetting = triggerSettingsMap.get(triggerName);
		Boolean isEnabledOverride = triggerSettingsOverrideMap.get(triggerName);
		Boolean returnFlag = true;

		if (null == isEnabledOverride) {
			if (null == thisTriggerSetting) {
				system.debug(debugLevel, 'No setting found for trigger:  ' + triggerName);
				returnFlag = true;
			} else {
				returnFlag = thisTriggerSetting.IsEnabled__c;
			}
		} else {
			returnFlag = isEnabledOverride;
		}

		return returnFlag;
	}

	public static final string BT_bottomFlag = 'BT_bottomFlag';

}