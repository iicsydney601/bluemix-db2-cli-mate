#!/home/vcap/app/bin/ruby
require 'rubygems'
require 'json'
script_name=File.basename(__FILE__)
db_found=0
db_name=""
schema_name=""
table_name=""
export_format=""
db2_serviceName = "sqldb"
json_db2 = JSON.parse(ENV['VCAP_SERVICES'])[db2_serviceName]
total_db2_services=json_db2.count

if (ARGV.length < 3 || ARGV.length > 4)
  usage()
end

if (ARGV.length == 3 && total_db2_services==1) 
  schema_name=ARGV[0]
  table_name=ARGV[1]
  export_format=ARGV[2]
elsif (ARGV.length < 3 && total_db2_services >1) 
  print ("\nMore than 1 db detected, you must specify db_name as first parameter\n")
  usage()
end

if (ARGV.length >= 3 && total_db2_services >1)
  db_name=ARGV[0]   
  schema_name=ARGV[1] 
  table_name=ARGV[2]
  export_format=ARGV[3]
end

if (total_db2_services == 1 && ARGV.length==3)  # only one SQLDB bound to the app
  db_found=1
  db_name=json_db2[0]["name"]
  credentials = json_db2[0]["credentials"]
  host = credentials["host"]
  username = credentials["username"]
  password = credentials["password"]
  database = credentials["db"]
  db2_port = credentials["port"]
end 

if (total_db2_services > 1 && ARGV.length >= 3)  # more than  one SQLDBs bound to the app
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

if (db_found !=1)
  abort("\nError! db_name not found\n\n")
end 

if (export_format != "del" && export_format != "ixf")
  abort('supported export_format is "ixf" or "del" ')
end

puts("db_name is #{db_name},  schema_name is #{schema_name},  table_name is #{table_name},  export_format is #{export_format}")

system("db2 connect to #{database} user #{username} using #{password};db2 'export to #{table_name}.#{export_format} of #{export_format} messages #{table_name}.msg select * from #{schema_name}.#{table_name}'")

BEGIN {
def usage()
  script_name=File.basename(__FILE__)
  print "\nsyntax: #{script_name} [db_name] schema_name table_Name export_format\n"
  print "db_name:        required if more than one dbs bound to the app\n"
  print "export_format:  del or ixf \n\n"
  exit (1)
end 
}