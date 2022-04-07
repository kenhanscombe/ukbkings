context("codes")

tmp_dir <- tempdir()
tmp <- testthat::setup(tempfile(tmpdir = tmp_dir))

test_that("bio_code stops and prints error when no coding data available", {
  expect_error(
    bio_code(project_dir = "."),
    stringr::str_interp(
      c("Required file .*Codings.csv does not exist.")
    )
  )
})

testthat::teardown(unlink(c(tmp, tmp_dir)))
