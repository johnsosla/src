public abstract class CFM_CSVGenerator {


    private Set<String>         mCustomFields        {get; set;}
    private List<String>        mColumnHeaders       {get; set;}
    private Map<String, String> mColumnNamesToFields {get; set;}

    protected List<CFM_BaseModel> mRows;

	public CFM_CSVGenerator(List<CFM_BaseModel> rows) {
		mRows = rows;
        mColumnHeaders = getColumnHeaders();
        mColumnNamesToFields = getColumnNamesToFields();
        mCustomFields = getCustomFields();
	}

    public CFM_CSVResult generateCSV(Boolean isPreview) {
        String contents = generateCSVContents();
        CFM_Attachment attach = new CFM_Attachment();
        attach.setName(getAttachmentName(isPreview));
        attach.setIsPrivate(false);
        attach.setParentId(getAttachmentParentId());
        attach.setBody(Blob.valueOf(contents));
        attach.save();
        
        return new CFM_CSVResult(attach.getId(), contents);
    }

    public String generateCSVContents() {
        CFM_CSVRow.setupHeaders(mColumnHeaders);

        String csvString = CFM_CSVRow.headersToString();

        for (CFM_BaseModel row : mRows) {
            CFM_CSVRow csvRow = new CFM_CSVRow();

            for (String header : mColumnHeaders) {
                String value;
                if (mCustomFields.contains(header)) {
                    value = getCustomValue(header, row);
                }
                else {
                    String objectColumn = mColumnNamesToFields.get(header);
                    value = String.valueOf(row.get(objectColumn));
                }
                csvRow.put(header, value);
            }
            csvString += '\n' + String.valueOf(csvRow);
        }

        return csvString;
    }

    //---Set of fields which have custom implementations to get the values
    protected abstract Set<String>         getCustomFields();
    protected abstract List<String>        getColumnHeaders();
    protected abstract Map<String, String> getColumnNamesToFields();
    protected abstract String              getCustomValue(String customHeader, CFM_BaseModel row);
    protected abstract String              getAttachmentName(Boolean isPreview);
    protected abstract Id                  getAttachmentParentId();

    public class CFM_CSVResult {
        public Id         CsvAttachId {get; set;}
        public String     CsvContents {get; set;}

        public CFM_CSVResult() {

        }

        public CFM_CSVResult(Id attachId, String contents) {
            CsvAttachId = attachId;
            CsvContents = contents;
        }
    }

    public class UnknownCustomImplementationHeaderException extends Exception {}

}