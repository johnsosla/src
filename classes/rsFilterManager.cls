public class rsFilterManager {

    private rsCriteria mCriteria;

    public enum FilterType {
        ProjectGroups,
        ProjectNames,
        ClientNames,
        LocationCountries,
        LocationCities,
        Statuses,
        RecordTypes
    }

    public List<SelectOption> ProjectGroups {get; set;}
    public String ProjectGroup {get; set;}

    public List<SelectOption> ProjectNames {get; set;}
    public String ProjectName {get; set;}

    public List<SelectOption> ClientNames {get; set;}
    public String ClientName {get; set;}

    public List<SelectOption> LocationCountries {get; set;}
    public String LocationCountry {get; set;}

    public List<SelectOption> LocationCities {get; set;}
    public String LocationCity {get; set;}

    public List<SelectOption> Statuses {get; set;}
    public String Status {get; set;}

    public List<SelectOption> RecordTypes {get; set;}
    public String RecordTypeId {get; set;}

    public String SearchText {get; set;}
    public String UserId {get; set;}

    public rsFilterManager() {}

    public void setupFilter(FilterType type) {
        if(type == FilterType.ProjectGroups) {
            ProjectGroups = rsPRTeamEmployee.find.getProjectGroupsByUserId(UserId);
        } else if(type == FilterType.ProjectNames) {
            ProjectNames = rsPRTeamEmployee.find.getProjectNamesByUserId(UserId);
        } else if(type == FilterType.ClientNames) {
            ClientNames = rsPRTeamEmployee.find.getClientNamesByUserId(UserId);
        } else if(type == FilterType.Statuses) {
            Statuses = rsPRTeamEmployee.find.getStatusOptions();
        } else if(type == FilterType.LocationCountries) {
            LocationCountries = rsPRTeamEmployee.find.getLocationCountriesByUserId(UserId);
        } else if(type == FilterType.LocationCities) {
            LocationCities = rsPRTeamEmployee.find.getLocationCitiesByUserId(UserId);
        } else if(type == FilterType.RecordTypes) {
            RecordTypes = rsPRTeamEmployee.find.getRecordTypes();
        }
    }

    public void setupProjectSearchFilters() {
        setupFilter(FilterType.ProjectGroups);
        setupFilter(FilterType.ProjectNames);
        setupFilter(FilterType.ClientNames);
        setupFilter(FilterType.LocationCountries);
        setupFilter(FilterType.LocationCities);
        setupFilter(FilterType.Statuses);
        setupFilter(FilterType.RecordTypes);
    }

    public List<rsPRTeamEmployee> getProjectSearchResults() {
        mCriteria = new rsPRTeamEmployeeCriteria();
        mCriteria.ProjectGroup = ProjectGroup;
        mCriteria.ProjectName = ProjectName;
        mCriteria.ClientName = ClientName;
        mCriteria.LocationCountry = LocationCountry;
        mCriteria.LocationCity = LocationCity;
        mCriteria.SearchText = SearchText;
        mCriteria.Status = Status;
        mCriteria.RecordTypeId = RecordTypeId;
        mCriteria.UserId = UserId;

        return rsPRTeamEmployee.find.byCriteria((rsPRTeamEmployeeCriteria)mCriteria);
    }

}