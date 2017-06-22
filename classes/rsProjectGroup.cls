public class rsProjectGroup implements Comparable{
    public String projectGroup {get; set;}
    public Integer order {get; set;}
    public List<rsPRTeamEmployee> groupProjects {get; set;}
    public Boolean isReordered {get; set;}

    public rsProjectGroup(String projectGroup, List<rsPRTeamEmployee> groupProjects) {
        this.projectGroup = projectGroup;
        this.groupProjects = groupProjects;
        this.groupProjects.sort();
        isReordered = false;
        for(rsPRTeamEmployee emp : groupProjects) {
            if(emp.getGroupSequence() != null) {
                this.order = emp.getGroupSequence();
            }
            if(emp.getProjectSequence() == null) {
                isReordered = true;
            }
        }
    }

    public Integer compareTo(Object compareTo) {
        rsProjectGroup compareItem = (rsProjectGroup)compareTo;

        if(compareItem.order != null) {
            if(compareItem.order > order) {
                return -1;
            }
            else {
                return 1;
            }
        } else {
            return -1;
        }
    }
}