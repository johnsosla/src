trigger ContractReview_ContentDocumentLinkTrigger on ContentDocumentLink (after insert) {
   ContractReviewHelper.SendNotification(Trigger.newMap);
}