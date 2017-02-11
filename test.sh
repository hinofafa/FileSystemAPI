#!/bin/bash

# AutoGrader for Assignment 2
# Generate a random file.
# Compute its md5sum
# Run the user program to copy the file
# Compare the md5sum of the file and its copy

userDomain="hk.ust.weiwa"
dummyFile="dummy"
localDir=`pwd`

# Clean up
clean_up() {
	rm -f $dummyFile
	rm -f md5.txt
	hadoop fs -rm -f $dummyFile
}

clean_up
# Generate a random file
head -c 100M < /dev/urandom > $dummyFile
md5sum $dummyFile > md5.txt

rm -f error

# Compile and package to jar
mvn clean package
if [ "$?" -ne 0 ]; then
	echo "[ERROR] mvn clean package UNSUCCESSFUL!" >> error
	clean_up
	exit 1
fi

# Copy the local file to HDFS
hadoop fs -moveFromLocal $dummyFile ./
if [ "$?" -ne 0 ]; then
	echo "[ERROR] Cannot move a test data to HDFS!" >> error
	clean_up
	exit 1
fi

# Run the user program to copy the file from HDFS back to local disk
localCopy="file://$localDir/$dummyFile"
hadoop jar target/FileSystemAPI-1.0-SNAPSHOT.jar $userDomain.CopyFile $dummyFile $localCopy
if [ ! -f $localCopy ]; then
	echo "[ERROR] No file has been copied from HDFS!" >> error
	clean_up
	exit 1
fi

md5sum -c md5.txt
if [ "$?" -ne 0 ]; then
	echo "[ERROR] md5sum check failed!" >> error
	clean_up
	exit 1
fi

clean_up
echo "[SUCCESS]"
exit 0
