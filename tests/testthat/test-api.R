test_that("is_mcar returns correct mask", {
  x <- why_na(c(1.5, NA, 2.3, NA), c(0L, 1L, 0L, 2L))
  result <- is_mcar(x)
  expect_identical(result, c(FALSE, TRUE, FALSE, FALSE))
})

test_that("is_mar returns correct mask", {
  x <- why_na(c(1.5, NA, 2.3, NA), c(0L, 1L, 0L, 2L))
  result <- is_mar(x)
  expect_identical(result, c(FALSE, FALSE, FALSE, TRUE))
})

test_that("is_mnar returns correct mask", {
  x <- why_na(c(1.5, NA, 2.3, NA, 3.1), c(0L, 1L, 0L, 2L, 3L))
  result <- is_mnar(x)
  expect_identical(result, c(FALSE, FALSE, FALSE, FALSE, TRUE))
})

test_that("is_mcar/is_mar/is_mnar are mutually exclusive", {
  x <- why_na(c(1.5, NA, NA, NA), c(0L, 1L, 2L, 3L))
  mcar <- is_mcar(x)
  mar <- is_mar(x)
  mnar <- is_mnar(x)
  # No element should be TRUE in more than one predicate
  expect_true(!any((mcar & mar) | (mcar & mnar) | (mar & mnar)))
})

test_that("is_mcar/is_mar/is_mnar preserve length after subsetting", {
  x <- why_na(c(1.5, NA, 2.3, NA), c(0L, 1L, 0L, 2L))
  sub <- x[c(1, 3, 4)]
  result <- is_mcar(sub)
  expect_length(result, 3)
})

test_that("missing_reason returns factor with correct levels", {
  x <- why_na(c(1.5, NA, 2.3), c(0L, 1L, 2L))
  result <- missing_reason(x)
  expect_true(is.factor(result))
  expect_identical(levels(result), c("Observed", "MCAR", "MAR", "MNAR"))
})

test_that("missing_reason maps types correctly", {
  x <- why_na(c(1.5, NA, 2.3, NA, 3.1), c(0L, 1L, 0L, 2L, 3L))
  result <- missing_reason(x)
  expected <- factor(
    c(0L, 1L, 0L, 2L, 3L),
    levels = 0L:3L,
    labels = c("Observed", "MCAR", "MAR", "MNAR")
  )
  expect_identical(result, expected)
})

test_that("is_mcar/is_mar/is_mnar error on non-informative_na", {
  expect_error(is_mcar(c(1, 2, 3)))
  expect_error(is_mar(c(1, 2, 3)))
  expect_error(is_mnar(c(1, 2, 3)))
})

test_that("missing_reason errors on non-informative_na", {
  expect_error(missing_reason(c(1, 2, 3)))
})

test_that("is_observed returns correct mask", {
  x <- why_na(c(1.5, NA, 2.3, NA), c(0L, 1L, 0L, 2L))
  result <- is_observed(x)
  expect_identical(result, c(TRUE, FALSE, TRUE, FALSE))
})

test_that("is_ignorable returns FALSE only for MNAR", {
  x <- why_na(c(1.5, NA, 2.3, NA, 3.1), c(0L, 1L, 0L, 2L, 3L))
  result <- is_ignorable(x)
  expect_identical(result, c(TRUE, TRUE, TRUE, TRUE, FALSE))
})

test_that("predicates are exhaustive and mutually exclusive", {
  x <- why_na(c(1.5, NA, NA, NA), c(0L, 1L, 2L, 3L))
  obs <- is_observed(x)
  mcar <- is_mcar(x)
  mar <- is_mar(x)
  mnar <- is_mnar(x)
  rowsums <- obs + mcar + mar + mnar
  expect_true(all(rowsums == 1))
})

test_that("missing_summary counts mechanisms correctly", {
  x <- why_na(c(1.5, NA, 2.3, NA, 3.1), c(0L, 1L, 0L, 2L, 3L))
  result <- missing_summary(x)
  expect_equal(nrow(result), 4)
  expect_true(all(result$proportion >= 0 & result$proportion <= 1))
  expect_equal(sum(result$proportion), 1)
})

test_that("missing_summary has correct columns and types", {
  x <- why_na(c(1.5, NA), c(0L, 1L))
  result <- missing_summary(x)
  expect_true(is.factor(result$mechanism))
  expect_true(is.integer(result$n))
  expect_true(is.double(result$proportion))
})

test_that("sentinel_recode maps sentinels correctly", {
  raw <- c("12.5", "-9999", "LOD", "15.1", "NULL-broken")
  x <- sentinel_recode(raw, list("-9999" = "MAR", "LOD" = "MNAR", "NULL-broken" = "MCAR"))
  expect_s3_class(x, "informative_na")
  expect_true(is_mar(x)[2])
  expect_true(is_mnar(x)[3])
  expect_true(is_mcar(x)[5])
  expect_true(is_observed(x)[1])
  expect_true(is_observed(x)[4])
})

test_that("sentinel_recode handles unknown sentinels as observed", {
  raw <- c("12.5", "UNKNOWN", "15.1")
  x <- sentinel_recode(raw, list())
  expect_true(all(is_observed(x)))
})

test_that("sentinel_recode errors on invalid mechanism", {
  raw <- c("12.5", "-9999", "15.1")
  expect_error(
    sentinel_recode(raw, list("-9999" = "INVALID")),
    "Unknown mechanism"
  )
})
