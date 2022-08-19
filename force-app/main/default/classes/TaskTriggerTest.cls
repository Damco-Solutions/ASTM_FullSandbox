@isTest
private class TaskTriggerTest {
	@isTest static void testTaskUpdate() {
		Account account = new Account(Name='testaccount');
		insert account;
        Contact contact = new Contact(FirstName='Joe',LastName='Test',AccountId=account.Id);
        insert contact;
		test.startTest();
		Task task = new Task(Subject='Test',Description='Description Test',ActivityDate=Date.Today(),WhoId=contact.Id);
		insert task;
		test.stopTest();
	}
}