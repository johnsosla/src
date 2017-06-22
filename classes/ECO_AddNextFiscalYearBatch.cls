global class ECO_AddNextFiscalYearBatch extends ECO_BatchAdminService {

  public class DataFileException extends Exception{}

    public static final Integer DEFAULT_BATCH_SIZE = 200;
  //global Integer batchSize {get; set;}
  
  /**
   *  
   *
   * @Author  NTT Data - Scott Mantei
   * @Date    September 30, 2016
   *
   * @param   
   * @return  
   **/
  
  // Prior to running this batch file, there needs to be a corresponding 
  // Static Resource that contains the CSV file with records for the next 
  // year's fiscal dates.
  //
  // The data for this batch job must be in CSV format in the static resource
  // called 'NextFiscalYear'
  //
  // A requirement for this job is that it needs to run in the Batch Scheduling Dashboard.
  // As such, it is written as a batch job, even though there is no processing on a large
  // amount of records.  Due to this, the execute methods and the finish methods are empty.
   
  global ECO_AddNextFiscalYearBatch() {
  }


  private static String[] processCSVFile(String name)
  {
      try {
       StaticResource sr = [Select  s.Name, s.Id, s.Body From StaticResource s  where name = :name];
       blob tempBlob = sr.Body;
       String tempString = tempBlob.toString();
       tempString = tempSTring.replace('"', '');
       String[] stringArray = tempString.split('\r');
       
       if (!(stringArray.size() > 1)) throw new DataFileException('Error processing data file.');
       
       return stringArray;
      } catch (Exception e) {
        throw e;      
      }      
      return null;
  }  

  
  global Database.QueryLocator start( Database.BatchableContext BC) {
    this.logId = ECO_Service_BatchLog.logJobStart('ECO_AddNextFiscalYearBatch', this.batchStream, this.regionOuIds, BC.getJobId(), this.jobName);
      // Process the CSV file found at the Static Resource called 'NextFiscalYear'
      
      List<String> fyData = processCSVFile('ECO_NextFiscalYear');

      List<pse__Time_Period__c> pts = new List<pse__Time_Period__c>();

      for (Integer i=1; i<fyData.size(); i++) {
      
          pse__Time_Period__c pt = new pse__Time_Period__c();
          String[] tokens = fyData[i].split(',');
          
          pt.Name               = tokens[0];
          pt.pse__Start_Date__c = date.parse(tokens[1]);
          pt.pse__End_Date__c   = date.parse(tokens[2]);
          pt.pse__Type__c       = tokens[3];
          pt.PAMO__c            = tokens[4];
          pt.PAYR__c            = tokens[5];
          pt.TimePeriodCode__c  = tokens[6];
          pt.TimePeriodExternalID__c = tokens[6];          
          
          pts.add(pt);
      }

      upsert pts TimePeriodExternalID__c;

      String query = 'Select Id ' +
                        ', PeriodStartDate__c ' +
                        ', FiscalMonth__c  ' +
                        'From WeeklyRollupEntry__c  ' +
                        'Where FiscalMonth__c = null';
      
      return Database.getQueryLocator(query);

  }


  global void execute( Database.BatchableContext BC, List<WeeklyRollupEntry__c> weeklyrollupentries) {

    list<date> enddatelist = new list<date>();
    Set<Date> datesToConvert = new Set<Date>();
    Map<Date, String> mapTimePeriodCodeByDate = new Map<Date, String> ();

    for (WeeklyRollupEntry__c ba : weeklyrollupentries) {
        datesToConvert.add(ba.PeriodStartDate__c);
        if (ba.PeriodStartDate__c != null) {
            enddatelist.add((ba.PeriodStartDate__c).addmonths(2));
            enddatelist.add((ba.PeriodStartDate__c).addmonths(1));
            enddatelist.add((ba.PeriodStartDate__c).addmonths(0));
            enddatelist.add((ba.PeriodStartDate__c).addmonths(-1));
            enddatelist.add((ba.PeriodStartDate__c).addmonths(-2));
            enddatelist.add((ba.PeriodStartDate__c).addmonths(-3));
        }
    }
    
    datesToConvert.remove(null);

    List<pse__Time_Period__c> timePeriods  = new  List<pse__Time_Period__c>();
    if (enddatelist.size() > 0) {
        // Time period
        timePeriods = ECO_Utils_Date.calcTimePeriods(enddatelist, 'Month');
        pse__Time_Period__c fm = null;

        for (Date dt : datesToConvert) {
            fm = ECO_Utils_Date.getFiscalPeriod(dt, 0, timePeriods);
            if (fm != null) {
                mapTimePeriodCodeByDate.put(dt, fm.TimePeriodCode__c);
            }
        }

        for (WeeklyRollupEntry__c ba : weeklyrollupentries) {
            if (ba.PeriodStartDate__c != null) {
                ba.FiscalMonth__c = mapTimePeriodCodeByDate.get(ba.PeriodStartDate__c);
            }
        }
    }

    update weeklyrollupentries;



  }
  

     /**
     * Executes the batch by ensuring that the batch size is set or using the best default, also passes all the class properties forward to the executeBatch
     *
     * @Author  NTT Data - ?
     * @Date    2015
     *
     * @param   SC
     * @return  
     **/
 global void execute( SchedulableContext SC){
  
      if(batchSize == null){
        batchSize = DEFAULT_BATCH_SIZE;
      }

      ECO_AddNextFiscalYearBatch batch = new ECO_AddNextFiscalYearBatch();
      batch.batchSize = this.batchSize;
      batch.batchStream = this.batchStream;
      batch.regionOuIds = this.regionOuIds;
      batch.jobName = this.jobName;
      Database.executeBatch(batch, batchSize);            
  }
  

    /**
     * log the finish of this job and call the next batch in the stream if this job is a stream member
     *
     * @Author  NTT Data - Deborah Orth
     * @Date    November 2016
     *
     * @param   BC - Batchable Context
     * @return  
     **/
    global void finish(Database.BatchableContext BC) {
        runNextBatchInStream( BC.getJobId(), 'ECO_AddNextFiscalYearBatch'); 
    }    

}