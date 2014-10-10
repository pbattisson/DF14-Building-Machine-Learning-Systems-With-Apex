@isTest
private class VectorizationBatchTest {

	private static Account createAccount() {
		List<Account> accounts = new List<Account>();
		
		Account acc = new Account();
		acc.Name = 'test Acc';
		acc.ShippingLatitude = 10.0;
		acc.ShippingLongitude = 20.0;

		insert acc;
		
		return acc;
	}

	private static Clustering_Run__c createRun(List<Id> accountIds) {
		Clustering_Run__c run = new Clustering_Run__c();
		run.Initial_Number_of_Clusters__c = 1;
		run.Dimensions__c = 2;
		run.Max_Value__c = 10;
		insert run;

		Attachment attach = new Attachment();
		attach.Name = 'JSON';
		attach.ParentId = run.Id;
		attach.Body = Blob.valueOf(JSON.serialize(accountIds));
		insert attach;

		return run;
	}
	
	@isTest
	static void TestVectorizeAccount() {
		Account acc = createAccount();
		Clustering_Run__c run = createRun(new List<Id>{acc.Id});

		String query = 'Select Id, json__c, ShippingLatitude, ShippingLongitude From Account';
		List<String> fields = new List<String>{'ShippingLatitude', 'ShippingLongitude'};

		Test.startTest();

		Database.executeBatch(new VectorizationBatch(query, run.Id, fields),1);

		Test.stopTest();

		Account updatedAcc = [SELECT Id, json__c FROM Account WHERE Id = :acc.Id];

		System.assertEquals('[10.0,20.0]', updatedAcc.json__c, updatedAcc.json__c);
	}
	
}