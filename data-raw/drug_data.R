library(tidyverse)
library(data.table)
library(readxl)


# PharmGKB curated drug list (​https://www.pharmgkb.org/downloads​, drugs.zip)
drug_pharmgkb <- fread("data-raw/drugs/drugs.tsv", quote = "") %>%
    as.data.frame()

names(drug_pharmgkb) <- names(drug_pharmgkb) %>%
    tolower() %>%
    str_replace_all("-| ", "_")

usethis::use_data(drug_pharmgkb)


# Wu et al. (2019) Nat Commun
# Supplementary Data 1: Active ingredients and ATC code of medications
# in UK Biobank
drug_gwas <- readxl::read_excel(
    "data-raw/wu_nat_commun_2019_supp_data_1.xlsx",
    sheet = 1, skip = 1
) %>%
    select(1:4) %>%
    as.data.frame()

names(drug_gwas) <- c("category", "ukb_code", "atc_code", "name")

usethis::use_data(drug_gwas)


# Curated dm+d codes from Fabbri et al (2021)
drug_dmd_antidep <- data.frame(dmd_name = c(
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
))

usethis::use_data(drug_dmd_antidep, overwrite = TRUE)


# UKB primary care drug maps and lookups:
# BNF lookup (version 76)
# dm+d lookup (May 2019 release)
# Read v2 drugs lookup (April 2016 release)
# Read v2 (April 2016 release) to BNF (version 76) mapping

primary_care_xlsx <- "data-raw/primarycare_codings/all_lkps_maps_v3.xlsx"

bnf_lkp <- read_xlsx(primary_care_xlsx, sheet = "bnf_lkp")
dmd_lkp <- read_xlsx(primary_care_xlsx, sheet = "dmd_lkp")
read_v2_drugs_lkp <- read_xlsx(primary_care_xlsx, sheet = "read_v2_drugs_lkp")
read_v2_drugs_bnf <- read_xlsx(primary_care_xlsx, sheet = "read_v2_drugs_bnf")

drug_ukb <- tibble(
    df = list(bnf_lkp, dmd_lkp, read_v2_drugs_lkp, read_v2_drugs_bnf),
    name = c("bnf_lkp", "dmd_lkp", "read_v2_drugs_lkp", "read_v2_drugs_bnf"),
    description = c(
        "BNF lookup (version 76)",
        "dm+d lookup (May 2019 release)",
        "Read v2 drugs lookup (April 2016 release)",
        "Read v2 (April 2016 release) to BNF (version 76) mapping"
    )
)

usethis::use_data(drug_ukb, overwrite = TRUE)
