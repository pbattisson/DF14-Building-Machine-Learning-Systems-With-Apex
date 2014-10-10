public with sharing class KMeansController {
	private static transient Set<String> standard_objects = new Set<String>{'Account', 'Asset', 'Campaign', 'Case', 'Contact', 'Contract', 'Lead', 'Product', 'Quote'};
	
	public String object_API_name {get; set;}
	public String record_selection_type {get; set;}
	public Boolean showCriteriaSelection {get; private set;}
	public Integer numClusters {get; set;}
	public List<Field> fieldNames {get; private set;}
	public Integer maxValue {get; set;}
	private Integer dimension = 0;

	public KMeansController(ApexPages.StandardController ctrl) {
		fieldNames = new List<Field>();

	}

	public List<SelectOption> getObjects() {
		List<SelectOption> options = new List<SelectOption>();

		Map<String, Schema.SObjectType> global_describe = Schema.getGlobalDescribe();

		for(String key : global_describe.keySet()) {
			DescribeSObjectResult res = global_describe.get(key).getDescribe();
			
			if(res.getName().contains('__c') || standard_objects.contains(res.getLabel())) {
				options.add(new SelectOption(res.getName(), res.getLabel()));
			}
			
		}
		options.sort();

		List<SelectOption> displayList = new List<SelectOption>();
		displayList.add(new SelectOption('', '-- Please Select --'));
		displayList.addAll(options);

		return displayList;
	}

	public void getFields() {
		Map<String, Schema.SObjectType> global_describe = Schema.getGlobalDescribe();
		Map <String, Schema.SObjectField> fieldMap = global_describe.get(object_API_name).getDescribe().fields.getMap();
		fieldNames = new List<Field>();
		for(Schema.SObjectField sfield : fieldMap.Values()) {
			schema.describefieldresult dfield = sfield.getDescribe();	
			if(dfield.getType() == DisplayType.Double || dfield.getType() == DisplayType.Currency) {
				fieldNames.add( new Field(dfield.getName(), false));
			}
		}
	}

	public Integer getCount() {
		if(object_API_name == null) {
			return 0;
		}

		String queryString = 'SELECT COUNT() FROM ' + object_API_name;
		return Database.countQuery(queryString);
	}

	private String getQueryStringFields(){
		String qryString = '';
		for(Field f: fieldNames) {
			if (f.isSelected) {
				qryString += ',' + f.Name + ' ';
			}
		}
		return qryString;
	}

	public PageReference run() {
		String queryString = 'Select Id ' + getQueryStringFields() + 'From ' + object_API_name;
		List<Sobject> records = Database.query(queryString + ' LIMIT 50000');
		Set<Id> idSet = new Set<Id>();

		for(Integer i = 0, j = records.size(); i < j; i++) {
			idSet.add(records[i].Id);
		}

		records = new List<Sobject>();
		List<String> fieldNamesForRetrieval = new List<String>();

		for(Field f: fieldNames) {
			if (f.isSelected) {
				fieldNamesForRetrieval.add(f.Name);
			}
		}

		Id runId = KMeans.createClustering(idSet, numClusters, dimension, maxValue).Id;

		Database.executeBatch(new VectorizationBatch(queryString, runId, fieldNamesForRetrieval),10);

		return new PageReference('/'+runId);
	}

	public class Field {
		public String name {get; private set;}
		public Boolean isSelected {get;set;}

		public Field(String n, Boolean selected) {
			this.name = n;
			isSelected = selected;
		}
	}

}