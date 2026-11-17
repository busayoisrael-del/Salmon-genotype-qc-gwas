#!/usr/bin/env bash
# =============================================================================
# 02_remove_duplicates_and_qc.sh
# Detect and remove duplicated samples via IBD, then apply standard QC filters.
#
# Prerequisites:
#   - PLINK 1.9
#   - Input: file1_clean.{bed,bim,fam}  (from 01_prepare_plink_fileset.sh)
# =============================================================================

set -euo pipefail

# ---------- User-configurable variables ----------
BFILE_IN="file1_clean"
BFILE_OUT="finaldata"
IBD_THR=0.90          # IBD threshold for calling duplicates
GENO=0.05             # max missingness per SNP
MIND=0.05             # max missingness per individual
HWE=1e-6              # Hardy-Weinberg equilibrium p-value
MAF=0.05              # minor allele frequency
CHR_SET=29

echo ">>> Step 1: Estimate pairwise IBD"
plink --bfile ${BFILE_IN} \
      --genome \
      --chr-set ${CHR_SET} \
      --out tempdata

echo ">>> Step 2: Identify sample pairs exceeding IBD threshold (${IBD_THR})"
# Print both members of every high-IBD pair
gawk -v IBD_thr=${IBD_THR} '
    NR > 1 {
        if ($10 > IBD_thr) {
            print $1, $2
            print $3, $4
        }
    }
' tempdata.genome | sort | uniq > ID_to_remove.txt

echo ">>> Samples flagged for removal:"
cat ID_to_remove.txt || echo "(none)"

echo ">>> Step 3: Apply QC filters and remove flagged samples"
plink --bfile ${BFILE_IN} \
      --chr-set ${CHR_SET} \
      --remove ID_to_remove.txt \
      --geno ${GENO} \
      --mind ${MIND} \
      --hwe ${HWE} \
      --maf ${MAF} \
      --nonfounders \
      --make-bed \
      --out ${BFILE_OUT}

echo ">>> Final QC fileset: ${BFILE_OUT}.{bed,bim,fam}"
echo ">>> Done."
