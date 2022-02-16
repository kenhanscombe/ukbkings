library(tidyverse)
library(data.table)
library(readxl)


# PharmGKB curated drug list (​https://www.pharmgkb.org/downloads​, drugs.zip)
drug_pharmgkb <- fread("data-raw/drugs/drugs.tsv", quote = "") %>%
    as.data.frame()

names(drug_pharmgkb) <- names(drug_pharmgkb) %>%
    tolower() %>%
    str_replace_all("-| ", "_")


drug_pharmgkb <- drug_pharmgkb %>%
    dplyr::mutate(
        dplyr::across(
            tidyselect:::where(is.character),
            ~ stringi::stri_trans_general(.x, "latin-ascii")
        )
    )

usethis::use_data(drug_pharmgkb, overwrite = TRUE)


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