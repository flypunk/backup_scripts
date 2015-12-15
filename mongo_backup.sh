#!/bin/bash
# This script dumps all the mongo DBs on the local host and uploads them
# to an object store.
# See http://www.mongodb.org/display/DOCS/Import+Export+Tools for mongodump options
# Change the variables to match your environment

dest_dir=/tmp
dump_type=idftrees
destination=gs://bhs-bhp-backup/mongo/

cd $dest_dir
/usr/bin/mongodump 1>/dev/null # Suppress stdout for better cron compatibility

if [ $? -ne 0 ]
    then echo "Dump was not successfull"
    exit 1
fi

dumpname=$dump_type-`date +%Y-%b-%d`.tgz
tar -czf $dumpname dump
rm -rf dump

destination_type=$(echo $destination | cut -c1-3)

if [ "$destination_type" == "gs:" ]; then
    upload_command="/usr/local/bin/gsutil -q cp $dumpname $destination"
elif [ "$destination_type" == "s3:" ]; then
    upload_command="s3cmd --config=/home/ftapp/.s3cfg --no-progress put $dumpname $destination"
else
    echo "Don't know how to upload to $destination"
    exit 1
fi

$upload_command
if [ $? -ne 0 ]
    then echo "Upload to $destination was not successfull"
    exit 1
fi

rm $dumpname
