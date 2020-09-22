context('covid-19')

test_that("bio_covid stops with error if no covid-19 data available", {
  expect_error(
    bio_covid(".", data = "results", covid_dir = ".", code_dir = "."),
    "COVID-19 data is not available for this project."
  )
})
