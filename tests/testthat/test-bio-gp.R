context("GP data")

tmp_dir <- tempdir()
tmp <- testthat::setup(tempfile(tmpdir = tmp_dir))

test_that("bio_gp stops and prints error when no gp data available", {
  expect_error(
    bio_gp("./", record = "clinical", gp_dir = tmp_dir),
    "GP data is not available for this project."
  )
})

testthat::teardown(unlink(c(tmp, tmp_dir)))
