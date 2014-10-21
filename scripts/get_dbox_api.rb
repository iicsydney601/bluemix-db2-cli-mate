#!/home/vcap/app/bin/ruby
require 'rubygems'
require 'json'

db_found=0
db_name=""
db2_serviceName = "sqldb"
json_db2 = JSON.parse(ENV['VCAP_SERVICES'])[db2_serviceName]
total_db2_services=json_db2.count
dbox_tablename="DROPBOX.API_SETTING"
get_key=0
get_secret=0
get_type=0
get_all=0

if (total_db2_services > 0 )  # at least one SQLDB bound to the app
  db_found=1
  db_name=json_db2[0]["name"]
  credentials = json_db2[0]["credentials"]
  host = credentials["host"]
  username = credentials["username"]
  password = credentials["password"]
  database = credentials["db"]
  db2_port = credentials["port"]
end 

if (db_found !=1)
  abort("\nError! db_name not found\n\n")
end

system("db2 connect to #{database} user #{username} using #{password} >/dev/null; db2 list tables for schema Dropbox >/dev/null")
if ($? !=0)
  print("Error! You have not stored the Dropbox API settings in SQLDB, please run \"set_dbox_key.rb\" script first\n")
  exit 1
end 

case ARGV[0].to_s.downcase 
when "k"
  get_key=1
when "s"
  get_secret=1
when "t"
  get_type=1
when "a"
  get_all=1
end 

if (get_key==1) 
  sql_statement="SELECT(DECRYPT_CHAR(API_KEY,'#{db_name}')) FROM #{dbox_tablename}"
  result=`db2 connect to #{database} user #{username} using #{password} >/dev/null; db2 -x \"#{sql_statement}\"`
end 

if (get_secret==1) 
  sql_statement="SELECT(DECRYPT_CHAR(API_SECRET,'#{db_name}')) FROM #{dbox_tablename}"
  result=`db2 connect to #{database} user #{username} using #{password} >/dev/null; db2 -x \"#{sql_statement}\"`
end 

if (get_type==1) 
  sql_statement="SELECT APP_TYPE FROM #{dbox_tablename}"
  result=`db2 connect to #{database} user #{username} using #{password} >/dev/null; db2 -x \"#{sql_statement}\"`
end 

if (get_all==1) 
  sql_statement="SELECT (DECRYPT_CHAR(API_KEY,'#{db_name}')), (DECRYPT_CHAR(API_SECRET,'#{db_name}')), APP_TYPE FROM #{dbox_tablename}"
  result=`db2 connect to #{database} user #{username} using #{password} >/dev/null; db2 -x \"#{sql_statement}\"`
end 

print result  