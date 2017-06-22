public with sharing class rsSF254DisciplineController extends rsSectionController {
    public rsSF254DisciplineController() {
        super();
        mRecordType = rsProfilePart.RT_SF254;
    }

    public override PageReference savePart(){
        rsProfilePart tempPart = null;
        if( CurrentPart.getIsSF254Primary() ){
            for(rsProfilePart part : profile.getPartsByType(mRecordType)) {
                if(part.getIsSF254Primary()){
                    part.setIsSF254Primary(false);
                    tempPart = part;
                    break;
                }
            }
            if(tempPart != null) tempPart.save();
        }

        return super.savePart();
    }
}