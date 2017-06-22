/*************************************************************************
*
* PURPOSE: Trigger to automatically update Contacts related to a User record
* whenever that record is changed.
*
* CREATED: 2014 Ethos Solutions - www.ethos.com
* AUTHOR: Kyle Johnson
***************************************************************************/
trigger sshUpdateUserContact on User (after update, after insert) {
    //Trigger will become inactive, relevant code will be in UTC_UnifiedTrigger
}