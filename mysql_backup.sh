#!/bin/bash
# This script dumps the db schemas you specified and uploads them to an S3 bucket
# Change the variables in ALL_CAPS to match your environment
# See http://dev.mysql.com/doc/refman/5.1/en/mysqldump.html for mysqldump options

dest_dir=/tmp
db='YOUR_FIRST_DB, YOUR_OTHER_DB, YOUR_LAST_DB'

for database in $db ; do
    dumpname=$database-`hostname`-`date +%Y-%b-%d`
    /usr/bin/mysqldump --opt --single-transaction --routines -uMYSQL_USER -pMYSQL_PASSWORD $database | /bin/gzip --rsyncable > $dest_dir/$dumpname.sql.gz
    if [ $? -ne 0 ]
        then echo "Dump was not successfull"
        exit 1
    fi
    
    cd $dest_dir
    s3cmd --config=/root/.s3cfg --no-progress put $dest_dir/$dumpname.sql.gz s3://backups.YOURCOMPANY.com/
    if [ $? -ne 0 ]
        then echo "Upload to S3 was not successfull"
        exit 1
    fi

    rm $dest_dir/$dumpname.sql.gz

done
