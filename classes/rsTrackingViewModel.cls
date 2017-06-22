public with sharing class rsTrackingViewModel implements Comparable {

    public static String SortField {get; set;}
    public static String SortOrder {get; set;}

    private rsUpdateTracking mTracking;

    public rsTrackingViewModel(rsUpdateTracking track) {
        mTracking = track;
        if(SortOrder == null) {
            SortOrder = 'asc';
        }
    }

    public rsUpdateTracking getObj() {
        return mTracking;
    }

    public Integer compareTo(Object compareTo) {
        rsTrackingViewModel compareItem = (rsTrackingViewModel)compareTo;

        String val1 = mTracking.getObj().get(SortField) != null ? String.valueOf(mTracking.getObj().get(SortField)) : '';
        String val2 = compareItem.getObj().getObj().get(SortField) != null ? String.valueOf(compareItem.getObj().getObj().get(SortField)) : '';
        Integer flip = SortOrder == 'asc' ? 1 : -1;

        return val1.compareTo(val2) * flip;
    }
}