#!/usr/bin/env bash
# =============================================================================
# 05_mlma_with_pcs.sh
# Extract the first N principal components as quantitative covariates and
# re-run MLMA with those covariates.
#
# Prerequisites:
#   - GCTA
#   - pca_results.eigenvec (from 04_pca.sh)
#   - finaldata + GRM_data already exist
# =============================================================================

set -euo pipefail

# ---------- User-configurable variables ----------
NPCS=4                            # number of PCs to use as covariates
PHENO_FILE="full_phenotype_LOD.txt"
OUT_PREFIX="gwas_LODfull_co"
BFILE="finaldata"
GRM="GRM_data"
AUTOSOME_NUM=29

echo ">>> Step 1: Extract FID, IID and the first ${NPCS} PCs"
# Columns: 1=FID, 2=IID, 3=PC1, 4=PC2, ...
awk -v n=${NPCS} '{
    printf "%s %s", $1, $2
    for (i = 3; i <= 2 + n; i++) printf " %s", $i
    printf "\n"
}' pca_results.eigenvec > gcta_pc${NPCS}_covar.txt

echo ">>> Covariate file written: gcta_pc${NPCS}_covar.txt"

echo ">>> Step 2: MLMA with PC covariates"
gcta64 --mlma \
       --bfile ${BFILE} \
       --grm ${GRM} \
       --autosome-num ${AUTOSOME_NUM} \
       --pheno ${PHENO_FILE} \
       --qcovar gcta_pc${NPCS}_covar.txt \
       --out ${OUT_PREFIX} \
       > ${OUT_PREFIX}.log 2>&1

echo ">>> Results: ${OUT_PREFIX}.*"
echo ">>> Done."
