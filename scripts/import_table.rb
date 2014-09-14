#!/home/vcap/app/bin/ruby
require 'rubygems'
require 'json'
db_found=0
db_name=""
schema_name=""
import_mode="insert"
db2_serviceName = "sqldb"
json_db2 = JSON.parse(ENV['VCAP_SERVICES'])[db2_serviceName]
total_db2_services=json_db2.count

if (ARGV.length < 2 || ARGV.length > 4)
  usage()
end

if (ARGV.length == 2 && total_db2_services==1) 
  schema_name=ARGV[0]
  table_file_name=ARGV[1]
elsif (ARGV.length == 3 && total_db2_services==1) 
  schema_name=ARGV[0]
  table_file_name=ARGV[1]
  import_mode_index=ARGV[2]
elsif (ARGV.length < 3 && total_db2_services >1) 
  print ("\nMore than 1 db detected, you must specify db_name as first parameter\n")
  usage()
end

if (ARGV.length >= 3)
  db_name=ARGV[0]   
  schema_name=ARGV[1] 
  table_file_name=ARGV[2]
  import_mode_index=ARGV[3]
end

case import_mode_index.to_i
when 1 
  import_mode="insert"
when 2
  import_mode="insert_update"
when 3
  import_mode="replace"
when 4
  import_mode="replace_create"
when 5
  import_mode="create"
end 

if File.file?(table_file_name)==false 
  abort("Error! File name #{table_file_name} not found")
end 

if (total_db2_services == 1 && ARGV.length >=2)  # only one SQLDB bound to the app
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

file_base_name=File.basename(table_file_name)
pos=file_base_name.index('.')
import_format= file_base_name[pos+1..-1]
if (import_format == "csv") 
  import_format="del"
end 
 
table_name=file_base_name[0..pos-1]
system("db_name is #{db_name},  schema_name is #{schema_name},  table_name is #{table_name},  Import_format is #{import_format},  import_mode is #{import_mode}")

if (import_format != "del" && import_format != "ixf")
  abort('supported import_format is "ixf" or "del" ')
end

system("db2 connect to #{database} user #{username} using #{password};db2 'import from #{table_file_name} of #{import_format} messages #{table_name}.msg #{import_mode} into #{schema_name}.#{table_name}'")

BEGIN {
def usage()
  script_name=File.basename(__FILE__)
  print "\nsyntax: #{script_name} [db_name] schema_name table_file_name [import_mode]\n"
  print "db_name:      required if more than one dbs bound to the app\n"
  print "import mode:  1=insert(default), 2=insert_update, 3=replace, 4=replace_create (ixf only), 5=create (ixf only)\n\n"
  exit (1)
end 
}
