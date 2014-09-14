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

## What can you do with DB2climate##
Current Bluemix SQLDB Managed Data Web Console suffers a number of limitations.

1. Not able to import/load a file with IXF format to database
[https://developer.ibm.com/answers/questions/21537/is-it-possible-to-import-ixf-data-files-to-sqldb-tables/](https://developer.ibm.com/answers/questions/21537/is-it-possible-to-import-ixf-data-files-to-sqldb-tables/)
2. The SQLDB console does not have the export function.
[https://developer.ibm.com/answers/questions/20227/is-that-possible-to-download-data-or-table-ddl-from-sqldb-console/](https://developer.ibm.com/answers/questions/20227/is-that-possible-to-download-data-or-table-ddl-from-sqldb-console/)
3. Not able to migrate data between SQLDB instances using backup image
[https://developer.ibm.com/answers/questions/21480/migrate-data-between-sqldb-instance-using-backup-image/](https://developer.ibm.com/answers/questions/21480/migrate-data-between-sqldb-instance-using-backup-image/)
4. Not able to add non-ephemeral disk space to Bluemix (Bluemix restriction)
[https://developer.ibm.com/answers/questions/21000/adding-normal-disk-space-to-a-bluemix-app/](https://developer.ibm.com/answers/questions/21000/adding-normal-disk-space-to-a-bluemix-app/)
5. Not able to sync data to SQLDB (Bluemix restriction)
[https://developer.ibm.com/answers/questions/20958/sync-data-to-bluemix-sqldb/](https://developer.ibm.com/answers/questions/20958/sync-data-to-bluemix-sqldb/)

DB2climate is designed to address these issues. It allows you to open a ssh connection to the application container which has DB2 runtime client, Dropbox CLI and API client preloaded and configured, therefore you can run all supported db2 commands against your SQLDBs and move data in and out of Bluemix using Dropbox cloud storage. 

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

3. Create a git clone of this repository ...

        git clone https://github.com/iicsydney601/bluemix-db2-cli-mate.git
                                  or 
        git clone https://hub.jazz.net/git/felixf/bluemix-db2-cli-mate 

4. Navigate to the clone application directory.  
   `cd bluemix-db2-cli-mate`
    
5. Optionally, update the **`dropbox_api_keys.txt`** file with appropriate **App key** and **App secret**. By doing this before deployment, your keys setting is stored as part of droplet so you don't have re-enter each time the application restarts. If you choose not to do so at this stage, the first time you run the **dropbox-api** command you will be prompted to enter the keys. However, your keys setting can not survive the application restart.   

6.  From the cloned db2climate app directory, push the app without starting (**--no-start**) flag so that we can bind our SQLDB service before starting it.  

    if you are using cf cli v6.3 or above, run the command below.  
    `usage:   cf push APP [--no-start] --random-route`  
    `example: cf push db2climate --no-start --random-route`    

    If you are using an older version of cf cli, you will have to create a unique host/route during the push.  
   `usage:  cf push APP [--no-start] -n unique_host`  
  `example: cf push db2climate --no-start -n db2climate-FF`   

7.  Bind the SQLDB service to the new app  

     `usage:  cf bind-service APP SERVICE_INSTANCE_NAME`      
   `example: cf bind-service db2climate SQLDB_001`


8.  Start the app  
   `usage:   cf start APP`    
   `example: cf start db2climate`

Note: The starting process involves downloading and installing a number of packages. This includes Ruby runtime, DB2 v9.7 runtime client, Dropbox Linux client, Dropbox API client and tmate/tmux server. The whole package is nearly 400MB in size and it may take few minutes before the application fully up and running. It is normal to see multiple instances of messages "`0 of 1 instances running, 1 starting`" showing on your screen. Please be patient.

    Using release configuration from last framework (Ruby/Rack).
    -----> Uploading droplet (455M)
    
    0 of 1 instances running, 1 starting
    0 of 1 instances running, 1 starting
    0 of 1 instances running, 1 starting
    0 of 1 instances running, 1 starting
    0 of 1 instances running, 1 starting
    0 of 1 instances running, 1 starting
    0 of 1 instances running, 1 starting
    1 of 1 instances running
    
    App started
    
    Showing health and status for app db2climate in org felixf@au1.ibm.com / space test as felixf@au1.ibm.com...
    OK
    
    requested state: started
    instances: 1/1
    usage: 256M x 1 instances
    urls: db2climate-sludgier-sunhat.mybluemix.net
    
     state sincecpumemory  disk
    #0   running   2014-09-09 05:38:20 PM   0.0%   52.9M of 256M   360.8M of 2G


That's it! DB2climate has now successfully deployed to the Bluemix cloud.


## ssh into DB2climate app container ##
After the appliction is up and running, issue 
    
`cf files db2climate logs/stderr.log`

The last 4 lines of stderr.log should look like this

    2014/09/08 12:04:06 Starting tmate...
    2014/09/08 12:04:06 1000
    2014/09/08 12:04:06 1000
    2014/09/08 12:04:07 U67RHUFbnmx2gpD41JIaRLVxw@sf.tmate.io

The connection URL is at the last line of the log. The two "1000" are the height and width of your terminal followed by the connection URL.  

If you are using a Windows PC, you will need a cygwin like terminal program installed. I personally use **babun** windows shell which you can download it from [https://github.com/babun/babun](https://github.com/babun/babun) 

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

## Setup Dropbox as non-ephemeral storage ##

As Bluemix warden container does not support persistent storage at the moment. As a result, all changes written to the container disk are lost if the application is stopped or restarted.  Therefore, we need some kind of persistent storage so we can store our database backups or exported tables.  In this article, I will show you how to use Dropbox as our non-ephemeral storage to get your data in and out of Bluemix. This is not the best solution but until Bluemix supports SoftLayer's Object Storage, it remains a decent workaround.

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
DB2climate also come with a copy of Dropbox core API client installed. To use it, just run "**dropbox-api**" command. If you did not update the "`dropbox_api_keys.txt`" file before pushing the application, you will be prompted to enter the api keys. Next you need to select the appropriate "`Input Access Type`", you must match the input access type to your api app's "`Permission type`" when the app was created.  Then, cut and paste the URL on the screen to a browser; logon to your Dropbox account and click "`Allow`". Once you have done that, return to your ssh console and press enter to finish the setup.

    vcap@182bbgv126r:~$ dropbox-api  
    Please Input API Key: do9qmztlbd0oj9o  
    Please Input API Secret: fdt8xt7cm6gmfxp  
    Please Input Access type  
    a ... App folder - Your app only needs access to a single folder within the user's Dropbox 
    f ... Full Dropbox - Your app needs access to the user's entire Dropbox  
    [a or f]: a  
    To link this computer to a dropbox account, visit the following url, login in and click the Allow button 
 
    URL: https://www.dropbox.com/1/oauth/authorize?oauth_token=9L1reF1b1ZnC6r0V&oauth_callback=  

    Link completed==>?  
   


Congratulations, you have just successfully link your app container to your Dropbox account. The advantage of using Dropbox API over Dropbox Linux client is that Dropbox API does not synchronize with cloud storage automatically therefore you are safe to use your existing Dropbox account. Run "`dropbox.api help`" to get a list of available commands. 
For instance, to upload the local.tar file from the container to the Dropbox's root directory, we would issue: 

	$ 	dropbox-api put local.tar dropbox:/ 

To list all the files in our dropbox account, we would issue:

	$	dropbox-api ls

## Use DB2climate as a DB2 client   ##

You can run all supported db2 commands against your SQLDBs straight away after ssh into the warden container. All TCPIP nodes and databases would have automatically cataloged for you. In addition, in order to avoid users to keep referring to the VCAP_SERVICE file for db credentials, a number of scripts have been developed to help you manage your database(s) with ease. 

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

Script Name: import_table.rb  
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




## License ##
Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
