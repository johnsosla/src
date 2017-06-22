public abstract class rsCriteria {

    public String UserId {get; set;}
    public String ProjectGroup {get; set;}
    public String ProjectName {get; set;}
    public String ClientName {get; set;}
    public String LocationCountry {get; set;}
    public String LocationCity {get; set;}
    public String SearchText {get; set;}
    public String Status {get; set;}
    public String RecordTypeId {get; set;}

    public final String USER_ID_PATH;
    public final String PROJECT_GROUP_PATH;
    public final String PROJECT_NAME_PATH;
    public final String CLIENT_NAME_PATH;
    public final String STATUS_PATH;
    public final String LOCATION_COUNTRY_PATH;
    public final String LOCATION_CITY_PATH;
    public final String NEXT_PART_PATH;
    private static final String RECORD_TYPE_PATH = 'RecordTypeId';

    public rsCriteria() {}

    public String getWhereClause() {

        List<String> args = new List<String>();
        addWhereForStatus(args, Status, STATUS_PATH);
        addWhereArg(args, UserId, USER_ID_PATH);
        addWhereArg(args, ProjectGroup, PROJECT_GROUP_PATH);
        addWhereArg(args, ProjectName, PROJECT_NAME_PATH);
        addWhereArg(args, ClientName, CLIENT_NAME_PATH);
        addWhereArg(args, LocationCountry, LOCATION_COUNTRY_PATH);
        addWhereArg(args, LocationCity, LOCATION_CITY_PATH);
        addWhereArg(args, RecordTypeId, RECORD_TYPE_PATH);
        String whereClause = String.join(args, ' AND ');

        return whereClause;
    }

    protected void addWhereArg(List<String> args, String value, String path) {
        if (String.isNotBlank(value) && String.isNotBlank(path)) {
            args.add(path + ' = ' + rsStringUtil.quote(value));
        }
    }

    private void addWhereForStatus(List<String> args, String value, String path) {
        if (String.isNotBlank(path) && String.isNotBlank(NEXT_PART_PATH)) {
            String whereClause = NEXT_PART_PATH + ' = null ';
            if (value == rsPRTeamEmployee.S_APPROVED) {
                args.add(whereClause + ' AND ' + path + ' = ' + rsStringUtil.quote(rsPRTeamEmployee.S_APPROVED));
            } else if (value == rsPRTeamEmployee.S_PENDING) {
                args.add(whereClause + ' AND (' + path + ' = ' + rsStringUtil.quote(rsPRTeamEmployee.S_PENDING) +
                         ' OR ' + path + ' = ' + rsStringUtil.quote(rsPRTeamEmployee.S_INREVIEW) + ')');
            } else if (value == rsPRTeamEmployee.S_ARCHIVED) {
                args.add(whereClause + ' AND ' + path + ' = ' + rsStringUtil.quote(rsPRTeamEmployee.S_ARCHIVED));
            } else if (value == rsPRTeamEmployee.S_ALL) {
                args.add(whereClause);
            } else if (String.isBlank(value)) {
                args.add(whereClause + ' AND ' + path + ' != ' + rsStringUtil.quote(rsPRTeamEmployee.S_ARCHIVED));
            }
        }
    }
}