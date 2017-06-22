/*******************************************************************
  Name        :   StaticHelper
  Requester   :   CRS Requirments
  Author      :   AECOM - Luke Farbotko
  Version     :   1.0 
  Purpose     :   Used to prevent loopback triggers on 
  				  OpportunityNameCopyTrigger.trigger 
  Date        :   12 Feb, 2015 

********************************************************************/
public with sharing class StaticHelper{
	public static boolean runME = true;

	public static boolean excludeIt = true;
}