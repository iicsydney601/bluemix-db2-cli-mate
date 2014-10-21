# db2climate v2.1 felixf@au1.ibm.com  06/10/2014
require 'rubygems'
require 'sinatra'
require 'json'

fname = "catalog_db.sh"
fcd = File.open(fname, "w")  
db2_serviceName = "sqldb"
json_db2 = JSON.parse(ENV['VCAP_SERVICES'])[db2_serviceName]
total_db2_services=json_db2.count
node_num=0
fcd.puts("#!/bin/bash")
fcd.puts(". /home/vcap/.profile")
for i in 0..total_db2_services-1
  db2_name=json_db2[i]["name"]
  db2_label=json_db2[i]["label"]
  credentials = json_db2[i]["credentials"]
  host = credentials["host"]
  username = credentials["username"]
  password = credentials["password"]
  database = credentials["db"]
  db2_port = credentials["port"]
  node_num=i+1
  fcd.puts("db2 catalog tcpip node db2node#{node_num} Remote #{host} SERVER #{db2_port}")
  fcd.puts("db2 terminate")
  fcd.puts("db2 catalog db #{database} at node db2node#{node_num}")
  fcd.puts("db2 terminate")
end
fcd.close
system("echo Installing DB2 Client...")
system("rtcl/db2_install")
system("echo clean up installation files...")
system("rm v9.7fp9a_linuxx64_rtcl.tar.gz")
system("rm -fr rtcl")
system("rm dropbox-lnx.x86_64-2.10.28.tar.gz")
system("rm local.tar.gz")
system("mv /app/scripts/*.rb /app/bin") 
system("Install db2move command")
system("wget https://dl.dropboxusercontent.com/u/92217296/db2_client/db2move -O /home/vcap/sqllib/bin/db2move")
system("chmod 755 /home/vcap/sqllib/bin/db2move")
system("wget https://dl.dropboxusercontent.com/u/92217296/db2_client/db2move.bnd -O /home/vcap/sqllib/bnd/db2move.bnd")
system("wget https://dl.dropboxusercontent.com/u/92217296/db2_client/db2common.bnd -O /home/vcap/sqllib/bnd/db2common.bnd")
system("echo Install Dropbox client...")
system("wget https://dl.dropboxusercontent.com/u/92217296/dropbox/dropbox.py -O /app/bin/dropbox.py")
system("chmod 755 /app/bin/dropbox.py")
system("echo Install Tmate...")
system("tar xf tmate.tar --strip-components=1")
system("rm tmate.tar")
system("echo Install Dropbox API client...")
system("ln -s /app/local/bin/dropbox-api /app/bin/dropbox-api")
system("chmod 755 /app/bin/* ")
system("chmod 755 #{fname}")
system("/app/#{fname}")
system("/app/bin/launch 2>/home/vcap/logs/tmate.log")