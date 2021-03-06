#!/home/vcap/app/bin/ruby
require 'rubygems'
require 'json'

db_found=0
script_name=File.basename(__FILE__)
db_name=ARGV[0] || abort("syntax: #{script_name} db_Name")
db2_serviceName = "sqldb"
json_db2 = JSON.parse(ENV['VCAP_SERVICES'])[db2_serviceName]
total_db2_services=json_db2.count
for i in 0..total_db2_services-1
  db2_name=json_db2[i]["name"]
  db2_label=json_db2[i]["label"]

  if db2_name == ARGV[0]
    db_found=1
    credentials = json_db2[i]["credentials"]
    host = credentials["host"]
    username = credentials["username"]
    password = credentials["password"]
    database = credentials["db"]
    db2_port = credentials["port"]
  end
end 

if (db_found==1)
  db_name=db_name.gsub(/\s+/, "_")  # repalces all whilte spaces with underscore signs
  system("mkdir #{db_name}\;cd #{db_name}\;db2move #{database} export -u #{username} -p #{password} ")
  system("tar zcvf #{db_name}.tar.gz #{db_name} ")
else
  puts("\nError! db_name not found\n\n")
  exit 1
end 
