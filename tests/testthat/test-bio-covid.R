context('COVID-19 data')

test_that("bio_covid stops with error if no covid-19 data available", {
  expect_error(
    bio_covid(".", data = "results", results_dir = ".", code_dir = "."),
    "COVID-19 data is not available for this project."
  )
})
