/*************************************************************************
*
* PURPOSE: Controller for direct report and peers component
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Alex Molina & Brian Lau
***************************************************************************/
public with sharing class rsDirectReportAndPeersController {

    public rsProfile profile {get; set;}
    private List<User> mDirectReportList;
    private List<User> mPeerList;

    private List<User> mPopupDirectList;
    private Integer mPopupDirectListOffset;

    private List<User> mPopupPeerList;
    private Integer mPopupPeerListOffset;

    private Boolean mHasMoreDirectReports;
    private Boolean mHasMorePeers;

    private static final Integer LISTLIMIT = 10;

    //This controls how many records show up on each page in the popup
    private static final Integer POPUPLIMIT = 25;

    public rsDirectReportAndPeersController() {
        mPopupDirectListOffset = 0;
        mPopupPeerListOffset = 0;
    }

    public Boolean getHasMoreDirectReports() {
        if(mHasMoreDirectReports == null) {
            mHasMoreDirectReports = rsProfile.find.directReportList(profile.getId(), POPUPLIMIT, POPUPLIMIT).size() > 0;
        }
        return mHasMoreDirectReports;
    }

    public Boolean getHasMorePeers() {
        if(mHasMorePeers == null) {
            mHasMorePeers = profile.getManagerId() != null ?
                            rsProfile.find.peerList(profile.getId(), profile.getManagerId(), POPUPLIMIT, POPUPLIMIT).size() > 0 :
                            false;
        }
        return mHasMorePeers;
    }

    public Integer getListLimit() {
        return LISTLIMIT;
    }

    public Integer getPopupLimit() {
        return POPUPLIMIT;
    }

    public Integer getPopupPeerListOffset() {
        return mPopupPeerListOffset;
    }

    public Integer getPopupDirectListOffset() {
        return mPopupDirectListOffset;
    }


    public List<User> getDirectReportList() {
        if(mDirectReportList == null) {
            mDirectReportList = new List<User>();
            mDirectReportList = rsProfile.find.directReportList(profile.getId(), LISTLIMIT, 0);
        }
        return mDirectReportList;
    }

    public List<User> getPeerList() {
        if(mPeerList == null) {
            mPeerList = new List<User>();
            if(profile.getManagerId() != null) {
                mPeerList = rsProfile.find.peerList(profile.getId(), profile.getManagerId(), LISTLIMIT, 0);
            }
        }

        return mPeerList;
    }

    // Resets the popup lists
    public PageReference resetLists() {
        mPopupDirectListOffset = 0;
        mPopupPeerListOffset = 0;
        mHasMoreDirectReports = true;
        mHasMorePeers = true;
        return null;
    }

/* Direct List popup methods */
    public List<User> getPopupDirectList() {
        mPopupDirectList = new List<User>();
        mPopupDirectList = rsProfile.find.directReportList(profile.getId(), POPUPLIMIT, mPopupDirectListOffset);
        return mPopupDirectList;
    }

    public PageReference directListNextPage() {
        mPopupDirectListOffset += POPUPLIMIT;
        mHasMoreDirectReports = rsProfile.find.directReportList(profile.getId(), POPUPLIMIT, mPopupDirectListOffset + POPUPLIMIT).size() > 0;
        return null;
    }

    public PageReference directListPreviousPage() {
        //We can't have a negative offset so don't decrement unless it's positive
        if( (mPopupDirectListOffset - POPUPLIMIT) > 0) {
            mPopupDirectListOffset -= POPUPLIMIT;
        } else {
            mPopupDirectListOffset = 0;
        }
        mHasMoreDirectReports = true;
        return null;
    }

/* Peer list popup methods */
    public List<User> getPopupPeerList() {
        mPopupPeerList = new List<User>();
        if(profile.getManagerId() != null) {
            mPopupPeerList = rsProfile.find.peerList(profile.getId(), profile.getManagerId(), POPUPLIMIT, mPopupPeerListOffset);
        }
        return mPopupPeerList;
    }

    public PageReference PeerListNextPage() {
        mPopupPeerListOffset += POPUPLIMIT;
        mHasMorePeers = rsProfile.find.peerList(profile.getId(), profile.getManagerId(), POPUPLIMIT, mPopupPeerListOffset + POPUPLIMIT).size() > 0;
        return null;
    }

    public PageReference PeerListPreviousPage() {
        //We can't have a negative offset so don't decrement unless it's positive
        if( (mPopupPeerListOffset - POPUPLIMIT) > 0) {
            mPopupPeerListOffset -= POPUPLIMIT;
        } else {
            mPopupPeerListOffset = 0;
        }
        mHasMorePeers = true;
        return null;
    }

}