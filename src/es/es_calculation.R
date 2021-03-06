############### SYNOPSIS ###################
# 1) Calculate ES
# 2) Saves ES object (as .RData file)
# 3) Writes multi geneset file for es_mu to use as input for S-LDSC/CELLECT
# Output is written to tmp-data/expression-precalc/

### OUTPUT: 
# ....

### REMARKS:
# ....

### REFERENCE:

# ======================================================================= #
# =============================== USAGE ================================ #
# ======================================================================= #

# SEE run_es_calculation.sh

# ======================================================================= #
# =============================== SETUP ================================ #
# ======================================================================= #

library(tidyverse)
library(here)

source(here("src/lib/load_functions.R")) # load sc-genetics library

# ======================================================================= #
# =============================== CONSTANTS ================================ #
# ======================================================================= #

# TODO: test that outdir writeable
path_out <- here("out/es")


# ======================================================================= #
# ================================== FUNCTION ============================== #
# ======================================================================= #

wrapper_calc_es <- function(path_prefix.es_precalc, path_out, dataset_prefix, version_stamp, type_mouse_gene_ids) {
  
  file.out.es_obj <- sprintf("%s/%s.es_obj-%s.RData", path_out, dataset_prefix, version_stamp)
  if (file.exists(file.out.es_obj)) {
    print("ES object file already exists. Will overwrite it...")
  }

  # ================================== Mouse ============================== #
  es_obj_mouse <- create_es_object(path_prefix.es_precalc)
  es_obj_mouse <- exclude_sporadic_expressed_genes(es_obj_mouse)
  # es_obj_mouse <- calc_es_wrapper(es_obj_mouse)
  # es_obj_mouse <- bin_ess(es_obj_mouse, n_bins=101, threshold_bin_zero=0)
  
  # print("Saving object...")
  # file.out <- sprintf("%s/%s.es_obj_mouse-%s.RData", path_out, dataset_prefix, version_stamp)
  # save(es_obj_mouse, file=file.out)
  
  # ============================== Human =============================== #
  
  es_obj <- map_to_human(es_obj_mouse, type_mouse_gene_ids=type_mouse_gene_ids)
  es_obj <- calc_es_wrapper(es_obj)
  es_obj <- calc_empirical_pvalues_wrapper(es_obj)
  es_obj <- transform_ess(es_obj, method="rank_normalize")
  es_obj <- set_group_by_annotation_slots(es_obj)
  es_obj <- calc_es_meta(es_obj)
  
  print("Saving ES object...")
  save(es_obj, file=file.out.es_obj)
  print("Done saving")
  
  # ================================ Write ESs ================================= #
  
  ### Write ES mu matrix
  # write_es(slot='es_meta'): writes out mean, median, sd
  write_es(es_obj, slot="es_meta", dataset_prefix=dataset_prefix, dir_out=path_out)

  ### [LEGACY] Write multi_geneset_file for LDSC --> ES mu only
  # df_multi_geneset <- write_multi_geneset_file(es_obj, dataset_prefix, dir_out=path_out, use_es_w=F, es_mean_only=T) # no raw values
  
  ### [LEGACY] Write multi_geneset_file for LDSC --> ESw [not needed]
  # df_multi_geneset <- write_multi_geneset_file(es_obj, dataset_prefix=sprintf("%s_raw_ess", dataset_prefix), use_raw_es_values=T) # *OBS*: only set use_raw_es_values=T if you want raw (untransformed) ES values exported.
  print("Done with function")
  

}


# ======================================================================= #
# =============================== ARGS ================================ #
# ======================================================================= #

### CMD Args
dataset_prefix <- commandArgs(trailingOnly=TRUE)[1]
version_stamp <- commandArgs(trailingOnly=TRUE)[2]
print(sprintf("RUNNING dataset_prefix=%s, version_stamp=%s", dataset_prefix, version_stamp))

### DEV | MANUAL Args
# version_stamp <- "999999"
# dataset_prefix2run <- c("tabula_muris","mousebrain","campbell2017_lvl1","campbell2017_lvl2")
# dataset_prefix <- "campbell2017_lvl1"
# dataset_prefix <- "campbell2017_lvl2"
# dataset_prefix <- "tabula_muris"
# dataset_prefix <- "mousebrain"


path_prefix.es_precalc <- here("tmp-data/expression-precalc/", dataset_prefix) 
if (dataset_prefix == "mousebrain") {
  type_mouse_gene_ids <- "ensembl"
} else if (dataset_prefix == "tabula_muris") {
  type_mouse_gene_ids <- "mgi"
} else if (dataset_prefix %in% c("campbell2017_lvl1", "campbell2017_lvl2", "campbell2017_lvl1_neur", "campbell2017_lvl2_neur")) {
  type_mouse_gene_ids <- "mgi"
} else if (dataset_prefix == "chen2017") {
    type_mouse_gene_ids <- "mgi"
} else if (dataset_prefix == "romanov2017") {
    type_mouse_gene_ids <- "mgi"
} else if (dataset_prefix == "moffitt2018") {
    type_mouse_gene_ids <- "ensembl" 
} else if (dataset_prefix == "mikkelsen2019") {
  type_mouse_gene_ids <- "ensembl" 
} else if (dataset_prefix == "kimVMH2019_10x") {
  type_mouse_gene_ids <- "mgi" 
} else if (dataset_prefix == "kimVMH2019_smartseq") {
  type_mouse_gene_ids <- "mgi"  
} else {
  stop(sprintf("Got wrong dataset_prefix %s", dataset_prefix))
}


# ======================================================================= #
# =============================== RUN ================================ #
# ======================================================================= #

wrapper_calc_es(path_prefix.es_precalc, path_out, dataset_prefix, version_stamp, type_mouse_gene_ids)


print("Script done!")
