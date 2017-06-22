public class rsViewModel implements Comparable{

    public static String SortField {get; set;}
    public static String SortOrder {get; set;}

    private rsProfilePart mProfilePart;

    public rsViewModel(rsProfilePart part) {
        this.mProfilePart = part;
        if(SortOrder == null) SortOrder = 'asc';
    }

    public void setProfilePart(rsProfilePart part){
        this.mProfilePart = part;
    }

    public rsProfilePart getProfilePart(){
        return this.mProfilePart;
    }

    public Boolean getDeleteRender() {
        Boolean rendered = true;
        if(rsStringUtil.isNullOrEmpty(mProfilePart.getAttachmentId()) || mProfilePart.getStatus() == rsProfilePart.S_INREVIEW) {
            rendered = false;
        }
        return rendered;
    }

    public Integer compareTo(Object compareTo){

        rsViewModel compareItem = (rsViewModel)compareTo;

        String val1 = mProfilePart.getObj().get(sortField) != null ? String.valueOf(mProfilePart.getObj().get(sortField)) : '';
        String val2 = compareItem.mProfilePart.getObj().get(sortField) != null ? String.valueOf(compareItem.mProfilePart.getObj().get(sortField))  : '';
        Integer flip = sortOrder == 'asc' ? 1 : -1;

        return val1.compareTo(val2) * flip;
    }
}