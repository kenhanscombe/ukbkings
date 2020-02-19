context("fields")

# TODO: write tests for bio_field_add

test_that("bio_field stops and prints error for invalid path", {
  expect_error(bio_field("invalid/path"), "Invalid project directory path.")
})

test_that("bio_field creates valid path to csv", {
  testdata_path <- system.file("testdata", package = "ukbkings")
  df <- bio_field(testdata_path)

  expect_match(df$basket[1], "^ukb[0-9]+$")
  expect_true(file.exists(df$path[1]))
})
