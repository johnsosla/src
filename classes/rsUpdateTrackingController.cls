/*************************************************************************
*
* PURPOSE: Controller update tracking component
*
* CREATED: 2015 Ethos Solutions - www.ethos.com
* AUTHOR: Brian Lau
***************************************************************************/
public with sharing class rsUpdateTrackingController extends rsSectionController {

    public rsUpdateTracking CurrentTrackUpdate {get; set;}
    private List<rsTrackingViewModel> mViewModels {get; set;}

    public rsUpdateTrackingController() {
        super();
        CurrentTrackUpdate = new rsUpdateTracking();
    }

    public override PageReference newPart() {
        CurrentTrackUpdate = new rsUpdateTracking(profile.getId());
        enableEditMode();
        return null;
    }

    public override PageReference editPart() {
        for(rsUpdateTracking track : profile.getProfileUpdateTrackings()) {
            if(track.getId() == ApexPages.currentPage().getParameters().get('trackId')) {
                enableEditMode();
                CurrentTrackUpdate = new rsUpdateTracking((rs_Update_Tracking__c)track.getObj().clone(true,true));
                break;
            }
        }
        return null;
    }

    public override PageReference savePart() {
        Boolean mIsExistingPart = String.isNotBlank(CurrentTrackUpdate.getId());
        CurrentTrackUpdate.save();
        CurrentTrackUpdate = rsUpdateTracking.find.byTrackId(CurrentTrackUpdate.getId()); // Gets the Created Date
        if(!mIsExistingPart) {
            profile.getProfileUpdateTrackings().add(CurrentTrackUpdate);
        } else {
            Integer i = 0;
            for(rsUpdateTracking track : profile.getProfileUpdateTrackings()) {
                if(track.getId() == CurrentTrackUpdate.getId()) {
                    break;
                }
                i++;
            }
            profile.getProfileUpdateTrackings().set(i, CurrentTrackUpdate);
        }

        enableListMode();
        return null;
    }

    public override PageReference cancelPart() {
        CurrentTrackUpdate = null;
        enableListMode();
        return null;
    }

    public override PageReference deletePart() {
        List<rsUpdateTracking> trackings = profile.getProfileUpdateTrackings();
        Integer index = null;
        for(Integer i = 0; i < trackings.size(); i++) {
            if(trackings[i].getId() == ApexPages.currentPage().getParameters().get('trackId')) {
                index = i;
                break;
            }
        }
        rsUpdateTracking tracking = trackings.remove(index);
        tracking.destroy();
        if(getTrackingViewParts().size() == 0) {
            getPreviousPage();
        }
        return null;
    }

    public List<rsTrackingViewModel> getTrackingViewParts() {
        String sortField = ApexPages.currentPage().getParameters().get('sortField');
        String pageChange = ApexPages.currentPage().getParameters().get('pageChange');

        if(sortField == null && pageChange == null) {
            mViewModels = new List<rsTrackingViewModel>();

            for(rsUpdateTracking track : profile.getProfileUpdateTrackings()) {
                mViewModels.add(new rsTrackingViewModel(track));
            }
        }

        if(TotalParts != null && TotalParts < mViewModels.size()) {
            if (TotalParts > 0 && getViewLimit() > 0 && getViewLimit() < getResultLimit() * PageNum) {
                if ( (Math.mod(TotalParts, getViewLimit()) < getResultLimit() && Math.mod(TotalParts, getViewLimit()) > 0) || (PageNum == getNumberOfPages() && Math.mod(TotalParts, getResultLimit()) > 0) ) {
                    setViewLimit(getViewLimit() + 1);
                }
            }
        }

        TotalParts = mViewModels.size();
        if(TotalParts < getViewLimit() || (TotalParts > 0 && getViewLimit() == 0)) {
            setViewLimit(TotalParts);
        }

        List<rsTrackingViewModel> viewParts = new List<rsTrackingViewModel>();

        if(mViewModels != null && !mViewModels.isEmpty()) {
            for(Integer i = ViewIndex; i < getViewLimit(); i++) {
                viewParts.add(mViewModels[i]);
            }
        }

        return viewParts;
    }

    public override PageReference sortParts() {
        String sortField = ApexPages.currentPage().getParameters().get('sortField');
        if (sortField != null) {

            if (getSortOrder() == null || sortField != getLastSortedBy()) {
                setSortOrder('asc');
                rsTrackingViewModel.SortOrder = 'asc';
            }

            rsTrackingViewModel.SortField = sortField;
            if (getLastSortedBy() != null) {
                if (sortField == getLastSortedBy()) {
                    if (getSortOrder() == 'asc') {
                        setSortOrder('desc');
                        rsTrackingViewModel.SortOrder = 'desc';
                    } else {
                        setSortOrder('asc');
                        rsTrackingViewModel.SortOrder = 'asc';
                    }
                }
            }
            mViewModels.sort();
            setLastSortedBy(sortField);
        }
        return null;
    }
}