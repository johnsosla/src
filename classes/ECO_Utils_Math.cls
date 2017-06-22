public without sharing class ECO_Utils_Math {
	public static Decimal sigmoid (Decimal x) {
		return (1 / (1 + Math.exp(-Math.abs(x))));
	}
	
	public static Double quadraticEquationRoot1 (Double a, Double b, Double c) {    
	    Double root1, root2; 
	    root1 = (-b + Math.sqrt(Math.pow(b, 2) - 4*a*c)) / (2*a);
	    root2 = (-b - Math.sqrt(Math.pow(b, 2) - 4*a*c)) / (2*a);
	    return Math.max(root1, root2);  
	}
	
	public static Double quadraticEquationRoot2 (Double a, Double b, Double c) {    
	    Double root1, root2; 
	    root1 = (-b + Math.sqrt(Math.pow(b, 2) - 4*a*c)) / (2*a);
	    root2 = (-b - Math.sqrt(Math.pow(b, 2) - 4*a*c)) / (2*a);
	    return Math.min(root1, root2);
	}

	public static Decimal ifNull(Decimal val) {
		return val == null ? 0 : val;
	}
}