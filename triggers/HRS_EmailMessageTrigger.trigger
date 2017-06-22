trigger HRS_EmailMessageTrigger on EmailMessage (after insert, before insert, after update, before update ) {

    if ( trigger.isBefore){

        if ( trigger.isInsert){

            HRS_EmailMessageHandler.beforeInsertEmailMessages( trigger.new );
        }

        if ( trigger.isUpdate){


        }    

    }
    
    if ( trigger.isAfter ){

        if ( trigger.isInsert){
            //Case approval Using standard Email to Case function
            HRS_EmailMessageHandler.afterInsertEmailMessages( trigger.new );
        }

        if ( trigger.isUpdate){


        }         

    }
}