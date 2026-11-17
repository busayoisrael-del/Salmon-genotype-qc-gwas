#!/usr/bin/env bash
# =============================================================================
# 04_pca.sh
# LD-pruning followed by principal component analysis (PCA) with PLINK.
# Generates the eigenvalue / eigenvector files required by the R plotting script.
#
# Prerequisites:
#   - PLINK 1.9
#   - Input: finaldata.{bed,bim,fam}
# =============================================================================

set -euo pipefail

BFILE="finaldata"
CHR_SET=29
OUT_PREFIX="pca_results"

echo ">>> Step 1: LD pruning (window 50, step 5, r² threshold 0.2)"
plink --bfile ${BFILE} \
      --chr-set ${CHR_SET} \
      --indep-pairwise 50 5 0.2 \
      --out pca_pruning

echo ">>> Step 2: Compute principal components"
plink --bfile ${BFILE} \
      --chr-set ${CHR_SET} \
      --extract pca_pruning.prune.in \
      --pca 20 \
      --out ${OUT_PREFIX}

echo ">>> Eigenvalues  → ${OUT_PREFIX}.eigenval"
echo ">>> Eigenvectors → ${OUT_PREFIX}.eigenvec"
echo ">>> Done.  Now run: Rscript scripts/plot_pca.R"
