global class VectorizationBatch implements Database.Batchable<sObject> {
	
	private String query;
	private Clustering_Run__c run;
	private List<String> fieldNames;
	
	global VectorizationBatch(String qryString, Id clusterId, List<String> fields) {
		run = [SELECT Max_Value__c, Dimensions__c, Ids_for_Clustering__c, Initial_Number_of_Clusters__c FROM Clustering_Run__c where Id = :clusterId];
		query = qryString;
		fieldNames = fields;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		Attachment attach = [SELECT Body FROM Attachment WHERE Name = 'JSON' and ParentId = :run.Id];
		Set<Id> ids = (Set<Id>)JSON.deserialize(((Blob)attach.Body).toString(), Set<Id>.class);
		//Set<Id> ids = (Set<Id>)JSON.deserialize(run.Ids_for_Clustering__c, Set<Id>.class);
		return Database.getQueryLocator(query + ' WHERE Id in :ids');
	}

  global void execute(Database.BatchableContext BC, List<sObject> scope) {
		List<SObject> jsonRecords = new List<SObject>();
		for(Integer i = 0, j = scope.size(); i < j; i++) {
			jsonRecords.add(vectorise(scope[i]));
		}
		update jsonRecords;
	}
	
	// transform the data and serialize into the json__c field.
	private SObject vectorise(SObject rec) {

		List<Double> vector = new List<Double>();
		Double value;
		for (String f: fieldNames) {
			value = (Double)rec.get(f);
			vector.add(value);
		}
		String s = JSON.serialize(vector);
		rec.put('json__c',s);
		return rec;
	}

	global void finish(Database.BatchableContext BC) {
		Iteration__c iteration = KMeans.initiateClustering(run);	
		KMeans.kickoffClustering(iteration);
	}
	
}