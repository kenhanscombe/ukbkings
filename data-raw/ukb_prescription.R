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
library(rvest)

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

read_v2_drugs_lkp <- read_xlsx(primary_care_xlsx, sheet = "read_v2_drugs_lkp")
read_v2_drugs_bnf <- read_xlsx(primary_care_xlsx, sheet = "read_v2_drugs_bnf")
dmd_lkp <- read_xlsx(primary_care_xlsx, sheet = "dmd_lkp")

# dm+d codes from Chiara's drug list
dmd_names <- c(
    "agomelatine", "allegron", "alventa", "amfebutamone", "amitriptyline",
    "amoxapine", "amphero", "anafranil", "apclaven", "asendis", "bolvidon",
    "bonilux", "brintellix", "bupropion", "butriptyline", "cipralex",
    "cipramil", "citalopram", "clomipramine", "cymbalta", "dapoxetine",
    "defanyl", "depalta", "depefex", "desipramine", "domical", "dosulepin",
    "dothapax", "dothiepin", "doxepin", "duciltia", "duloxetine", "dutonin",
    "dutor", "edronax", "efexor", "escitalopram", "faverin", "felicium",
    "feprapax", "fetzima", "fluanxol", "fluoxetine", "flupenthixol",
    "flupentixol", "fluvoxamine", "gamanil", "imipramine", "iprindole",
    "iproniazid", "isocarboxazid", "lentizol", "levomilnacipran", "lofepramine",
    "loferpramine", "lomont", "ludiomil", "lustral", "majoven", "manerix",
    "maprotiline", "marplan", "mianserin", "milnacipran", "mirtazapine",
    "mirtazepine", "mirtazipine", "moclobemide", "molipaxin", "motipress",
    "motival", "nardil", "nefazodone", "nortriptyline", "norval", "olena",
    "optimax", "oxactin", "parnate", "paroxetine", "parstelin", "perphenazine",
    "phenelzine", "politid", "prepadine", "priligy", "prothiaden",
    "protriptyline", "prozac", "prozep", "ranfaxine", "ranflutin",
    "reboxetine", "rodomel", "seroxat", "sertraline", "sinepin", "sinequan",
    "sunveniz", "surmontil", "tardcaps", "thaden", "tifaxin", "tofranil",
    "tonpular", "tranylcypromine", "trazadone", "trazodone", "trimipramine",
    "triptafen", "triptafen-m", "trixat", "tryptizol", "tryptophan", "valdoxan",
    "vaxalin", "venaxx", "vencarm", "venlablue", "venladex", "venlafaxin",
    "venlafaxine", "venlalic", "venlaneo", "venlasov", "vensir", "venzip",
    "vexarin", "viepax", "viloxazine", "vivactil", "vivalan", "vortioxetine",
    "winfex", "yentreve", "zispin", "zyban"
)

# ==
# NHS dm+d browser
# https://services.nhsbsa.nhs.uk/dmd-browser/
# Code lookup by BNF Chapter 0403: https://services.nhsbsa.nhs.uk/dmd-browser/code-lookup

chr_from_dmd_html_table <- function(url, page) {
    html <- str_interp(url, list(page = page)) %>%
        read_html()

    html %>%
        html_table() %>%
        .[[1]] %>%
        .[[1]] %>%
        str_replace("null \n                  ", "") %>%
        word(1) %>%
        tolower()
}

dmd_url <- "https://services.nhsbsa.nhs.uk/dmd-browser/code-lookup/results?code=0403&codeType=BNF&size=20&sortOrder=rel&page=${page}"
dmd_anti_dep <- map(1:4, ~ chr_from_dmd_html_table(dmd_url, page = .)) %>%
    reduce(c) %>%
    unique()


# ATC codes for antidepressants
# https://bmjopen.bmj.com/content/suppl/2013/09/20/bmjopen-2013-003507.DC1/bmjopen-2013-003507supp.pdf
# ==


# Antidepressant prescriptions
# One filter with bnf OR dmd OR read2 code

bnf_antidep_prescriptions <- bio_record(project_dir, record = "gp_scripts") %>%
    filter(str_detect(bnf_code, "^04\\.?03\\.?0[1-4]")) %>%
    collect() %>%
    distinct()

dmd_antidep_prescriptions <- bio_record(project_dir, record = "gp_scripts") %>%
    filter()

read2_antidep_prescriptions <- bio_record(project_dir, record = "gp_scripts") %>%
    filter()