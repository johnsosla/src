public with sharing class rsProjectViewModel implements Comparable {

    public static String SortField {get; set;}
    public static String SortOrder {get; set;}
    private rsPRTeamEmployee mProject;

    public rsProjectViewModel(rsPRTeamEmployee project) {
        this.mProject = project;
        if(SortOrder == null) SortOrder = 'asc';
    }

    public void setObj(rsPRTeamEmployee project){
        this.mProject = project;
    }

    public rsPRTeamEmployee getObj(){
        return this.mProject;
    }

    public Integer compareTo(Object compareTo) {
        rsProjectViewModel compareItem = (rsProjectViewModel)compareTo;
        if(String.isNotBlank(SortField) && String.isNotBlank(SortOrder)) {
            String val1 = mProject.getObj().get(SortField) != null ? String.valueOf(mProject.getObj().get(SortField)) : '';
            String val2 = compareItem.mProject.getObj().get(SortField) != null ? String.valueOf(compareItem.mProject.getObj().get(SortField)) : '';
            Integer flip = SortOrder == 'asc' ? 1 : -1;
            return val1.compareTo(val2) * flip;
        } else if(mProject.getGroupSequence() != null && compareItem.getObj().getGroupSequence() != null) {
            if(mProject.getGroupSequence() == compareItem.getObj().getGroupSequence()) {
                if(compareItem.getObj().getProjectSequence() != null && mProject.getProjectSequence() != null) {
                        return mProject.getProjectSequence() - compareItem.getObj().getProjectSequence();
                } else if(compareItem.getObj().getProjectSequence() == null) {
                    return -1;
                } else {
                    return 1;
                }
            } else {
                return mProject.getGroupSequence() - compareItem.getObj().getGroupSequence();
            }
        } else if(compareItem.getObj().getGroupSequence() == null) {
            return -1;
        } else {
            return 1;
        }
    }
}