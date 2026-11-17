#!/usr/bin/env Rscript
# =============================================================================
# plot_pca.R
# Visualise PCA results: scree plot + PC1 vs PC2 scatter.
# Expects files produced by 04_pca.sh:
#   pca_results.eigenval
#   pca_results.eigenvec
# =============================================================================

# 1. Load eigenvalues and eigenvectors
eigenvals  <- read.table("pca_results.eigenval", header = FALSE)$V1
eigenvecs  <- read.table("pca_results.eigenvec", header = FALSE)

# 2. Proportion of Variance Explained (PVE)
total_variance <- sum(eigenvals)
pve <- (eigenvals / total_variance) * 100

cat("\n=========================================\n")
cat(" PROPORTION OF VARIANCE EXPLAINED (PVE)\n")
cat("=========================================\n")
for (i in seq_len(min(10, length(pve)))) {
  cat(sprintf("PC%02d: %6.3f%%\n", i, pve[i]))
}
cat("=========================================\n\n")

# 3. Scree plot
png("pc_scree_plot.png", width = 800, height = 600, res = 150)
plot(seq_along(pve), pve, type = "b", pch = 19, col = "blue4",
     xlab = "Principal Component",
     ylab = "Variance Explained (%)",
     main = "Scree Plot: Determine PC Cut-off")
grid()
dev.off()

# 4. PC1 vs PC2 scatter
png("pc_structure_plot.png", width = 800, height = 800, res = 150)
plot(eigenvecs$V3, eigenvecs$V4, pch = 20, col = "darkgreen",
     xlab = paste0("PC1 (", round(pve[1], 2), "%)"),
     ylab = paste0("PC2 (", round(pve[2], 2), "%)"),
     main = "Population Stratification (PC1 vs PC2)")
grid()
dev.off()

cat("Plots saved:\n  - pc_scree_plot.png\n  - pc_structure_plot.png\n")
