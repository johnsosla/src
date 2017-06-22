/** ------------------------------------------------------------------------------------------------------
* @Description To return field name for translations based on user's language
*
* @Author      NTT Data - Priya Parepalli
* @Date        11/11/2016
*-----------------------------------------------------------------------------------------------------*/
public class ECO_Service_MasterDataTranslation {
    /**
    * To get translated field Name based on user language
    *
    * @Author  NTT Data - Priya Parepalli
    * @Date    11/11/2016
    *
    * @param   sObjectName, sObjectName
    * @return  String
    **/
    public static String translatedField(String sObjectName, String sFieldName){
        String sLanguage = UserInfo.getLanguage();
        String sCSFieldName;
        String sObjNameModified;
        sLanguage = sLanguage.left(2);
        if(sLanguage == 'en'){
            sLanguage = '';
        }
        //If using custom setting
        if(sObjectName.endsWith('__c')){
        	sObjNameModified = sObjectName.left(sObjectName.indexOf('__c'));
        }else{
        	sObjNameModified = sObjectName;
        }

        String csfieldName = sObjNameModified + '_' + sLanguage + sFieldName;
        ECOMDTranslation__c cSetting = ECOMDTranslation__c.getValues(csfieldName);
        if(cSetting != null){
            sCSFieldName = cSetting.FieldName__c;
        }else{
            sCSFieldName = sFieldName;
        }
        //End

        return sCSFieldName;

    }
}