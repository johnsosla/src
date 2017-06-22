public with sharing class GFA_TemplateTreeViewController extends GFA_TemplateTreeBaseController {

    public GFA_TemplateTreeViewController(ApexPages.StandardController sc) {
        super(sc);
    }

    public Boolean getCanEditTemplate() {
        return CurrentUser.getIsAdminUser() && template.getStatus() != GFA_Template.STATUS_PUBLISHED;
    }

    public PageReference editTemplate() {
        PageReference pr = Page.GFA_TemplateTreeEdit;
        pr.setRedirect(true);
        putParam(pr, 'id', template.getId());
        return pr;
    }

    public Boolean getCanPublishTemplate() {
        if ((template.getStatus() == GFA_Template.STATUS_PENDING
                || template.getStatus() == GFA_Template.STATUS_WITHDRAWN)
                && CurrentUser.getIsAdminUser()) {
            return true;
        } else {
            return false;
        }
    }

    public PageReference publishTemplate() {
        template.setStatusPublished();
        template.save();
        return null;
    }

    public Boolean getCanWithdrawTemplate() {
        //---TODO add additional checks based on Edit button permissions
        if (template.getStatus() == GFA_Template.STATUS_PUBLISHED
                && CurrentUser.getIsAdminUser()) {
            return true;
        } else {
            return false;
        }
    }

    public PageReference withdrawTemplate() {
        template.setStatusWithdrawn();
        template.save();
        return null;
    }
}