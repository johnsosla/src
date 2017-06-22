/** ------------------------------------------------------------------------------------------------------
 *	The mapper class interface
 * 
 * @Author      NTT Data - Deborah Orth
 * @Date        August 2016
 *-----------------------------------------------------------------------------------------------------*/
public abstract class ECO_BaseMapper {

	protected Attributes attributes 	{ get; set; }

	/**
	 * @Description used to step over unmapped items
	 *
	 * @Author  NTT Data - Deborah Orth
	 * @Date    Aug 2016
	 *
	 * @param	parser
	 * @return 	
	 **/
	public static void stepOverObject( JSONParser parser){
		Integer depth = 0;
		do {
			JSONToken curr = parser.getCurrentToken();
			if( curr == JSONToken.START_OBJECT || curr == JSONToken.START_ARRAY){
				depth++;
			} else if( curr == JSONToken.END_OBJECT || curr == JSONToken.END_ARRAY){
				depth--;
			}
		} while( depth > 0 && parser.nextToken() != null);
	}

	/** ------------------------------------------------------------------------------------------------------
	* @Description 
	*
	* @Author      NTT Data - Deborah Orth
	* @Date        August 2016
	*-----------------------------------------------------------------------------------------------------*/
	public class Attributes {
		public String type_Z 			{ get; set; }
		public String url 				{ get; set; } 

		/**
		 * @Description all SObject when serialized into JSON include an attributes section
		 *
		 * @Author  NTT Data - Deborah Orth
		 * @Date    Aug 2016
		 *
		 * @param	parser
		 * @return 	
		 **/
		public Attributes( JSONParser parser) {
			while( parser.nextToken() != JSONToken.END_OBJECT) {
				if( parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String token = parser.getText();
					if( parser.nextToken() != JSONToken.VALUE_NULL) {
						if( token == 'type') {
							type_Z = parser.getText();
						} else if( token == 'url') {
							url = parser.getText();
						} else {
							System.debug( LoggingLevel.WARN, 'Attributes consuming unrecognized property: ' + token);
							stepOverObject(parser);
						}
					}
				}
			}
		}
	}
}