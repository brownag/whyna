# Tests for generalized typed NA support across multiple value types

# Constructor tests per value type

test_that("why_na preserves logical type", {
  x <- why_na(c(TRUE, NA, FALSE), c(0L, 1L, 0L))
  expect_equal(typeof(vctrs::field(x, "value")), "logical")
  expect_identical(vctrs::field(x, "value")[2], NA)
})

test_that("why_na preserves integer type", {
  x <- why_na(c(1L, NA, 3L), c(0L, 2L, 0L))
  expect_equal(typeof(vctrs::field(x, "value")), "integer")
  expect_identical(vctrs::field(x, "value")[2], NA_integer_)
})

test_that("why_na preserves double type", {
  x <- why_na(c(1.5, NA, 3.7), c(0L, 1L, 0L))
  expect_equal(typeof(vctrs::field(x, "value")), "double")
  expect_identical(vctrs::field(x, "value")[2], NA_real_)
})

test_that("why_na preserves character type", {
  x <- why_na(c("a", NA, "c"), c(0L, 1L, 0L))
  expect_equal(typeof(vctrs::field(x, "value")), "character")
  expect_identical(vctrs::field(x, "value")[2], NA_character_)
})

test_that("why_na preserves complex type", {
  x <- why_na(c(1+2i, NA, 3+4i), c(0L, 1L, 0L))
  expect_equal(typeof(vctrs::field(x, "value")), "complex")
  expect_identical(vctrs::field(x, "value")[2], NA_complex_)
})

test_that("why_na with Date preserves Date class", {
  skip_if_not_installed("lubridate")
  dates <- as.Date(c("2024-01-01", NA, "2024-01-03"))
  x <- why_na(dates, c(0L, 1L, 0L))
  expect_s3_class(vctrs::field(x, "value"), "Date")
  expect_identical(vctrs::field(x, "value")[2], as.Date(NA))
})

test_that("why_na with POSIXct preserves POSIXct class", {
  times <- as.POSIXct(c("2024-01-01 12:00:00", NA, "2024-01-03 12:00:00"), tz = "UTC")
  x <- why_na(times, c(0L, 1L, 0L))
  expect_s3_class(vctrs::field(x, "value"), "POSIXct")
  expect_true(is.na(vctrs::field(x, "value")[2]))
})

test_that("why_na with factor preserves factor class", {
  f <- factor(c("a", NA, "b"))
  x <- why_na(f, c(0L, 1L, 0L))
  expect_s3_class(vctrs::field(x, "value"), "factor")
  expect_true(is.na(vctrs::field(x, "value")[2]))
})

# Coercion tests

test_that("vec_c combines integer and double whyna to double whyna", {
  x <- why_na(c(1L, 2L), c(0L, 0L))
  y <- why_na(c(3.5, 4.5), c(0L, 0L))
  z <- vctrs::vec_c(x, y)
  expect_equal(typeof(vctrs::field(z, "value")), "double")
  expect_length(z, 4)
})

test_that("vec_c(whyna, bare vector) upgrades bare to whyna", {
  x <- why_na(c(1.5, 2.5), c(0L, 0L))
  y <- c(3.1, 4.2)
  z <- vctrs::vec_c(x, y)
  expect_s3_class(z, "informative_na")
  expect_length(z, 4)
})

test_that("vec_c errors on incompatible types", {
  x <- why_na(c("a", "b"), c(0L, 0L))
  y <- c(1.5, 2.5)
  expect_error(vctrs::vec_c(x, y), class = "vctrs_error")
})

test_that("cast from double to integer whyna errors on lossy cast", {
  x <- why_na(c(1.5, 2.5), c(0L, 0L))
  expect_error(vctrs::vec_cast(x, to = why_na(1L, c(0L))))
})

test_that("cast from integer to double whyna succeeds", {
  x <- why_na(c(1L, 2L), c(0L, 0L))
  result <- vctrs::vec_cast(x, to = why_na(1.5, c(0L)))
  expect_equal(typeof(vctrs::field(result, "value")), "double")
})

# Round-trip cast tests

test_that("extract value field from integer whyna", {
  x <- why_na(c(1L, NA, 3L), c(0L, 1L, 0L))
  y <- vctrs::field(x, "value")
  expect_equal(typeof(y), "integer")
  expect_equal(y[1], 1L)
})

