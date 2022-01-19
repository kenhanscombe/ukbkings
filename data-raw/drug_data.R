# drugs.tsv - PharmGKB curated drug list (​https://www.pharmgkb.org/downloads​, drugs.zip)
# ukb.gwas.medication.supplementary.data.1.xlsx - Genome-wide association study of medication-use and associated disease in the UK Biobank, Nature Communications


library(tidyverse)
library(data.table)
library(readxl)


drugs_pharmvar <- fread("data-raw/drugs/drugs.tsv", quote = "")
names(drugs_pharmvar) <- names(drugs_pharmvar) %>%
    tolower() %>%
    str_replace_all("-| ", "_")

drugs_ukb <- read_excel(
    "data-raw/wu_nat_commun_2019_supp_data_1.xlsx",
    sheet = 1, skip = 1
) %>%
    select(1:4)

names(drugs_ukb) <- c("category", "ukb_code", "atc_code", "name")