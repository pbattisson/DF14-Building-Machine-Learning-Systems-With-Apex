/**
  * @author Paul Battisson, Jennfier Wyher
  *	@description This class has the single static method "runClustering" which should be used as an entry point 
  *				 to initialize a new clustering run on some data set.
  **/
public with sharing class KMeans {

	//Static method to initialize a clustering run for a given record set
	public static Clustering_Run__c createClustering(Set<Id> ids, Integer numClusters, Integer dimensions, Double maxValue) {
		
		Clustering_Run__c run = new Clustering_Run__c();
		//run.Ids_for_Clustering__c = JSON.serialize(ids);
		run.Initial_Number_of_Clusters__c = numClusters;
		run.Dimensions__c = dimensions;
		run.Max_Value__c = maxValue;

		insert run;
		Attachment attach = new Attachment();
		attach.Name = 'JSON';
		attach.ParentId = run.Id;
		attach.Body = Blob.valueOf(JSON.serialize(ids));
		insert attach;
		return run;
	}

	public static Iteration__c initiateClustering(Clustering_Run__c cRun) {
		Iteration__c iteration = new Iteration__c();
		iteration.Clustering_Run__c = cRun.Id;

		Double maxValue = cRun.Max_Value__c;
		Integer dimensions = Integer.valueOf(cRun.Dimensions__c);
		
		Matrix initialCentroids = new Matrix(0, dimensions);

		// Random assignment of the initial centroid
		for(Integer i = 0, j = Integer.valueOf(cRun.Initial_Number_of_Clusters__c); i < j; i++) {
			List<Double> centroid = new List<Double>();
			for(Integer x = 0, y = dimensions; x < y; x++) {
				centroid.add(Math.random()*maxValue);
			}
			initialCentroids.addRow(centroid);
		}

		iteration.Sequence__c = 1;
		iteration.Centroid_Matrix__c = JSON.serialize(initialCentroids);
		insert iteration;

		return iteration;
	}

	public static void kickoffClustering (Iteration__c iteration) {
		Id iterationId = iteration.Id;
		KMeansIteration kmIteration = new KMeansIteration(iterationId);
		Database.executeBatch(kmIteration, 50);		
	}
}