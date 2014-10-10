public with sharing class KMeansPlaybackController {
	
	public Id clusterId {get; private set;}
	public String initialData {get; private set;}
	
	public KMeansPlaybackController(ApexPages.StandardController controller) {
		clusterId = controller.getRecord().id;
		initialData = JSON.serialize(getAssignmentsForIteration(1, clusterId));
	}

	@RemoteAction
	public static Map<String, Object> getAssignmentsForIteration(Integer iterationNumber, Id runId){
		Iteration__c iteration = [SELECT Id, Centroid_Matrix__c, Sequence__c FROM Iteration__c WHERE Clustering_Run__c = :runId AND Sequence__c = :iterationNumber];
		Attachment assignmentAttach = [SELECT ParentId, Body FROM Attachment WHERE ParentId = :iteration.Id];
		List<List<Id>> assignment = (List<List<Id>>)JSON.deserialize(((Blob)assignmentAttach.Body).toString(), List<List<Id>>.class);
		assignmentAttach = null;

		Attachment clusterIdAttachment = [SELECT ParentId, Body FROM Attachment WHERE ParentId = :runId];
		List<Id> idsForClustering = (List<Id>)JSON.deserialize(((Blob)clusterIdAttachment.Body).toString(), List<Id>.class);
		clusterIdAttachment = null;

		if(idsForClustering.size() > 100){
			List<Id> tmpIdList = new List<Id>();
			for(Integer i = 0; i < 100; i++){
				tmpIdList.add(idsForClustering[i]);
			}
			idsForClustering = tmpIdList;
			tmpIdList = null;
		}

		String objectName = idsForClustering[0].getSObjectType().getDescribe().getName();

		Map<Id, Sobject> clusteringRecords = new Map<Id, SObject>(database.query('SELECT Id, json__c FROM ' + objectName + ' WHERE Id in :idsForClustering'));

		idsForClustering = null;

		Matrix centroids = (Matrix)JSON.deserialize(iteration.Centroid_Matrix__c, Matrix.class);

		Map<String, Object> returnData = new Map<String, Object>();

		for(Integer i = 0, j = centroids.rows; i < j; i++){
			returnData.put('Centroid Position ' + (i+1), centroids.getRow(i)[0]);
			returnData.put('Centroid Position ' + (i+1) + ' x', centroids.getRow(i)[1]);
			returnData.put('Assigned to Centroid ' + (i+1), new List<Double>());
			returnData.put('Assigned to Centroid ' + (i+1) + ' x', new List<Double>());
		}

		for(Integer i = 0, j = assignment.size(); i < j; i++){
			for(Integer x = 0, y = assignment[i].size(); x < y; x++){
				if(clusteringRecords.containsKey(assignment[i][x])){
					List<Double> values = (List<Double>)JSON.deserialize((String)(clusteringRecords.get(assignment[i][x]).get('json__c')), List<Double>.class);
					((List<Double>)(returnData.get('Assigned to Centroid ' + (i+1)))).add(values[0]);
					((List<Double>)(returnData.get('Assigned to Centroid ' + (i+1) + ' x'))).add(values[1]);
				}
			}

		}

		return returnData;

	}
}