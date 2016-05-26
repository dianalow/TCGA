#!/bin/bash

usage="
####################################################
make_TCGA_matrix.sh
-- script to generate expression matrix from 
   TCGA Level 3 expression data

AUTHOR: Diana Low
SITE  : http://github.com/dianalow
LAST UPDATED: May 26 2016
####################################################

$(basename "$0") [-h] [-t file_identifier] [-n name_mapping] [-m output_filename] 

where:
    -h  show this help text

    -t  type of expression filetype you want to concatenate eg. rsem.genes.normalized_results

    -n  space-separated 12-letter patient_barcode_uid with corresponding filename
        in the form of TCGA-XX-XXXX<space>filename
        eg. TCGA-DD-AACO<space>unc.edu.032ec32d-66ca-4792-9132-2e61d918c3c2.2633853.rsem.genes.results
        * can be obtained from TCGA's file_manifest.txt

    -m  output file for matrix to be written to
"
tflag=false
nflag=false
mflag=false
OPTIND=1

while getopts ':t:n:m:h' option; do
  case "$option" in
    t) echo "-t argument: $OPTARG"
       file_identifier=$OPTARG
       tflag=true
       ;;
    n) echo "-n argument: $OPTARG"
       name_mapper=$OPTARG
       nflag=true
       ;;
    m) echo "-m argument: $OPTARG"
       matrix_file=$OPTARG
       mflag=true
       ;;
    h) echo "$usage"
       exit 0
       ;;
   \?) echo "Invalid option: -$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
    :) echo "Option -$OPTARG requires an argument." >&2
       echo "$usage" >&2
       exit 1
       ;;

  esac
done
shift $((OPTIND - 1))

# check if all parameters have been set
if ! $tflag | $nflag | $mflag
then
    echo "-t, -m and -n are all required arguments." >&2
    echo "$usage"
    exit 1
fi

# check if file name is valid
if [ ! -f $name_mapper ]; then
    echo "File $name_mapper not found!"
    exit 1
fi

# make array for name mapping
declare -A myArray
filename=$name_mapper
while read -r line
do
    name="$line"
    name=($name)
    myArray[${name[1]}]=${name[0]}
done < "$filename"

# preparing counter, temporary files
counter=0
currdir=$(pwd)
tmpdir=$(mktemp -d -p $currdir)
filenames_file=$(mktemp -p $tmpdir)
echo 'gene' >> $filenames_file

for thefile in $(ls -1 *$file_identifier*) 
do
   echo "File #" $counter
   if [ $counter -eq 0 ]
   then
       file1=$thefile
       echo ${myArray[$file1]} >> $filenames_file
   else
       tmpfile=$(mktemp -p $tmpdir)
       file2=$thefile
       echo ${myArray[$file2]} >> $filenames_file
       join -j 1 $file1 $file2 > $tmpfile
       file1=$tmpfile
   fi
   let counter=counter+1
done

# cleanup
sed -i '1d' $file1
fheader=$(paste -sd" " $filenames_file)
echo $fheader | cat - $file1 > $matrix_file
rm -R $tmpdir/*
rmdir $tmpdir
