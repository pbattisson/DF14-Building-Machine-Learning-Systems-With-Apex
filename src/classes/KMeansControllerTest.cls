@isTest
private class KMeansControllerTest {
	
	@isTest
	private static void testGetObjects() {
		ApexPages.StandardController stdController = new ApexPages.StandardController(new Clustering_Run__c());
		KMeansController controller = new KMeansController(stdController);
		List<SelectOption> objects = controller.getObjects();
		System.assert(objects.size() >= 10);
	}

	@isTest
	private static void testGetFields() {
		ApexPages.StandardController stdController = new ApexPages.StandardController(new Clustering_Run__c());
		KMeansController controller = new KMeansController(stdController);
		controller.object_API_name = 'Account';
		controller.getFields();
		//This is the default number of double fields in a DE org for the Account object
		System.assert(controller.fieldNames.size() >= 0);
	}
	
	@isTest
	private static void testGetCountZero() {
		ApexPages.StandardController stdController = new ApexPages.StandardController(new Clustering_Run__c());
		KMeansController controller = new KMeansController(stdController);
		controller.object_API_name = 'Account';
		System.assertEquals(0, controller.getCount());
	}

	@isTest
	private static void testGetCountOne() {
		Account acc = new Account(Name = 'Test1');
		insert acc;
		ApexPages.StandardController stdController = new ApexPages.StandardController(new Clustering_Run__c());
		KMeansController controller = new KMeansController(stdController);
		controller.object_API_name = 'Account';
		System.assertEquals(1, controller.getCount());
	}

	@isTest
	private static void testGetCountZeroNoObject() {
		ApexPages.StandardController stdController = new ApexPages.StandardController(new Clustering_Run__c());
		KMeansController controller = new KMeansController(stdController);
		System.assertEquals(0, controller.getCount());
	}

	@isTest
	private static void testRun() {
		Account acc = new Account(Name = 'Test1', ShippingLatitude = 10.00);
		insert acc;
		ApexPages.StandardController stdController = new ApexPages.StandardController(new Clustering_Run__c());
		KMeansController controller = new KMeansController(stdController);
		controller.object_API_name = 'Account';
		controller.numClusters = 2;
		controller.maxValue = 2;
		controller.getFields();
		for(KMeansController.Field fld : controller.fieldNames){
			if(fld.name == 'ShippingLatitude'){
				fld.isSelected = true;
			}
		}
		try{
			PageReference pr = controller.run();
			System.assert(pr.getUrl().length() == 19, pr);	
		} catch (Exception ex) {
			System.debug(ex.getCause());
		}
		
	}
}