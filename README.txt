Prototype article recommender based on the OpenURL Router Data. All code written for the Using OpenURL 
Activity Data project by EDINA (University of Edinburgh) --Read more

http://demos.openurl.ac.uk/

OpenURLRouterADPrototype README 
=========================

# Authors: Dimitrios Sferopoulos and Sheila Fraser
# Last Updated: 22nd August 2011

About
=====

The 'Using OpenURL Activity Data' project was undertaken by EDINA (the UK National Data Centre based
at the University of Edinburgh). The project released OpenURL activity data for use by third parties 
as a means of supporting development of innovative functionality that serves the UK educational 
community and developed a prototype article recommender based on the data to demonstrate how the 
data could be used by others.

The OpenURL Router Data is derived from the logs of the OpenURL Router, which directs user requests
for academic papers to the appropriate institutional resolver. The details of the dataset, sample 
files and the data itself is available at http://openurl.ac.uk/doc/data/thedata.html.

The software (see licence.txt) does the following:
Perl scripts:
    * Takes the data from the csv format provided and populates a mySQL database
    * Saves a subset of the data into a separate table for quick retrieval 
    (used in the web application dropdown list)
Grails code:
    * Allows a user to select an article from a pre-defined list and view related articles (recommendations)

This is the product of JISC-funded project activity, with the exception of the effort involved in
making this available on github, which was completed in personal time. See 
http://edina.ac.uk/projects/Using_OpenURL_Activity_data_summary.html for more information on the project.

All technical development was carried out by the technical team based at EDINA (see AUTHORS.txt).


CREATING THE DATABASE
=====================

Two of scripts (add_to_db.pl & cache_dropdown_list.pl) and the web application make use of a MySQL 
database. To create the database run the script db_create.sql. That should create three tables
(articles, aweights and sessions). You can view the schema in db_schema.jpeg.


RUNNING THE SCRIPTS
===================

You need to run the perl scripts in order to populate the database:

First find and edit the following lines in the scripts 'add_to_db.pl' and 'cache_dropdown_list.pl' 
to include your specific database settings:

	host = "127.0.0.1";
	database = "openurlrec";
	user = "yourDBuser";
	password = "yourDBpassword";
	port = "3306";


Download the data from the our website http://openurl.ac.uk/doc/data/thedata.html, save it in the
'data' directory and unzip it. 

Then run the scripts in the following sequence (for running instructions run 'perldoc'):

	perl extract_proxy_free.pl
	perl get_sessions.pl
	perl group_single_request_sessions.pl
	perl del_single_req_sessions.pl
	perl add_to_db.pl
	perl cache_dropdown_list.pl


Run the above scripts for each of the different data files.

WEB APPLICATION
===============

The web application uses a MySQL database. A JDBC MySQL driver needs to be downloaded and installed.
All you have to do is download the driver from here: http://dev.mysql.com/downloads/connector/j/ 
and save it in the openurlrec/lib/ directory.

After you have your MySQL database set up, open the file IndexController.groovy in 
openurlrec/grails-app/controllers/recommenderprototype and edit the following two lines to match
your specific database settings.

    String username = "yourDBuser";
    String passwd = "yourDBpassword";


The application, built in grails, can run under Tomcat or Jetty. You can of course run the
application through grails (http://grails.org/Download) by going into the 'openurlrec' directory
and running 'grails run-ap'. That should run the application in http://localhost:8080.

The web application queries a database named 'openurlrec' so would advice to name your database like
this to avoid having to change the code.

View the application running here: http://demos.openurl.ac.uk