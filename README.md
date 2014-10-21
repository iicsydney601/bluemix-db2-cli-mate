# DB2climate (Ruby) #

DB2climate offers an alternative (`CLI`) based console to manage your **Bluemix SQLDB** service. It is lightweight and fast. On top of that, it is capable to perform few tasks that are not currently available with SQLDB's built-in web based Managed Database Console. 

This is a Ruby app that uses the following cloud services:
 -   SQLDB 

DB2climate includes the following packages:

1. Repackaged Dan Higham’s Tmate Server
2. DB2 v9.7 FixPack 9a runtime client
3. Dropbox CLI client
4. Dropbox API client
5. A number of ruby scripts to ease the database management of SQLDBs 

## What you'll need to build DB2climate ##

1. A Bluemix account [https://ace.ng.bluemix.net/](https://ace.ng.bluemix.net/)  
2. Cloud foundry cf command line tool [https://github.com/cloudfoundry/cli](https://github.com/cloudfoundry/cli)  
3. A terminal program with ssh capability such as babun or putty  
4. A Dropbox account [http://www.dropbox.com/](http://www.dropbox.com/)  
5. A Dropbox API app [https://www.dropbox.com/developers](https://www.dropbox.com/developers)  
6. Some familiarity with db2 runtime commands is helpful   

## What can you do with DB2climate##

1. Import/load a file with IXF format to database
[https://developer.ibm.com/answers/questions/21537/is-it-possible-to-import-ixf-data-files-to-sqldb-tables/](https://developer.ibm.com/answers/questions/21537/is-it-possible-to-import-ixf-data-files-to-sqldb-tables/)
2. Export tables from SQLDB 
[https://developer.ibm.com/answers/questions/20227/is-that-possible-to-download-data-or-table-ddl-from-sqldb-console/](https://developer.ibm.com/answers/questions/20227/is-that-possible-to-download-data-or-table-ddl-from-sqldb-console/)
3. Migrate data between SQLDB instances using backup image
[https://developer.ibm.com/answers/questions/21480/migrate-data-between-sqldb-instance-using-backup-image/](https://developer.ibm.com/answers/questions/21480/migrate-data-between-sqldb-instance-using-backup-image/)
4. Add non-ephemeral disk space to Bluemix 
[https://developer.ibm.com/answers/questions/21000/adding-normal-disk-space-to-a-bluemix-app/](https://developer.ibm.com/answers/questions/21000/adding-normal-disk-space-to-a-bluemix-app/)
5. Sync data to SQLDB
[https://developer.ibm.com/answers/questions/20958/sync-data-to-bluemix-sqldb/](https://developer.ibm.com/answers/questions/20958/sync-data-to-bluemix-sqldb/)

DB2climate allows you to open a ssh connection to the application container which has DB2 runtime client, Dropbox CLI and API client preloaded and configured, therefore you can run all supported db2 commands against your SQLDBs and move data in and out of Bluemix using Dropbox cloud storage. 

## Deploy DB2climate to Bluemix  ##

### Prerequisites ###

Before we begin, we first need to install the [**cf command line tool**](https://github.com/cloudfoundry/cli/releases) that will be used to upload and manage your application. If you've previously installed an older version of the cf tool, make sure you are now using cf v6 by passing it the -v flag:
    `cf -v`

DB2climate uses Dropbox as persistent storage, therefore you will need to sign up a Dropbox account from [dropbox](https://www.dropbox.com/).  In addition, if you plan to use Dropbox-api client to manage files between app container and Dropbox cloud storage (preferred method), you will need to create a Dropbox-api app through [https://www.dropbox.com/developers/apps](https://www.dropbox.com/developers/apps "https://www.dropbox.com/developers/apps"). Once your api app is created successfully, note down the **App Key** and **App secret**. 

### Deploy to Bluemix cloud ###

1. Login to Bluemix.
    `usage:    cf login [-a API_URL]`  
    `example:  cf login -a https://api.ng.bluemix.net`        

2. Create an instance of the sqldb service.  
   `usage:    cf create-service SERVICE PLAN SERVICE_INSTANCE_NAME`  
   `example:  cf create-service sqldb sqldb_small SQLDB_001`     

3. Create a git clone of this repository.  
   `git clone https://hub.jazz.net/git/felixf/bluemix-db2-cli-mate`

4. Navigate to the clone application directory. 
   `cd bluemix-db2-cli-mate`

5. From the cloned db2climate app directory, push the app without starting (**--no-start**) flag so that we can bind our SQLDB service before starting it.  Note: This is a console app, so we don't actually create an URL or host for it.
    `usage:   cf push APP [--no-start]`  
    `example: cf push db2climate --no-start `    
    
6. Bind the SQLDB service to the new app  
    `usage:  cf bind-service APP SERVICE_INSTANCE_NAME`      
    `example: cf bind-service db2climate SQLDB_001`

7. Start the app  
   `usage:   cf start APP`    
   `example: cf start db2climate`

Note: The starting process involves downloading and installing a number of packages. This includes Ruby runtime, DB2 v9.7 runtime client, Dropbox Linux client, Dropbox API client and tmate/tmux server. The whole package is close to 400MB in size and it may take few minutes before the application fully up and running. In addition, while Bluemix  might shows the application is up and running, the application initialization may still in process. You can verify from the disk usage of the application. A complete initialized application should be around 360MB in size. Anything above that suggests that the application is not ready. Please wait for 10 seconds and run the following command to verify.   
  
`cf app db2climate`

That's it! DB2climate has now successfully deployed to the Bluemix cloud.


## ssh into DB2climate app container ##
After the app is up and running, we would like to ssh into the app container. To do that, we need to know the connection URL first. Issue 
    
`cf files db2climate logs/tmate.log`

The last 4 lines of tmate.log should look like this

    2014/09/08 12:04:06 Starting tmate...
    2014/09/08 12:04:06 1000
    2014/09/08 12:04:06 1000
    2014/09/08 12:04:07 U67RHUFbnmx2gpD41JIaRLVxw@sf.tmate.io

The connection URL is at the last line of the log. The two "1000" are the height and width of your terminal followed by the connection URL. 
 
**Tip**: If you don't see the "Starting tmate..." message at the bottom of the log, it means the application has yet to complete the initialization process, wait for 30 seocnds or so and run the "cf files" command again.  

If you are using a Windows PC, you will need a cygwin like terminal program installed. I personally use **babun** windows shell which you can download it from [https://github.com/babun/babun](https://github.com/babun/babun).  

Warning: Prior attempting to make a ssh connection for the very first time, make sure you run the **ssh-keygen** program at the home directory, otherwise, you will get connection denied error.

`{ ~ }  » ssh U67RHUFbnmx2gpD41JIaRLVxw@sf.tmate.io`  
                                                                                             `~ Permission denied (publickey).`  

Run ssh-keygen program at the home directory   
`{ ~ }  » ssh-keygen`    
`Generating public/private rsa key pair.`    
`Enter file in which to save the key (/home/felixf/.ssh/id_rsa):`  
`Enter passphrase (empty for no passphrase):`    
`Enter same passphrase again:`  
`Your identification has been saved in /home/felixf/.ssh/id_rsa.`      
`Your public key has been saved in /home/felixf/.ssh/id_rsa.pub.`  
`The key fingerprint is:`  
`ec:15:74:51:48:03:68:bb:e2:e1:eb:e9:e0:37:ae:e6 felixf@IBM-PK19GZM`  
`The key's randomart image is:`  
`+--[ RSA 2048]----+`  
`|         .oo=+.  |`  
`|        o. ...   |`  
`|       . ..      |`   
`|       ..  .     |`  
`|        S..      |`  
`|      o...       |`  
`|    .o o.        |`  
`|   ...=.         |`  
`|   oE**o         |`  
`+-----------------+`  

After running the “ssh-keygen” program, you can ssh into the app container without error.
  
    { ~ }  »  ssh U67RHUFbnmx2gpD41JIaRLVxw@sf.tmate.io  
    vcap@182bbgv126r:~$`

**Tip**: If you prefer to use putty, please refer to this blog on how to generate private keys and making connection. [https://www.ibm.com/developerworks/community/blogs/Dougclectica/entry/ssh_key_authentication_with_putty30?lang=en](https://www.ibm.com/developerworks/community/blogs/Dougclectica/entry/ssh_key_authentication_with_putty30?lang=en)

## Setup Dropbox as non-ephemeral storage ##

By default, after deployment, the is no persistent storage available for the application.   As a result, all changes written to  disk are lost if the application is stopped or restarted. Therefore, we need some kind of persistent storage so we can store our database backups or exported tables. In this article, I will show you how to use Dropbox as our non-ephemeral storage to get your data in and out of Bluemix. This is not the only solution, but it is a quick one to get working.

DB2climate supports two methods to access the Dropbox cloud storage. 
### Method 1- Dropbox Linux client: (not preferred) ###
DB2climate pre-installs a copy of Dropbox linux client. All you need to do is to start the Dropbox daemon and registers your client machine. You need to run the 
"**dropbox.py start**" command twice, the 1st time is to start the daemon, the 2nd time to reveal the registration URL link. 

    vcap@182bbgv126r:~$ dropbox.py start
    Starting Dropbox...Done!
    vcap@182bbgv126r:~$ dropbox.py start
    To link this computer to a dropbox account, visit the following url:
    https://www.dropbox.com/cli_link?host_id=476c1191d98e3e35214f4a06ba5465b6
    vcap@182bbgv126r:~$


Copy and paste the registration URL into a browser and then sign into your Dropbox account to link this computer. (**Warning**: if you plan to use your existing Dropbox account which has more than 1.7GB of files in the cloud, upon successful linking, synchronization will occur immediately and quickly fill up the local container’s free disk space causing the DB2climate application to restart automatically and all changes are lost.)

Once you link the computer successfully, you would notice a "**DropBox**" folder created under the **/app** directory and synchronization will immediately occur. You can check its sync status by issuing “**dropbox.py status**” command.

Congratulations, you have just successfully setup a persistent storage to your application container. you can now transfer files in and out of our Bluemix containers with ease. Use “dropbox.py” script to control the Dropbox daemon such as start/stop and synchronization status.  

### Method 2- Dropbox API script (preferred method) ###
DB2climate comes with a copy of Dropbox core API client installed. To avoid having to enter Dropbox API keys each time the db2climate is restarted,  you can store the Dropbox API keys securely inside the SQLDB bound to the db2climate app.  Run “**set_dbox_api.rb**” script and follow the on screen prompt to enter the API key and API secret.  Next you need to select the appropriate "Access Type", you must match the access type to your api app's "Permission type" when the api's app was created. 

Having stored the Dropbox API keys to the database, we can start using the dropbox-api program. To use it, run **dropbox-api** command. Cut and paste the URL on the screen to a browser; logon to your Dropbox account and click "Allow". Once you have done that, return to your ssh console and press enter to finish the setup.
    
Congratulations, you have just successfully link your app container to your Dropbox account. The advantage of using Dropbox API over Dropbox Linux client is that Dropbox API does not synchronize with cloud storage automatically therefore you are safe to use your existing Dropbox account. Run "`dropbox.api help`" to get a list of available commands. 
For instance, to upload the local.tar file from the container to the Dropbox's root directory, we would issue: 

	$ 	dropbox-api put local.tar dropbox:/ 

To list all the files in our dropbox account, we would issue:

	$	dropbox-api ls

## Use DB2climate as a DB2 client   ##

You can run all supported db2 commands against your SQLDBs straight away after ssh into the warden container. All TCPIP nodes and databases were automatically cataloged for you. In addition, in order to avoid users having to refer to the VCAP_SERVICE file for db credentials, a number of scripts have been developed to help you manage your database(s) with ease. 

### General purpose scripts ###
Scrpt Name:	ls_db.rb  
Purpose:	list all databases bound to the app and display their credentials.  
syntax:	 `$ ls_db.rb`

    vcap@182b9k5hdli:~$ ls_db.rb  
    +-----------+----------+----------------+----------+--------------+-----------------------+  
    |  db_name  | db_label |  host          | username |   password   | database_id | db_port |  
    +-----------+----------+----------------+----------+--------------+-----------------------+  
    | SQLDB_001 | sqldb    | 23.246.228.245 | vuxtnpkh | 1tsr1gndjrv1 | I_196883    | 50000   |  
    | SQLDB_002 | sqldb    | 23.246.228.234 | godcafuw | ziofkeplij8y | I_902477    | 50000   |  
    | SQLDB_003 | sqldb    | 23.246.228.243 | athamigu | gjxgdrivdhia | I_547489    | 50000   |  
    +-----------+----------+----------------+----------+--------------+-----------------------+  
    
 
Script Name:  catalog_db.rb  
Purpose:  catalog tcpip node and database  
Syntax:    `$ catalog_db.rb  db_name`  (where db_name is the instance name of your created SQLDB service)  
Example: `$ catalog_db.rb SQLDB_001 `   
Note: This script is executed automatically to setup your DB environment upon your ssh connection. So you don't need to run it separately.


Script Name:   connect_db.rb  
Purpose:   connect to database   
Syntax:     `$ connect_db.rb db_name` (where db_name is the instance name of your created SQLDB service)  
Exampe:   `$ connect_db.rb SQLDB_001`

Script Name: gen_dbSchema.rb  
Purpose:   generate a database schema 
Syntax:    `$  gen_dbSchema.rb [database_db_name] schema_name `   
Example 1: `$  gen_dbSchema.rb BX`  (single db instance bound to the app)  
Example 2: `$  gen_dbSchema.rb SQLDB_002 BX` (multi db instances bound to the app)  


Script Name: cr_sample_tables.rb  
Purpose:  Crate and populate two sample tables for testing export/import scripts  
syntax:   `$  cr_sample_tables.rb db_Name`  
Example:  `$ cr_sampletables.rb SQLDB_001`  

Script Name: ls_tables.rb  
Purpose:  List all tables of given schema name   
syntax:   `$  ls_tables.rb [db_name] schema_name`  
Example 1:  `$ ls_tables.rb BX`  (single db instance bound to the app)    
Example 2:  `$ ls_tables.rb SQLDB_002 BX` (multi db instances bound to the app)


### Export and Import Table scripts ###

Script Name: export_table.rb  
Purpose: export a table in supported format (ixf or del).  
Output file: the name of exported table with export format as extension  
syntax:   `$   export_table.rb [db_name] schema_name table_Name export_format`    
Example 1:  `$ export_table.rb BX country ixf`  (single db instance bound to the app)  
Output file name is `country.ixf` in the current directory  
Example 2:  `$ export_table.rb SQLDB_002 BX CITY del` (multi db instances bound to the app)  
Output file name is `CITY.del` in the current directory

Script Name: import__table.rb   
Purpose: import a table in supported formats (ixf or del) with all supported import mode  
syntax:   `$   import_table.rb [db_name] schema_name table_file_name [import_mode]`  
Supported Import mode are: `1=insert(default), 2=insert_update, 3=replace, 4=replace_create (ixf only), 5=create (ixf only)`    
Example 1:  `$ import_table.rb BX country.ixf`(single db instance bound to the app with default insert mode)  
Example 2:  `$  import_table.rb SQLDB_002 BX country.ixf 2` (multi db instances bound to the app with insert_update mode)  
  

### Backup and Restore Database scripts ###
Unfortunately,  we are not able to run the built-in **db2 backup** or **db2 restore** utility with db2climate.  This is because the default user does not have enough authority to perform backup and restore as the `db2 get authorization` command tells all.

    vcap@182b9k5hdli:~$ db2 get authorizations  
    
     Administrative Authorizations for Current User
    
     Direct SYSADM authority= NO  
     Direct SYSCTRL authority   = NO  
     Direct SYSMAINT authority  = NO  
     Direct DBADM authority = YES  
     Direct CREATETAB authority = YES  
     Direct BINDADD authority   = YES  
     Direct CONNECT authority   = YES  
     Direct CREATE_NOT_FENC authority   = YES  
     Direct IMPLICIT_SCHEMA authority   = YES  
     Direct LOAD authority  = YES  
     Direct QUIESCE_CONNECT authority   = YES  
     Direct CREATE_EXTERNAL_ROUTINE authority   = YES  
     Direct SYSMON authority= NO  
    
     Indirect SYSADM authority  = NO  
     Indirect SYSCTRL authority = NO  
     Indirect SYSMAINT authority= NO  
     Indirect DBADM authority   = NO  
     Indirect CREATETAB authority   = NO  
     Indirect BINDADD authority = NO  
     Indirect CONNECT authority = NO  
     Indirect CREATE_NOT_FENC authority = NO  
     Indirect IMPLICIT_SCHEMA authority = NO  
     Indirect LOAD authority= NO  
     Indirect QUIESCE_CONNECT authority = NO  
     Indirect CREATE_EXTERNAL_ROUTINE authority = NO  
     Indirect SYSMON authority  = NO  
    
    vcap@182b9k5hdli:~$  

DB2 backup/restore utility requires an instance level authority such as SYSADM, SYSCTRL or SYSMAINT. The default user, however, only has DBADM authority, so any attempts to run backup and restore will result in this error.

    vcap@182b9k5hdli:~$ ls_db.rb  

    +-----------+----------+----------------+----------+--------------+-------------+---------+  
    |  db_name  | db_label |  host          | username |   password   | database_id | db_port |  
    +-----------+----------+----------------+----------+--------------+-------------+---------+  
    | SQLDB_001 | sqldb    | 23.246.228.245 | vuxtnpkh | 1tsr1gndjrv1 | I_196883    | 50000   |  
    | SQLDB_002 | sqldb    | 23.246.228.234 | godcafuw | ziofkeplij8y | I_902477    | 50000   |  
    | SQLDB_003 | sqldb    | 23.246.228.243 | athamigu | gjxgdrivdhia | I_547489    | 50000   |  
    +-----------+----------+----------------+----------+--------------+-------------+---------+ 
 
    vcap@182b9k5hdli:~$ db2 backup db I_196883 user vuxtnpkh using 1tsr1gndjrv1  
    SQL1092N  "VUXTNPKH" does not have the authority to perform the requested command or operation.  
    vcap@182b9k5hdli:~$  


As a result, we need a workaround. The only workaround that I could think of was to use the db2move command which I used to use regularly to migrate databases from one OS to another. This command basically exports all tables out into ixf format so they can be imported back into a new database. It is fully automated and extremely easy to use. Please note that db2move does not come with db2 runtime client, it is available only on server editions. You can get a copy of db2 express-C free of charge from here [http://www-01.ibm.com/software/data/db2/express-c/download.html](http://www-01.ibm.com/software/data/db2/express-c/download.html) . As the Bluemix application container restricts to a maximum of 2GB in size, it will take too much space from our container if we are to install a copy of DB2 express-C server. Luckily, we only need 3 files to get the db2move up and running. We will need db2move, db2common.bnd and db2move.bnd. Place db2move in the sqllib/bin directory and 2 bnd files into the sqllib/bnd directory,  we will have a fully working db2move utility.   
Note: db2move utility has been packaged with the DB2climate application, so you don't need to do the above tasks.  
 
Script Name: export_db.rb  
Purpose: export all database tables in ixf format using db2move export command  
Output fie: db_name with .tar.gz extension in the current directory   
Syntax:    `$  export_db.rb db_name`    
Exampe:  `$  export_db.rb SQLDB_001`  
Sample output: `$  SQLDB_001.tar.gz`  


Script Name:  import_db.rb script    
Purpose: import all database tables using db2move import command. It can be used to restore to existing db or clone a new one.    
Syntax:    `$  import_db.rb  db_name  db_backup_file_name`   
Example: `$  import_db.rb SQLDB_001  SQLDB_001.tar.gz`  


## Appendix   DB2climate tips and known issues ##
#### Tips: 

1.Bluemix allows multiple apps bind to the same service and vice versa.  Therefore, DB2climate can be used as a utility app bind to the same SQLDB service that your primary app binds to. As the screen shot depicted below, we have bound the SQLDB_001 instance to both Bluemix101-FF and DB2climate app. In this example, Bluemix101-FF is our  primary app which uses the SQLDB_001 as its backend database whereas DB2climate is our utility app that is used to help us managing the DB instance.

    name  		service   	plan 		 	bound apps
    SQLDB_001 	sqldb 		sqldb_small   	db2climate, Bluemix101-FF

2.When you finishing using the terminal, just shutdown your terminal program by clicking the "x" icon and confirm "OK". By doing this, your tmate session will be left running so you can reconnect to it using the same tmate credentials. If you type "exit" at the Tmate terminal, it will shutdown the Tmate server, as a result you will have to restart the db2climate application which will generate a new tmate credential. On top of that, you will have to re-setup the Dropbox account and re-catalog all the databases again. 
When using the disconnect method, you can reconnect back to the container using the same tmate credential. All changes you made last session remain intact. Effectively resumes from your last session. 

#### Known issues: ####
1. If you  unbind your SQLDB instance from the DB2climate app and then later rebind it, you will no longer be able to run some of the db2 command successfully. While some commands such as "db2 get dbm cfg", "db2 get authorization"  continue to work,  other commands like "db2 list tables" or "db2 select * from ..." will yield error like the sample screen shot below.  
 
    `vcap@182uup7tc8i:~$ db2 list tables`
    `SQL0727N An error occurred during implicit system action type "1".`
    `Information returned for the error includes SQLCODE "-551", SQLSTATE "42501"`
    `and message token "VEGTTEPX|SELECT|SYSCAT.ROUTINES". SQLSTATE=56098`  
    `vcap@182uup7tc8i:~$`

    Because of the above restriction, you should not unbind your SQLDB instance from the DB2climate application at any time. If you accidentally have, the only way to restore your ability to manage your SQLDB instance via DB2climate is to delete your SQLDB instance, re-create a new instance and restore the database from your Dropbox cloud storage backup. 

2.  Occasionally, when you deploy or start the DB2climate app, the tmate server might not get initialized properly and as a result tmate url may not be revealed. If that happens to you, simply stop and restart the DB2climate app should fix it.

        2014-09-15 06:26:14 (1.01 MB/s) - `/app/bin/dropbox.py' saved [111519/111519]  
    	2014/09/15 06:26:17 Starting tmate...  
    	2014/09/15 06:26:17 1000  
    	2014/09/15 06:26:17 1000  


## License ##
Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
