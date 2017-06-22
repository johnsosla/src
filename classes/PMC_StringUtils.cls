public class PMC_StringUtils {
	public static Boolean equalsIgnoreCase(String s1, String s2) {
		if (s1 == null && s2 == null) return true;
		if (s1 == null && s2 != null || s1 != null && s2 == null) return false;

		return s1.trim().equalsIgnoreCase(s2.trim());
	}

	public static Boolean stringIContains(String target, String searchStr) {
		if (target == null || searchStr == null) return false;

		return target.trim().toLowerCase().contains(searchStr.trim().toLowerCase());
	}
}