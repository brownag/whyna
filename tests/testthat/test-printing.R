test_that("format displays observed values numerically", {
  x <- why_na(c(1.5, 2.3, 3.7), c(0L, 0L, 0L))
  out <- format(x)
  expect_length(out, 3)
  expect_true(all(out %in% c("1.5", "2.3", "3.7")))
})

test_that("format displays MCAR as <NA:MCAR>", {
  x <- why_na(c(1.5, NA), c(0L, 1L))
  out <- format(x)
  expect_identical(out[2], "<NA:MCAR>")
})

test_that("format displays MAR as <NA:MAR>", {
  x <- why_na(c(1.5, NA), c(0L, 2L))
  out <- format(x)
  expect_identical(out[2], "<NA:MAR>")
})

test_that("format displays MNAR as <NA:MNAR>", {
  x <- why_na(c(1.5, NA), c(0L, 3L))
  out <- format(x)
  expect_identical(out[2], "<NA:MNAR>")
})

test_that("vec_ptype_abbr returns typed abbreviation", {
  x <- why_na(c(1.5, 2.3), c(0L, 1L))
  expect_identical(vctrs::vec_ptype_abbr(x), "why_dbl")
})

test_that("vec_ptype_full returns typed full name", {
  x <- why_na(c(1.5, 2.3), c(0L, 1L))
  expect_identical(vctrs::vec_ptype_full(x), "informative_na<double>")
})

test_that("print output contains type abbreviation in tibble", {
  skip_if_not_installed("tibble")
  x <- why_na(c(1.5, NA), c(0L, 1L))
  df <- tibble::tibble(val = x)
  output <- capture.output(print(df))
  expect_true(any(grepl("why_dbl", output)))
})

test_that("print output shows format correctly", {
  x <- why_na(c(1.5, NA), c(0L, 1L))
  output <- capture.output(print(x))
  expect_true(any(grepl("NA:MCAR", paste(output, collapse = " "))))
})
