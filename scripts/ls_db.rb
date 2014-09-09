#!/home/vcap/app/bin/ruby
require 'rubygems'
require 'json'
require 'text-table'

db_info=Array.new{Array.new(7)}
db_info[0]=["db_name","db_label","host","username","password","database_id","db_port"]
db2_serviceName = "sqldb"
json_db2 = JSON.parse(ENV['VCAP_SERVICES'])[db2_serviceName]
total_db2_services=json_db2.count
for i in 0..total_db2_services-1
  db2_name=json_db2[i]["name"]
  db2_label=json_db2[i]["label"]
  credentials = json_db2[i]["credentials"]
  host = credentials["host"]
  username = credentials["username"]
  password = credentials["password"]
  database = credentials["db"]
  db2_port = credentials["port"]
  db_info[i+1]=[db2_name,db2_label,host,username,password,database,db2_port]
end
puts db_info.to_table(:first_row_is_head => true)