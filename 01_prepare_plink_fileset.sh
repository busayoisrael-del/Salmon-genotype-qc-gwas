#!/usr/bin/env bash
# =============================================================================
# 01_prepare_plink_fileset.sh
# Convert Axiom-style genotype files into a clean PLINK binary fileset
# and correct chromosome coding for Atlantic salmon (ssa → numeric).
#
# Prerequisites:
#   - PLINK 1.9 (or 2.0 compatible flags)
#   - Input files:
#       new_phr_call_cod.ped
#       new_phr_call_cod.map
# =============================================================================

set -euo pipefail

# ---------- User-configurable variables ----------
PREFIX_IN="new_phr_call_cod"   # base name of the Axiom export
PREFIX_OUT="file1"             # intermediate PLINK prefix
CHR_SET=29                     # Atlantic salmon autosomes + sex chromosomes

echo ">>> Step 1: Clean the .map file (remove header lines starting with ##)"
awk '!/^##/' "${PREFIX_IN}.map" > clean_file.map

echo ">>> Step 2: Add the six standard pedigree columns to the .ped file"
# FID = SampleID, IID = SampleID, Father=0, Mother=0, Sex=0, Phenotype=-9
awk '{
    printf "%s %s 0 0 0 -9", $1, $1
    for (i = 2; i <= NF; i++) printf " %s", $i
    printf "\n"
}' "${PREFIX_IN}.ped" > clean_file.ped

echo ">>> Step 3: Create initial binary fileset"
plink --file clean_file \
      --chr-set ${CHR_SET} \
      --allow-extra-chr \
      --make-bed \
      --out ${PREFIX_OUT}

echo ">>> Step 4: Build SNP → numeric chromosome map from the .bim file"
# Strip leading "ssa0" or "ssa" so that ssa01 → 1, ssa29 → 29, etc.
awk '{
    chr = $1
    gsub(/^ssa0/, "", chr)
    gsub(/^ssa/,  "", chr)
    print $2, chr
}' ${PREFIX_OUT}.bim > snp_chr_map.txt

echo ">>> Step 5: Update chromosome codes and exclude mitochondrial chromosome"
plink --bfile ${PREFIX_OUT} \
      --chr-set ${CHR_SET} \
      --allow-extra-chr \
      --not-chr mit \
      --update-chr snp_chr_map.txt \
      --make-bed \
      --out ${PREFIX_OUT}_clean

echo ">>> Step 6: Quick sanity check – chromosome counts"
awk '{print $1}' ${PREFIX_OUT}_clean.bim | sort | uniq -c

echo ">>> Intermediate fileset ready: ${PREFIX_OUT}_clean.{bed,bim,fam}"
echo ">>> Done."
