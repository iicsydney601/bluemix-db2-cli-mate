export LD_LIBRARY_PATH=/app/lib
export TERM=screen-256color
export PATH=$PATH:$HOME/bin
ssh-keygen -q -t rsa -f /home/vcap/.ssh/id_rsa -N ""
