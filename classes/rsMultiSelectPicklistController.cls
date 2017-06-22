/*************************************************************************
*
* PURPOSE: Custom Multi Select Controller Controller
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Brian Lau
***************************************************************************/

public with sharing class rsMultiSelectPicklistController {
    public List<SelectOption> allOptions {get; set;}
    public List<SelectOption> selectedOptions {get; set;}
    private String selectedOptionsValues;

    public rsMultiSelectPicklistController() {}

    public String getSelectedOptionsValues() {
        return selectedOptionsValues;
    }

    public void setSelectedOptionsValues(String strs) {
        selectedOptionsValues = strs;
        selectedOptions.clear();
        for(String str : selectedOptionsValues.split(';')) {
            selectedOptions.add(new SelectOption(str,str));
        }
    }
}