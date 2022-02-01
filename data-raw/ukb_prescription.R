# Saskia's (medication dosage preparation)
# ========================================
# ukb56514_fabbri/CYP450/scripts/code_calculate_antidep_dosage_SPH_14122021.R

# /scratch/groups/ukbiobank/
# Reads:
# drugs <- "usr/saskia_h/UKB_data/CYP450/data/ukb18177_all_antidep_extracted_mapped_18022020_SPH.txt"
# quant_map <- "usr/saskia_h/UKB_data/CYP450/data/quantity_mapped_tablets_v2.txt"
# quant_map_drops <- "Edinburgh_Data/usr/saskia_h/UKB_data/CYP450/data/quantity_mapped_drops_v2.txt"
# cyp <- "usr/saskia_h/UKB_data/CYP450/data/ukb56514_CYP2C19_metabolizer_status_09022021_SPH.txt"
# Writes:
# "Edinburgh_Data/usr/saskia_h/UKB_data/CYP450/data/ukb18177_antidepressants_dosage_data_prescription_ep_cyp2c19_18082021.rds")

# !! bridge <- "/scratch/datasets/ukbiobank/ukb56514/raw/bridge_56514_18177.csv"


# Chiara (antidepressant prescriptions)
# =====================================
# /scratch/groups/ukbiobank/usr/chiara/GP_data/

# antidepressant prescriptions
# ukb56514_antidep_extracted.txt

# antidepressant prescriptions with diagnosis of depression
# (see column dep_vs_med)
# ukb56514_dep_AD_data.txt

# antipsychotics, some mood stabilizers (lithium, valproate, lamotrigine
# and pregabalin), and anxiolytics/hypnotics
# extracted_med_data_ukb56514.txt


# https://github.com/chiarafabbri/MDD_TRD_study
# extract anti -depressant, -psychotics, and mood stabilizers
# extract_diagn_ADs_TRD_pheno.R
# extract_other_diagn_med.R


devtools::load_all("/scratch/datasets/ukbiobank/ukbkings")
library(readxl)

project_dir <- "/scratch/datasets/ukbiobank/ukb56514"


# Read 2 antidepressant codes from primary care data

# Primary Care Codings:
# http://biobank.ndph.ox.ac.uk/showcase/showcase/auxdata/primarycare_codings.zip
# primarycare_codings/all_lkps_maps_v3.xlsx
# primarycare_codings/all_lkps_maps_variable_names_definitions_v3.pdf

primary_care_xlsx <- "primarycare_codings/all_lkps_maps_v3.xlsx"

# readxl::excel_sheets(primary_care_xlsx)
# [1] "Description"       "Contents"          "bnf_lkp"           "dmd_lkp"           "icd9_lkp"          "icd10_lkp"         "icd9_icd10"
#  [8] "read_v2_lkp"       "read_v2_drugs_lkp" "read_v2_drugs_bnf" "read_v2_icd9"      "read_v2_icd10"     "read_v2_opcs4"     "read_v2_read_ctv3"
# [15] "read_ctv3_lkp"     "read_ctv3_icd9"    "read_ctv3_icd10"   "read_ctv3_opcs4"   "read_ctv3_read_v2"



# ATC codes for antidepressants
# https://bmjopen.bmj.com/content/suppl/2013/09/20/bmjopen-2013-003507.DC1/bmjopen-2013-003507supp.pdf



# Antidepressant prescriptions
# One filter with bnf OR dmd OR read2 code

bnf_antidep_prescriptions <- bio_record(project_dir, record = "gp_scripts") %>%
    filter(str_detect(bnf_code, "^04\\.?03\\.?0[1-4]")) %>%
    collect() %>%
    distinct()

dmd_rgx <- str_c("^", drug_dmd_antidep$dmd_name) %>%
    str_c(collapse = "|") %>%
    regex(ignore_case = TRUE)

dmd_antidep_prescriptions <- bio_record(project_dir, record = "gp_scripts") %>%
    filter(str_detect(drug_name, dmd_rgx)) %>%
    collect() %>%
    distinct()

read2_antidep_prescriptions <- bio_record(project_dir, record = "gp_scripts") %>%
    filter()