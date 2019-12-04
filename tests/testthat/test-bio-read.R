test_that("bio_field stops and prints error for invalid path", {
  testthat::expect_error(bio_field("invalid/path"), "Invalid project directory path.")
})
