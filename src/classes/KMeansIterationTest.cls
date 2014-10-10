@isTest
private class KMeansIterationTest {
   static testmethod void testIteration() {
        // Initialize data
        List<Double> dataPt = new List<Double>{1,2,3};
        Country__c c1 = new Country__c(Name = 'c1', json__c=JSON.serialize(dataPt));
        insert c1;

        dataPt = new List<Double>{2,3,4};
        Country__c c2 = new Country__c(Name = 'c2', json__c=JSON.serialize(dataPt));
        insert c2;
        
        dataPt = new List<Double>{1,5,4};
        Country__c c3 = new Country__c(Name = 'c3', json__c=JSON.serialize(dataPt));
        insert c3;

        dataPt = new List<Double>{3,7,4};
        Country__c c4 = new Country__c(Name = 'c4', json__c=JSON.serialize(dataPt));
        insert c4;


        Set<Id> ids = new Set<Id>{c1.id, c2.id, c3.id, c4.id};
        Integer numClusters = 2;
        Double maxValue = 7;
        Clustering_Run__c cRun = KMeans.createClustering(ids, numClusters, dataPt.Size(), maxValue);
        // Don't randomly initiate, set
        //Iteration__c iteration = KMeans.initiateClustering(cRun);
        Matrix initialCentroids = new Matrix(0, 3);
        List<Double> centroid = new List<Double>{1, 2, 3};
        initialCentroids.addRow(centroid);
        centroid = new List<Double>{2,3,4};
        initialCentroids.addRow(centroid);

        Iteration__c iteration = new Iteration__c();
        iteration.Clustering_Run__c = cRun.Id;
        iteration.Sequence__c = 1;
        iteration.Centroid_Matrix__c = JSON.serialize(initialCentroids);
        insert iteration;
        


        Test.startTest();
        KMeans.kickoffClustering(iteration);
        Test.stopTest();


        // verify the results of the iteration
        Attachment attach = [SELECT Body FROM Attachment WHERE Name = 'JSON' and ParentId = :iteration.Id];
        List<List<Id>> assignment = (List<List<Id>>)JSON.deserialize(((Blob)attach.Body).toString(), List<List<Id>>.class);

        List<Id> cluster1 = assignment[0];
        System.assertEquals(1, cluster1.size());
        List<Id> cluster2 = assignment[1];
        System.assertEquals(3, cluster2.size());

    }
}