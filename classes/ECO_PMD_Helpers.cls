global with sharing class ECO_PMD_Helpers 
{
	public ECO_PMD_Helpers() {}

	global static List<pse__Project_Task__c> sortProjecTasks(List<pse__Project_Task__c>  evs)
    {
    	// GET THE LATEST TWO SNAPSHOTS FOR THE PROJECT
		List<pse__Project_Task__c> ordered_evs = new List<pse__Project_Task__c> ();
		for (pse__Project_Task__c ev : evs)
		{
			if(ev.pse__Hierarchy_Depth__c == 0 )
			{
				if(ordered_evs.size() == 0)
					ordered_evs.add( ev);
				else
					ordered_evs.add(0, ev);
			}
			else
			{
				integer i = 1;
				boolean found = false;
				for (pse__Project_Task__c oev : ordered_evs)
				{
					if ( ev.pse__Parent_Task__r.Id == oev.Id )//ev.pse__Order__c == 0 && 
					{
						found = true;
						break;
					}
					/*if ( ev.pse__Order__c != 0 && ev.pse__Parent_Task__r.Id == oev.pse__Parent_Task__r.Id && ev.pse__Order__c-1 == oev.pse__Order__c )
					{
					found = true;

					break;
					}*/
					i++;
				}
				if(found == true)
				{ 
					//ordered_evs.size();
					try
					{ 
						ordered_evs.add( i, ev);
					}
					catch(Exception ex)
					{ 
						ordered_evs.add(ev); // just add to the end
					}
				}
			}
		}
		return ordered_evs;
    }

    global static String getFiscal(Date d){
        String s = String.valueOf(d.month() + 1);
        Integer m = d.month() + 1;
        if(m < 10){
            s ='0' + string.valueof(m);
        }
        return 'FY' + String.valueOf(d.year()) + s;        
    }

    global static Decimal validDecimal(Decimal i) {
        Decimal result = i;
        if(i == null){
            result = 0;
        }        
        return result;
    }
}