public with sharing class AccountBuilder {
	
	String name = 'test account';
	 
	public AccountBuilder withName(String name) {
        this.name = name;
        return this;
    }
    
	public Account build() {
        return new Account(name = this.name);
    }
}