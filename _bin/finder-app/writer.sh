#!/bin/sh
# Tester script for assignment 1 and assignment 2
# Author: Arnaud Simo
# 24.11.2025
# Ce programme ecrit une chaine de charactere dans un fichier texte.


#set -e
#set -u

##arguments
writefile="$1"
writestr="$2"

 
# Check argument count
if [ $# -lt 2 ]  
then	
	echo "Error::no arguments has been specify."
	echo "      ./writer.sh  /dir1/subdir1/text.txt  EnterAstring"
	exit 1
fi

#extract dir from file  path
dir_path=$(dirname "$writefile")

# echo "--DEBUG--"
# echo "output=dir_path=$dir_path"
# echo "output2=writefile=$writefile"
# echo "---------"

if [ ! -d "$dir_path" ]
then 
	# create dir path if does not exist
	mkdir -p   "$dir_path"
fi

# write text into file (overwrite)
echo "$writestr" >  "$writefile"
