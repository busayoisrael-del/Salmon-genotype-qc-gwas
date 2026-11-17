#!/usr/bin/env bash
# =============================================================================
# optional_rename_sample_ids.sh
# Example of how to replace array Sample IDs with animal / phenotype IDs
# using a two-column mapping file.
#
# Mapping file format (phenotype_IDs_clean.txt):
#   AnimalID  ...  SampleID_or_CEL
#   (script uses column 1 as new ID and column 5 as old ID)
#
# Adjust the column numbers if your mapping file has a different layout.
# =============================================================================

set -euo pipefail

MAP_FILE="phenotype_IDs_clean.txt"
PED_IN="raw_snp_genotype_file.ped"   # change to your actual .ped
PED_OUT="my_snpgenotype_file.ped"

awk 'NR==1 {next}                          # skip header of mapping file
     FNR==NR {map[$5] = $1; next}          # build SampleID → AnimalID map
     {
         raw_id = $1
         sub(/\.CEL$/, "", raw_id)         # strip .CEL suffix if present
         if (raw_id in map) {
             $1 = map[raw_id]
             $2 = map[raw_id]
         }
         print $0
     }' "${MAP_FILE}" "${PED_IN}" > "${PED_OUT}"

echo ">>> Renamed PED written to ${PED_OUT}"
