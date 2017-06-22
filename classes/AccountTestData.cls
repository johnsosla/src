public class AccountTestData {

    public static List<Account> createAccounts(Integer NumberOfRecordsTocreate) {
        List<Account> accountsToCreate = new List<Account>();
        
        for(Integer i = 0; i< NumberOfRecordsToCreate; i++) {
        	Account account = new Account();
            account.Name = 'Test Account ' + i;
            accountsToCreate.add(account);
        }
        
        return accountsToCreate;
    }
}