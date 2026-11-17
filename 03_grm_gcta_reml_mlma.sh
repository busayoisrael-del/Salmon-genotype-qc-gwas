#!/usr/bin/env bash
# =============================================================================
# 03_gcta_grm_reml_mlma.sh
# Build genomic relationship matrix (GRM), run REML heritability estimation,
# and perform mixed-linear-model association (MLMA) with GCTA.
#
# Prerequisites:
#   - GCTA 1.94+ (gcta64)
#   - Input: finaldata.{bed,bim,fam}
#   - Phenotype file(s) in GCTA format (FID IID phenotype)
# =============================================================================

set -euo pipefail

# ---------- User-configurable variables ----------
BFILE="finaldata"
GRM_OUT="GRM_data"
PHENO_FILE="pheno_positive.txt"   # change as needed
THREADS=10
AUTOSOME_NUM=29                   # Atlantic salmon

echo ">>> Step 1: Build genomic relationship matrix"
gcta64 --bfile ${BFILE} \
       --autosome-num ${AUTOSOME_NUM} \
       --make-grm \
       --out ${GRM_OUT} \
       --thread-num ${THREADS}

echo ">>> Step 2: REML heritability estimation"
gcta64 --reml \
       --grm ${GRM_OUT} \
       --pheno ${PHENO_FILE} \
       --out reml_TRAIT

echo ">>> Step 3: Mixed linear model association (MLMA)"
gcta64 --mlma \
       --bfile ${BFILE} \
       --grm ${GRM_OUT} \
       --autosome-num ${AUTOSOME_NUM} \
       --pheno ${PHENO_FILE} \
       --out gwas \
       > gwas.log 2>&1

echo ">>> Outputs: ${GRM_OUT}.*  reml_TRAIT.*  gwas.*"
echo ">>> Done."
