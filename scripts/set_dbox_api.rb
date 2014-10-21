#!/home/vcap/app/bin/ruby
require 'rubygems'
require 'json'

db_found=0
db_name=""
db2_serviceName = "sqldb"
json_db2 = JSON.parse(ENV['VCAP_SERVICES'])[db2_serviceName]
total_db2_services=json_db2.count
dbox_tablename="DROPBOX.API_SETTING"
dbox_api_sql_fname="insert_dbox_api.sql"
api_key=""
api_secret=""
access_type=""

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

print "Please enter your Dropbox API key: "
api_key=gets.chomp

print "Please enter your Dropbox API secret: "
api_secret=gets.chomp

while  !["a", "f"].include?(access_type.to_s.downcase)
  print "Please enter your app's access type:\n"
  print " a ... App folder - Your app only needs access to a single folder within the user's Dropbox \n"
  print " f ... Full Dropbox - Your app needs access to the user's entire Dropbox \n"
  print " [a or f]: "
  access_type=gets.chomp
end
sql_1="DROP TABLE #{dbox_tablename}"
sql_2=" CREATE TABLE #{dbox_tablename} (API_KEY VARCHAR (100) FOR BIT DATA NOT NULL, API_SECRET VARCHAR (100) FOR BIT DATA NOT NULL, APP_TYPE CHAR(1)) ORGANIZE BY ROW DATA CAPTURE NONE COMPRESS NO"
sql_3= "INSERT INTO #{dbox_tablename} VALUES (ENCRYPT('#{api_key}','#{db_name}'), ENCRYPT('#{api_secret}','#{db_name}'), '#{access_type}')"

system("db2 connect to #{database} user #{username} using #{password} >/dev/null; db2 \"#{sql_1}\" >/dev/null")
system("db2 connect to #{database} user #{username} using #{password} >/dev/null; db2 \"#{sql_2}\" >/dev/null")
system("db2 connect to #{database} user #{username} using #{password} >/dev/null; db2 \"#{sql_3}\"")
