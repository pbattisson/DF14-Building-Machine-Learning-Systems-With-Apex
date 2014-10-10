/**
  * @author Jennfier Wyher
  * @description This class is where the main processing occurs for the runs. The batch job assigns each point to a 
  *							 centroid and calculates a running total to build the average correctly. At the end of the process a 
  *							 new iteraration is kicked off if needed.
  */
global class KMeansIteration implements Database.Batchable<sObject>, Database.Stateful {
	
	String query;  // get the records identified by the recordIds;
	private final Integer maxIterations = 10;
	private Integer numClusters;
	private Integer dimension;
	private Matrix centroid;
	private List<Id> recordIds;
	private Id cId;
	private Id iterationId;
	private Integer sequence;
	private String objectName;

	private Matrix clusterTotals;			// running total, each row represents a cluster
	private List<List<Id>> idClusters;		// ids associated with each cluster

	
	global KMeansIteration(Id iterationId) {
		this.iterationId = iterationId;
		
		Iteration__c iteration = [SELECT Id, Centroid_Matrix__c, Sequence__c,
					Clustering_Run__r.Id, Clustering_Run__r.Ids_for_Clustering__c, Clustering_Run__r.Initial_Number_of_Clusters__c, Clustering_Run__r.Dimensions__c 
					FROM Iteration__c WHERE Id = :iterationId];

		// get clustering details
		centroid = (Matrix)JSON.deserialize(iteration.Centroid_Matrix__c, Matrix.class);
		cId = iteration.Clustering_Run__r.Id;
		Attachment attach = [SELECT Body FROM Attachment WHERE Name = 'JSON' and ParentId = :cId];
		recordIds = (List<Id>)JSON.deserialize(((Blob)attach.Body).toString(), List<Id>.class);
		numClusters = Integer.valueOf(iteration.Clustering_Run__r.Initial_Number_of_Clusters__c);
		dimension = Integer.valueOf(iteration.Clustering_Run__r.Dimensions__c);
		sequence = iteration.Sequence__c.intValue();

		if (recordIds.size() ==0) { return; }

		// get records and data to analyze
		Schema.SObjectType token = recordIds[0].getSObjectType();
        objectName = token.getDescribe().getName();
		query = 'select id, json__c from '+ objectName + ' where Id in :recordIds';	 

		// initialize values to calculate new centroid
   		clusterTotals = new Matrix(numClusters, dimension);
   		clusterTotals.fill(0);

   		idClusters = new List<List<Id>>();
   		for (Integer i=0;i<numClusters;i++) {
   			idClusters.add(new List<Id>());
   		}

	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

  	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		// assign each record to a cluster
   		for (sObject obj: scope) {
	   		Id recordId = (Id)obj.get('id');
	   		List<Double> vector = (List<Double>)JSON.deserialize((String)obj.get('json__c'), List<Double>.class);

	   		if(vector.size() != 0){
	  			Integer index = clusterAssignment(vector);

	   			List<Id> idList = idClusters[index];
	   			idList.add(recordId);
	   			idClusters[index] = idList;

	   			List<Double> total = clusterTotals.getRow(index);
	   			for (Integer col=0;col<dimension;col++) {
	   				total[col] = total[col] + vector[col];
	   			}
	   			clusterTotals.setRow(total, index);
	   		}
   		}	
	}


	// return the index of the cluster to assign to
	private Integer clusterAssignment(List<Double> vector) {
		Integer minIndex = 0;
		Double minValue = null; 

		Integer rows = centroid.rows, cols = centroid.columns;

		// calculate the euclidean distance and find minimum
		for(Integer i = 0; i < rows; i++) {
			List<Double> row = centroid.getRow(i);
			Double value = 0;
			for(Integer j = 0; j < cols; j ++) {
				value += Math.pow(vector[j] - row[j], 2);
			}
			if (minValue == null || value< minValue) {
				minValue = value;
				minIndex = i;
			}
		}

		return minIndex;
	}


	// calculate the new centroids
	// divide the clusterTotal rows by the size of the clusterIds 
	private Matrix calcCentroids() {
		Integer size;
		for (Integer num=0;num<numClusters;num++) {
			size = idClusters[num].size();
			
			if (size == 0) {
				clusterTotals.setRow(centroid.getRow(num), num); // keep the same centroid point
			} else {
				for(Integer col=0;col<dimension;col++) {
					clusterTotals.setElement(num, col, clusterTotals.getElement(num, col)/size);
				}
			}
		}
		return clusterTotals;
	}


	
	global void finish(Database.BatchableContext BC) {
   		Matrix newCentroid = calcCentroids();

   		// Save the results
 		Attachment attach = new Attachment();
		attach.Name = 'JSON';
		attach.ParentId = iterationId;
		attach.Body = Blob.valueOf(JSON.serialize(idClusters));
		insert attach;

 		// save the new Centroid for the next Iteration
 		Iteration__c iteration = new Iteration__c();
 		iteration.Sequence__c = sequence+1;
		iteration.Clustering_Run__c = cId;
		iteration.Centroid_Matrix__c = JSON.serialize(newCentroid);
		insert iteration;

		iterationId = iteration.Id;
		if (sequence < maxIterations) {
			KMeansIteration kmIteraction = new KMeansIteration(iterationId);
			Database.executeBatch(kmIteraction, 50);
		}
	}
	
}