test_that("extract value field from character whyna", {
  x <- why_na(c("a", NA, "c"), c(0L, 1L, 0L))
  y <- vctrs::field(x, "value")
  expect_equal(typeof(y), "character")
  expect_equal(y[1], "a")
})

# Printing tests

test_that("format character whyna displays correctly", {
  x <- why_na(c("a", NA, "c"), c(0L, 1L, 0L))
  out <- format(x)
  expect_match(out[1], "^a\\s*$")
  expect_identical(out[2], "<NA:MCAR>")
  expect_match(out[3], "^c\\s*$")
})

test_that("vec_ptype_abbr returns typed abbreviation for integer", {
  x <- why_na(c(1L, 2L), c(0L, 0L))
  abbr <- vctrs::vec_ptype_abbr(x)
  expect_match(abbr, "why_int")
})

test_that("vec_ptype_abbr returns typed abbreviation for character", {
  x <- why_na(c("a", "b"), c(0L, 0L))
  abbr <- vctrs::vec_ptype_abbr(x)
  expect_match(abbr, "why_chr")
})

test_that("vec_ptype_full returns typed full name for Date", {
  dates <- as.Date(c("2024-01-01", "2024-01-02"))
  x <- why_na(dates, c(0L, 0L))
  full <- vctrs::vec_ptype_full(x)
  expect_match(full, "informative_na<date>")
})

# sentinel_recode with ptype

test_that("sentinel_recode with default ptype=double works", {
  raw <- c("12.5", "-9999", "LOD", "15.1")
  x <- sentinel_recode(raw, list("-9999" = "MAR", "LOD" = "MNAR"))
  expect_equal(typeof(vctrs::field(x, "value")), "double")
  expect_equal(vctrs::field(x, "value")[1], 12.5)
  expect_true(is_mar(x)[2])
  expect_true(is_mnar(x)[3])
})

test_that("sentinel_recode with ptype=integer works", {
  raw <- c("12", "-9999", "LOD", "15")
  x <- sentinel_recode(raw, list("-9999" = "MCAR", "LOD" = "MNAR"), ptype = integer())
  expect_equal(typeof(vctrs::field(x, "value")), "integer")
  expect_equal(vctrs::field(x, "value")[1], 12L)
})

test_that("sentinel_recode with ptype=character preserves strings", {
  raw <- c("value1", "-9999", "LOD", "value2")
  x <- sentinel_recode(raw, list("-9999" = "MCAR", "LOD" = "MNAR"), ptype = character())
  expect_equal(typeof(vctrs::field(x, "value")), "character")
  expect_equal(vctrs::field(x, "value")[1], "value1")
  expect_equal(vctrs::field(x, "value")[4], "value2")
})

# tibble integration

test_that("tibble with character whyna column displays correctly", {
  skip_if_not_installed("tibble")
  x <- why_na(c("a", NA, "c"), c(0L, 1L, 0L))
  df <- tibble::tibble(val = x)
  expect_s3_class(df$val, "informative_na")
  output <- capture.output(print(df))
  expect_true(any(grepl("why_chr", output)))
})

test_that("tibble with integer whyna column displays correctly", {
  skip_if_not_installed("tibble")
  x <- why_na(c(1L, NA, 3L), c(0L, 1L, 0L))
  df <- tibble::tibble(val = x)
  expect_s3_class(df$val, "informative_na")
  output <- capture.output(print(df))
  expect_true(any(grepl("why_int", output)))
})

# dplyr integration

test_that("dplyr::filter preserves integer whyna type", {
  skip_if_not_installed("dplyr")
  x <- why_na(c(1L, 2L, NA, 4L), c(0L, 0L, 1L, 0L))
  df <- tibble::tibble(val = x)
  result <- dplyr::filter(df, is_observed(val))
  expect_equal(typeof(vctrs::field(result$val, "value")), "integer")
})

test_that("dplyr::mutate creates character whyna", {
  skip_if_not_installed("dplyr")
  df <- tibble::tibble(x = c("a", "b", "c"))
  result <- dplyr::mutate(df, y = why_na(x))
  expect_s3_class(result$y, "informative_na")
  expect_equal(typeof(vctrs::field(result$y, "value")), "character")
})
