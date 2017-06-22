public class rsUserViewModel implements Comparable{

    public static String SortField {get; set;}
    public static String SortOrder {get; set;}
    private User currUser;

    public rsUserViewModel(User user) {
        this.currUser = user;
        if(SortOrder == null) SortOrder = 'asc';
    }

    public void setObj(User user){
        this.currUser = user;
    }

    public User getObj(){
        return this.currUser;
    }

    public Integer compareTo(Object compareTo) {
        rsUserViewModel compareItem = (rsUserViewModel)compareTo;

        String val1 = currUser.get(sortField) != null ? String.valueOf(currUser.get(sortField)) : '';
        String val2 = compareItem.currUser.get(sortField) != null ? String.valueOf(compareItem.currUser.get(sortField))  : '';
        Integer flip = sortOrder == 'asc' ? 1 : -1;

        return val1.compareTo(val2) * flip;
    }
}