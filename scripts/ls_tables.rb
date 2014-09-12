#!/home/vcap/app/bin/ruby
require 'rubygems'
require 'json'
db_found=0
script_name=File.basename(__FILE__)
db2_serviceName = "sqldb"
db_name=""
schema_name=""
app_port = ENV['VCAP_APP_PORT']
jsondb_app = JSON.parse(ENV['VCAP_APPLICATION'])
json_db2 = JSON.parse(ENV['VCAP_SERVICES'])[db2_serviceName]
total_db2_services=json_db2.count

if (ARGV.length < 1 || ARGV.length > 2)
  usage()
end

if (ARGV.length == 1 && total_db2_services==1) 
  schema_name=ARGV[0] 
elsif (ARGV.length == 1 && total_db2_services >1) 
  print ("\nMore than 1 db detected, you must specify db_name as first parameter\n")
  usage()
end

if (ARGV.length == 2)
  db_name=ARGV[0]   
  schema_name=ARGV[1] 
end

if (total_db2_services == 1 && ARGV.length==1)  # only one SQLDB bound to the app
  db_found=1
  db_name=json_db2[0]["name"]
  credentials = json_db2[0]["credentials"]
  host = credentials["host"]
  username = credentials["username"]
  password = credentials["password"]
  database = credentials["db"]
  db2_port = credentials["port"]
end 

if (total_db2_services > 1 || ARGV.length > 1)  # more than  one SQLDBs bound to the app
  for i in 0..total_db2_services-1
    db2_name=json_db2[i]["name"]
    if (db2_name == db_name)
      db_found=1
      credentials = json_db2[i]["credentials"]
      host = credentials["host"]
      username = credentials["username"]
      password = credentials["password"]
      database = credentials["db"]
      db2_port = credentials["port"]
    end
  end 
end 


if (db_found==1)
  system("db2 connect to #{database} user #{username} using #{password};db2 'list tables for schema #{schema_name}'")
else
  abort("\nError! db_name not found\n\n")
end


BEGIN {
def usage()
  script_name=File.basename(__FILE__)
  print "\nsyntax: #{script_name} [db_name] schema_name\n"
  print "db_name:    required if more than one dbs bound to the app\n"
  exit (1)
end 
}
