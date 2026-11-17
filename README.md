# Atlantic Salmon Genotype QC & GWAS Pipeline

A practical, step-by-step pipeline for converting Axiom array genotype data into analysis-ready PLINK binary filesets, performing quality control, estimating relatedness, running heritability (REML) and mixed-model association (MLMA) analyses with GCTA, and exploring population structure via PCA.

The workflow is tailored for **Atlantic salmon** (*Salmo salar*) data (29 chromosome set, `ssa` chromosome nomenclature) but can be adapted to other species by changing a few variables.

> **Attribution**  
> Several data-preparation steps were adapted from the excellent tutorial  
> [Genotype files in practice](https://genomicsbootcamp.github.io/book/genotype-files-in-practice.html)  
> by the Genomics Bootcamp team. All subsequent QC, relatedness, GWAS and PCA steps were developed / customised for this project.

---

## Pipeline Overview

| Step | Script | Purpose |
|------|--------|---------|
| 1 | `01_prepare_plink_fileset.sh` | Clean Axiom `.ped`/`.map`, create binary fileset, convert `ssa` chromosomes to numeric |
| 2 | `02_remove_duplicates_and_qc.sh` | IBD-based duplicate removal + standard SNP/individual QC filters |
| 3 | `03_gcta_grm_reml_mlma.sh` | Build GRM → REML heritability → MLMA GWAS |
| 4 | `04_pca.sh` + `plot_pca.R` | LD pruning → PCA → scree & structure plots |
| 5 | `05_mlma_with_pcs.sh` | Re-run MLMA using the first *N* PCs as covariates |

An optional helper script (`optional_rename_sample_ids.sh`) is provided for mapping array Sample IDs to animal / phenotype IDs.

---

## Requirements

### Software
- **PLINK 1.9** (or PLINK 2.x with compatible flags)
- **GCTA** ≥ 1.94 (`gcta64`)
- **R** ≥ 4.0 (only for the PCA plotting script)
- Standard Unix tools: `awk`, `gawk`, `bash`

### Input files you must supply
| File | Description |
|------|-------------|
| `myfile.ped` + `.map` | Axiom export (or any PED/MAP pair) |
| Phenotype file(s) | GCTA format: `FID  IID  phenotype` (e.g. `pheno_positive.txt`, `full_phenotype_LOD.txt`) |
| (optional) Mapping file | For sample-ID renaming |

Place all input files in the working directory (or adjust the paths inside the scripts).

---

## Quick Start

```bash
# Make scripts executable
chmod +x scripts/*.sh scripts/*.R

# 1. Prepare clean PLINK fileset
./scripts/01_prepare_plink_fileset.sh

# 2. Remove duplicates & apply QC
./scripts/02_remove_duplicates_and_qc.sh

# 3. GRM + REML + basic MLMA
./scripts/03_gcta_grm_reml_mlma.sh

# 4. PCA
./scripts/04_pca.sh
Rscript scripts/plot_pca.R

# 5. MLMA with PC covariates (edit NPCS and phenotype file if needed)
./scripts/05_mlma_with_pcs.sh
```

All key thresholds (IBD, missingness, HWE, MAF, number of PCs, etc.) are defined as variables at the top of each script so they are easy to change.

---

## Important Notes & Design Choices

### Chromosome handling
Atlantic salmon chromosomes are exported by Axiom software with names such as `ssa01`, `ssa02`, … `ssa29` and sometimes `mit`.  
The pipeline:
1. Strips the `ssa`/`ssa0` prefix so that PLINK and GCTA see numeric chromosomes 1–29.
2. Explicitly excludes the mitochondrial chromosome (`--not-chr mit`).
3. Uses `--chr-set 29` / `--autosome-num 29` throughout.

### Duplicate detection
Pairwise IBD is estimated with PLINK `--genome`. Any pair with PI_HAT > 0.90 is treated as a duplicate; **both** members of the pair are written to the removal list. You may wish to keep one individual from each pair — edit the `gawk` block in `02_remove_duplicates_and_qc.sh` if you prefer that behaviour.

### QC defaults
| Filter | Default | Meaning |
|--------|---------|---------|
| `--geno` | 0.05 | Remove SNPs with >5 % missing genotypes |
| `--mind` | 0.05 | Remove individuals with >5 % missing genotypes |
| `--hwe`  | 1e-6 | Hardy-Weinberg filter |
| `--maf`  | 0.05 | Minor-allele-frequency filter |
| `--nonfounders` | on | Do not require founders for HWE |

These are conventional starting values; adjust them according to your study design and sample size.

### Choosing the number of PCs
After running `plot_pca.R`, inspect `pc_scree_plot.png`.  
Include all principal components **before** the elbow (the point at which the variance explained flattens).  
Then set the `NPCS` variable in `05_mlma_with_pcs.sh` accordingly.

---

## Output Files (main ones)

| File / prefix | Description |
|---------------|-------------|
| `file1_clean.{bed,bim,fam}` | Clean binary fileset after chromosome correction |
| `finaldata.{bed,bim,fam}` | QC-filtered fileset (duplicates removed) |
| `GRM_data.*` | Genomic relationship matrix |
| `reml_TRAIT.*` | REML heritability results |
| `gwas.*` | MLMA association results (no covariates) |
| `pca_results.eigenval/vec` | PCA eigenvalues & eigenvectors |
| `pc_scree_plot.png` / `pc_structure_plot.png` | PCA diagnostic plots |
| `gwas_LODfull_co.*` | MLMA results with PC covariates |

---

## Customisation Tips

- **Different species** – change `CHR_SET` / `AUTOSOME_NUM` and the chromosome-stripping logic in `01_prepare_plink_fileset.sh`.
- **Different phenotype** – edit the `PHENO_FILE` variable in the GCTA scripts.
- **Keep one of each duplicate pair** – modify the `gawk` command that writes `ID_to_remove.txt`.
- **More / fewer PCs** – change `NPCS` in `05_mlma_with_pcs.sh`.

---

## Licence & Citation

This repository is released under the MIT Licence (see `LICENSE` if present).  
If you use the pipeline in a publication, please cite:

1. The original Genomics Bootcamp tutorial for the early data-preparation ideas.  
2. PLINK, GCTA and any other software you rely on (standard practice).

---

## Author

Oluwabusayo Israel Okeleye  
PhD Candidate, Genetics & Genomics – University of Edinburgh  

Feel free to open an issue or pull request if you find bugs or have improvements.
