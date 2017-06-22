/*
 * Author : Sujit Kumar
 * Provides the exception context, error code and error Message for an exception.
 *
 */
public virtual class ECO_BaseException extends Exception {
	
    private List<InfoItem> infoItems = new List<InfoItem>();

    private class InfoItem {
        public String errorContext = null;
        public String errorCode  = null;
        public String errorText  = null;
        
        public InfoItem(String contextCode, String errorCode, String errorText) {
            this.errorContext = contextCode;
            this.errorCode   = errorCode;
            this.errorText   = errorText;
        }
    }

    public ECO_BaseException(String errorContext, String errorCode, String errorMessage) {
        addInfo(errorContext, errorCode, errorMessage);
    }

    public ECO_BaseException(String errorContext, String errorCode, String errorMessage, Exception cause) {
        initCause(cause);
        addInfo(errorContext, errorCode, errorMessage);
    }

    public ECO_BaseException addInfo(String errorContext, String errorCode, String errorText) {
        this.infoItems.add(new InfoItem(errorContext, errorCode, errorText));
        return this;
    }

    public String getCode() {
        StringBuffer builder = new StringBuffer();

        for (Integer i = this.infoItems.size()-1 ; i >=0; i--) {
            InfoItem info = this.infoItems.get(i);
            builder.append('[');
            builder.append(info.errorContext);
            builder.append(':');
            builder.append(info.errorCode);
            builder.append(']');
        }

        return builder.toString();
    }

    public String toString() {
        StringBuffer builder = new StringBuffer();

        builder.append(getCode());
        builder.append('\n');

        //append additional context information.
        for (Integer i = this.infoItems.size()-1 ; i >=0; i--) {
            InfoItem info = this.infoItems.get(i);
            builder.append('[');
            builder.append(info.errorContext);
            builder.append(':');
            builder.append(info.errorCode);
            builder.append(']');
            builder.append(info.errorText);
            if (i>0) builder.append('\n');
        }

        //append root causes and text from this exception first.
        if (getMessage() != null) {
            builder.append('\n');
            if (getCause() == null) {
                builder.append(getMessage());
            } else if (!getMessage().equals(getCause().getMessage())) {
                builder.append(getMessage());
            }
        }
        appendException(builder, getCause());

        return builder.toString();
    }

    private void appendException(StringBuffer builder, Exception myException) {
        if (myException == null) return;
        appendException(builder, myException.getCause());
        builder.append(myException.getMessage());
        builder.append('\n');
    }
}