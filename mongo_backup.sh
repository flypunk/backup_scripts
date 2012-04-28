#!/bin/bash
# This script dumps all the mongo DBs on the local host and uploads them
# to an S3 bucket
# See http://www.mongodb.org/display/DOCS/Import+Export+Tools for mongodump options
# Change the variables in ALL_CAPS to match your environment

dest_dir=/tmp
cd $dest_dir
/usr/bin/mongodump 1>/dev/null # Suppress stdout for better cron compatibility

if [ $? -ne 0 ]
    then echo "Dump was not successfull"
    exit 1
fi

dumpname=mongo-`hostname`-`date +%Y-%b-%d`.tgz
tar -czf $dumpname dump
rm -rf dump
    
s3cmd --config=/root/.s3cfg --no-progress put $dumpname s3://backups.YOURCOMPANY.com/
    if [ $? -ne 0 ]
        then echo "Upload to S3 was not successfull"
        exit 1
    fi

rm $dumpname
