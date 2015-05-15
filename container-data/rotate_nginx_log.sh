#!/bin/bash
# <https://gist.github.com/allex/10360845>

# Set variable
logs_path="/var/log/nginx/"
old_logs_path=${logs_path}/old
nginx_pid=`cat /var/run/nginx.pid`

time_stamp=`date -d "yesterday" +%Y-%m-%d`

mkdir -p ${old_logs_path}

# Main
for file in `ls $logs_path | grep log$ | grep -v '^20'`
do
    if [ ! -f ${old_logs_path}/${time_stamp}_$file ]
    then
        dst_file="${old_logs_path}/${time_stamp}_$file"
    else
        dst_file="${old_logs_path}/${time_stamp}_$file.$$"
    fi
    mv $logs_path/$file $dst_file
    gzip -f $dst_file  # do something with access.log.0
done

kill -USR1 $nginx_pid