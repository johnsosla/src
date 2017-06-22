public with sharing class rsSF330DisciplineController extends rsSectionController {
    public rsSF330DisciplineController() {
        super();
        mRecordType = rsProfilePart.RT_SF330;
    }

    public override PageReference savePart(){
        rsProfilePart tempPart = null;
        if( CurrentPart.getIsSF330Primary() ){
            for(rsProfilePart part : profile.getPartsByType(mRecordType)) {
                if(part.getIsSF330Primary()){
                    part.setIsSF330Primary(false);
                    tempPart = part;
                    break;
                }
            }
            if(tempPart != null) tempPart.save();
        }

        return super.savePart();
    }
}