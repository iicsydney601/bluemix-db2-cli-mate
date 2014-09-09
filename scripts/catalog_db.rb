#!/home/vcap/app/bin/ruby
require 'rubygems'
require 'json'

db_found=0
db_name=ARGV[0] || abort("syntax: #{__FILE__} db_Name")
db2_serviceName = "sqldb"
json_db2 = JSON.parse(ENV['VCAP_SERVICES'])[db2_serviceName]
total_db2_services=json_db2.count
node_num=1 
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
    node_num=i+1
  end
end 
if (db_found==1)
  system("db2 catalog tcpip node db2node#{node_num} Remote #{host} SERVER #{db2_port}")
  system("db2 terminate")
  system("db2 catalog db #{database} at node db2node#{node_num}")
  system("db2 terminate")
else
  puts("\nError! db_name not found\n\n")
  exit 1
end 