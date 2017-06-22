public class CollectionManagerController
{
    public static integer StaticrowNumber = 0;
    public class myCollection
    {
        public myCollection(Practice_Area_Collection__c r, integer rn)
        {
            rec = r;
            rowNumber = rn;
            isDelete = false;
        }
        public Practice_Area_Collection__c rec{get;set;}
        public boolean isDelete{get;set;}
        public integer rownumber{get;set;}
    }
    public string Typ{get;set;}
    public boolean showResult{get;set;}
    public Practice_Area_Collection__c filterRec{get;set;}
    private List<myCollection> collectionList;
    public List<myCollection> NewcollectionList{get;set;}
    public List<myCollection> getUpdateList()
    {
        return collectionList;
    }
    public CollectionManagerController()
    {
         Typ = ApexPages.currentPage().getParameters().get('typ');
         if(Typ=='' || Typ == null)
             Typ='ALL';
         showResult = false;
         filterRec= new Practice_Area_Collection__c();
         IsOverLimit = false;
         
    }
    public boolean IsOverLimit{get;set;}
    public void Filter()
    {
        string soql = 'SELECT Business_Line__c, Geography__c, Practice_Area__c, Sub_Practice_Area__c From Practice_Area_Collection__c where id!=null';
        collectionList = new List<myCollection>();
        NewcollectionList = new List<myCollection>();
        string Condition ='';
        if(filterRec.Business_Line__c != null)
            soql = soql + ' AND Business_Line__c = \'' + filterRec.Business_Line__c +'\'';
        if(filterRec.Geography__c != null)
            soql = soql + ' AND Geography__c = \'' + filterRec.Geography__c +'\'';
        if(filterRec.Practice_Area__c != null)
            soql = soql + ' AND Practice_Area__c  = \'' + filterRec.Practice_Area__c +'\'';
        if(filterRec.Sub_Practice_Area__c != null)
            soql = soql + ' AND Sub_Practice_Area__c = \'' + filterRec.Sub_Practice_Area__c +'\'';
        soql =soql +' LIMIT 1001';
        IsOverLimit = false;
        for(Practice_Area_Collection__c rec:database.query(soql))
        {
            if(collectionList.size()>=300)
            {
                IsOverLimit = true;
                break;
            }
            collectionList.add(new  myCollection(rec,StaticrowNumber++)); 
        }
        NewcollectionList.add(new  myCollection(new Practice_Area_Collection__c(),StaticrowNumber++));
        showResult = true;
    }
    public void DeleteSelected()
    {
        List<myCollection> NewmyCollection = new List<myCollection>();
        List<Practice_Area_Collection__c> rowForDelete = new List<Practice_Area_Collection__c>();
        system.debug('********************************'+collectionList.size());
        
        for(myCollection myc:collectionList)
            if(myc.isDelete)
                rowForDelete.add(myc.rec);
            else
                NewmyCollection.add(myc); 
        collectionList = NewmyCollection;
        if(rowForDelete.size()>0)
            delete rowForDelete;
            
        NewmyCollection = new List<myCollection>();
        for(myCollection myc:NewcollectionList)
            if(!myc.isDelete)
                NewmyCollection.add(myc); 
        NewcollectionList = NewmyCollection;
        if(NewcollectionList.size()==0)
             NewcollectionList.add(new  myCollection(new Practice_Area_Collection__c(),StaticrowNumber++));
    }
    public void addRow()
    {
        NewcollectionList.add(new  myCollection(new Practice_Area_Collection__c(),StaticrowNumber++));
    }
    public PageReference Save()
    {
        List<Practice_Area_Collection__c> rowForInsert = new List<Practice_Area_Collection__c>();
        boolean isError=false;
        for(myCollection myc:collectionList)
        {
            if(myc.rec.Business_Line__c ==null)
            {
                isError=true;
                myc.rec.Business_Line__c.addError('field is compulsory');
            }
            if(myc.rec.Geography__c ==null)
            {
                isError=true;
                myc.rec.Geography__c.addError('field is compulsory');
            }
            if(myc.rec.Practice_Area__c==null)
            {
                isError=true;
                myc.rec.Practice_Area__c.addError('field is compulsory');
            }
            if(myc.rec.Sub_Practice_Area__c==null)
            {
                isError=true;
                myc.rec.Sub_Practice_Area__c.addError('field is compulsory');
            }
            
            rowForInsert.add(myc.rec);
        }
        if(!isError)
        update rowForInsert;
        
        rowForInsert = new List<Practice_Area_Collection__c>();
        for(myCollection myc:NewcollectionList)
        {
            if(myc.rec.Business_Line__c !=null || myc.rec.Geography__c!=null || myc.rec.Practice_Area__c!=null || myc.rec.Sub_Practice_Area__c!=null)
            {
                if(myc.rec.Business_Line__c ==null)
                {
                    isError=true;
                    myc.rec.Business_Line__c.addError('field is compulsory');
                }
                if(myc.rec.Geography__c ==null)
                {
                    isError=true;
                    myc.rec.Geography__c.addError('field is compulsory');
                }
                if(myc.rec.Practice_Area__c==null)
                {
                    isError=true;
                    myc.rec.Practice_Area__c.addError('field is compulsory');
                }
                if(myc.rec.Sub_Practice_Area__c==null)
                {
                    isError=true;
                    myc.rec.Sub_Practice_Area__c.addError('field is compulsory');
                }
                rowForInsert.add(myc.rec);
            }
        }
        if(!isError)
        {
            insert rowForInsert;    
            return new PageReference('/apex/MenuItems');
        }
        else
        {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR,'Please check the errors.');
            ApexPages.addMessage(msg);
            return null;
        }
    }
    public PageReference Cancel()
    {
        return new PageReference('/apex/MenuItems');
        
    }
}