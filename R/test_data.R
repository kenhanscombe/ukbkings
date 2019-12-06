# Make unit test data

# library(dplyr)
# library(magrittr)

# Use tab testdata from ukbtools
testdata_ukbtools <- system.file("extdata", package = "ukbtools")
tab <- read.delim(file.path(testdata_ukbtools, "ukbxxxx.tab"))

# Convert tab file to csv with quotes and missing values to match default ukbconv created csv file
tab %>%
  mutate_all(as.character) %>%
  write.csv(
    "inst/testdata/ukb12345.csv",
    row.names = FALSE,
    quote = TRUE,
    na = ""
  )

# Associated "field finder" from tab names and types.
# (header: field, name, ukb_type)
f <- data.frame(
  field = names(tab),
  name = str_c("var_", 1:ncol(tab)),
  ukb_type = c(
    "Integer", "Integer", "Integer", "Text", "Text",
    "Continuous", "Integer", "Text", "Text", "Text",
    "Text", "Text", "Text", "Text", "Text",
    "Text", "Text", "Text", "Text", "Text",
    "Text", "Text", "Text", "Text", "Text",
    "Text", "Text", "Integer", "Text", "Text",
    "Integer", "Text", "Text"
  )
)

f %>%
  write.table(
    "inst/testdata/ukb12345_field_finder.txt",
    sep = "\t",
    row.names = FALSE,
    quote = FALSE
  )
