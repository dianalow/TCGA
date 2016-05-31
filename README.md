# TCGA
scripts to process files downloaded from TCGA

```
####################################################
make_TCGA_matrix.sh
-- script to generate expression matrix from 
   TCGA Level 3 expression data

AUTHOR: Diana Low
SITE  : http://github.com/dianalow
LAST UPDATED: May 26 2016
####################################################

make_TCGA_matrix.sh [-h] [-t file_identifier] [-n name_mapping] [-m output_filename] [-s]

where:
    -h  show this help text

    -t  type of expression filetype you want to concatenate eg. rsem.genes.normalized_results

    -n  space-separated 12-letter patient_barcode_uid with corresponding filename
        in the form of TCGA-XX-XXXX<space>filename
        eg. TCGA-DD-AACO<space>unc.edu.032ec32d-66ca-4792-9132-2e61d918c3c2.2633853.rsem.genes.results
        * can be obtained from TCGA's file_manifest.txt

    -m  output file for matrix to be written to

    -s  sort files before concatenation; will increase processing time

```
Tested and works on LIHC dataset. More specific examples to follow.
