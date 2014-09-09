#!/home/vcap/app/bin/ruby
require 'rubygems'
require 'json'

db_found=0
db_name=ARGV[0] || abort("syntax: #{__FILE__} db_Name")
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
  p "Downloading sample sql scripts ..."
  system("wget https://dl.dropboxusercontent.com/u/92217296/db2_client/sample_sql/cr_country.sql -O cr_country.sql")
  system("wget https://dl.dropboxusercontent.com/u/92217296/db2_client/sample_sql/cr_city.sql -O cr_city.sql")
  system("wget https://dl.dropboxusercontent.com/u/92217296/db2_client/sample_sql/insert_country.sql -O insert_country.sql")
  system("wget https://dl.dropboxusercontent.com/u/92217296/db2_client/sample_sql/insert_city.sql -O insert_city.sql")
  p "Creating sample tables..."
  system(". /home/vcap/.profile; db2 connect to #{database} user #{username} using #{password}; db2 -tvf cr_country.sql; db2 -tvf cr_city.sql;db2 -tvf insert_country.sql;db2 -tvf insert_city.sql")
else
  puts("\nError! db_name not found\n\n")
  exit 1
end 
  
