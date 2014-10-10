/**
  * @author Paul Battisson
  * @description Test class for the KMeansPlaybackController.
  */
@isTest
private class KMeansPlaybackControllerTest {

	private static List<Id> createAccounts(Integer num) {
		List<Account> accounts = new List<Account>();
		for(Integer i = 1; i <= num; i++) {
			Account acc = new Account();
			acc.Name = 'test ' + i;
			acc.json__c = '[' + i*Math.random()*10 + ',' + i*Math.random()*10 + ']';
			accounts.add(acc);
		}

		insert accounts;
		List<Id> accountIds = new List<Id>();
		for(Integer j = 0; j < num; j++) {
			accountIds.add(accounts[j].Id);
		}

		return accountIds;
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

	private static Iteration__c createIteration(Id runId, List<Id> assignIds) {
		
		Iteration__c iteration = new Iteration__c();
		iteration.Clustering_Run__c = runId;
		iteration.Sequence__c = 1;
		iteration.Centroid_Matrix__c = JSON.serialize(new Matrix('[[1,1],[2,2]]'));

		insert iteration;

		Attachment attach = new Attachment();
		attach.Name = 'JSON';
		attach.ParentId = iteration.Id;
		attach.Body = Blob.valueOf(JSON.serialize(new List<List<Id>>{assignIds}));
		insert attach;

		return iteration;
	}

	@isTest 
	private static void testRetrieveIterationData() {
		List<Id> accIds = createAccounts(2);
		Clustering_Run__c run = createRun(accIds);
		Iteration__c iteration = createIteration(run.Id, accIds);

		ApexPages.StandardController stdController = new ApexPages.StandardController(run);
		KMeansPlaybackController controller = new KMeansPlaybackController(stdController);
		System.assertnotEquals(null, controller.initialData);
	}

}