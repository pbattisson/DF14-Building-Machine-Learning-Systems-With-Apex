# Building Machine Learning Systems with Apex

This is the repository showing the code demoed in the Dreamforce 2014 session with the same name. The codebase includes the custom objects for the Clustering Run and Iteration objects. In the demo shown we used a Country object and created some data from this. For this packaged version, intended to be used as a base for developer's to work from, this object is excluded and the tests's use the Account's "json__c" field which will be added as part of the deployment. 

We felt this was more sensible as everyone will have this object and it is our expectation that most work will be done with this object initially (segmenting accounts based upon revenue, number of locations, etc.). To work with a different object, just add a large text field called json (API name json__c).

## About This Work

This project is the work of Jennfier Wyher and Paul Battisson, both of Mavens Consulting, for their 2014 Dreamforce session entitled "Building Machine Learning Systems with Apex". This work is provided under the MIT License and no warranty or guarantee is provided. You use this code at your own risk. This code is intended for demonstration purposes. It could use a few more tests for catching things in some of the processing, however effort has been spent to lower resource usage for the demonstration over this. Should you have any questions around the code please reach out via the issues log or twitter to Paul (twitter.com/pbattisson). 

If you would like to discuss applications for the code please feel free to contact us. And please let us know if you use this commercially - it would be great to know about it!