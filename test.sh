#!/bin/bash

# AutoGrader for Assignment 2
# Generate a random file.
# Compute its md5sum
# Run the user program to copy the file
# Compare the md5sum of the file and its copy

# Generate a random file
userDomain="hk.ust.weiwa"
dummyFile="dummy"
head -c 10M < /dev/urandom > $dummyFile
md5sum $dummyFile > md5.txt

maven=`mvn clean package`
if [ "$?" -ne 0 ]; then
	echo "[ERROR] mvn clean package UNSUCCESSFUL!" >> error
	echo "" >> error
	echo $maven >> error
	exit 1
fi

# Copy the local file to HDFS
hdfs=`hadoop fs -moveFromLocal $dummyFile ./`
if [ "$?" -ne 0 ]; then
	echo "[ERROR] Cannot move a file to HDFS!" >> error
	echo "" >> error
	echo $hdfs >> error
	exit 1
fi

# Run the user program to copy the file from HDFS back to local disk
hadoop=`hadoop jar target/FileSystemAPI-1.0-SNAPSHOT.jar $userDomain.CopyFile $dummyFile $dummyFile`
if [ ! -f $dummyFile ]; then
	echo "[ERROR] Copy from HDFS failed!" >> error
	echo "" >> error
	echo $hadoop >> error
	exit 1
fi

md5sum -c md5.txt
if [ "$?" -ne 0 ]; then
	echo "[ERROR] Faild to pass the md5sum check!" >> error
	exit 1
fi

rm -f $dummyFile
echo "[SUCCESS]"