@isTest
public class ECO_SortOptionListTest {

	static testMethod void testSortOptionListS() {
	
		List<SelectOption> selections = new List<SelectOption>();
		selections.add(new SelectOption('A', 'A'));	
		selections.add(new SelectOption('D', 'D'));
		selections.add(new SelectOption('B', 'B'));
		selections.add(new SelectOption('C', 'C'));

		ECO_SortOptionList sortOptionList = new ECO_SortOptionList();

		ECO_SortOptionList.SortOptionList(selections);
	}
}