#' PharmGKB curated drug list
#'
#' A dataset containing all Chemicals with the Type of "Drug" in the PharmGKB
#' knowledgebase. Not all of these drugs have been involved in PharmGKB
#' annotations.
#'
#' @format A data frame with 3493 obs. of  24 variables:
#' \describe{
#'   \item{pharmgkb_accession_id}{Identifier assigned to this chemical by PharmGKB}
#'   \item{name}{Name PharmGKB uses for this drug}
#'   \item{generic_names}{Known generic names for this drug, comma-separated and "-enclosed}
#'   \item{trade_names}{Known trade names for this drug, comma-separated and "-enclosed}
#'   \item{brand_mixtures}{Known brand mixtures this drug is in, comma-separated and "-enclosed}
#'   \item{type}{Categories PharmGKB has assigned to this drug, can be more than one, possible values: Drug, Metabolite,
#' Ion, Drug Class, Biological Intermediate, Small Molecule, Prodrug}
#'   \item{cross_references}{References to other resources in the form "resource:id", comma-separated}
#'   \item{smiles}{The SMILES structure for this drug}
#'   \item{inchi}{The InCHI key for this drug}
#'   \item{dosing_guideline}{"Yes" if PharmGKB has annotated a guideline with this drug, "No" otherwise}
#'   \item{external_vocabulary}{Term for this drug in another vocabulary in the form "vocabulary:id", comma-separated}
#' }
#'
#' Multiple "Type" values can be assigned to a given entry
#' since the same substance can be used in different contexts. The
#' "Type" values used for Drugs & Chemicals are as follows:
#'
#' * __Drug__ A chemical substance used in the treatment, cure,prevention, or diagnosis of disease.
#' * __Metabolite__ Any intermediate or product resulting from metabolism.
#' * __Ion__ An atomic or molecular particle having a net electric charge.
#' * __Drug Class__ A drug class is a group of medications that may work in the same way, have a similar chemical structure, or are used to treat the same health condition.
#' * __Biological Intermediate__ An endogenous small molucule or ion.
#' * __Small Molecule__ An electrically neutral entity consisting of more than one atom.
#' * __Prodrug__ A compound that must undergo chemical conversion by metabolic processes before becoming the pharmacologically active drug for which it is a prodrug.
#'
#' @source \url{https://www.pharmgkb.org/downloads}
"drug_pharmgkb"


#' Active ingredients and ATC code of UKB self-reported medications
#'
#' A dataset containing
#' [Wu et al. (2019) Nat Commun](10.1038/s41467-019-09572-5),
#' Supplementary Data 1: Active ingredients and ATC code of medications
#' in UK Biobank. This study was a series of "GWASs of self-reported
#' medication use from 23 medication categories".
#'
#' The Anatomical Therapeutic Chemical (ATC) code: a unique code
#' assigned to a medicine according to the organ or system it works on
#' and how it works. The classification system is maintained by the
#' World Health Organization (WHO). In the ATC-Classification
#' substances are divided into different groups according to the organ
#' or organ system which they affect and their chemical, pharmacological
#' and therapeutic properties. A defined daily dose is assigned to each
#' active substance. Defined daily doses (DDD) are the assumed average
#' daily maintenance dose for the main indication of each substance in
#' adults.
#'
#' EU Commission Centralised medicinal products for human use by ATC code
#' https://ec.europa.eu/health/documents/community-register/html/reg_hum_atc.htm
#'
#' @format A data frame with 1752 obs. of  4 variables:
#' \describe{
#'   \item{category}{Category}
#'   \item{ukb_code}{Coding reported by UK Biobank}
#'   \item{atc_code}{Medication ATC code}
#'   \item{name}{Drug name}
#' }
"drug_gwas"


#' Curated dm+d antidepressant names
#'
#' Antidepressant dm+d names extracted by [Fabbri et al. (2021) Genetic
#' and clinical characteristics of treatment-resistant depression using
#' primary care records in two UK cohorts](https://pubmed.ncbi.nlm.nih.gov/33753889/)
#' \describe{
#'   \item{dmd_name}{Category}
#' }
"drug_dmd_antidep"