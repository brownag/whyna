test_that("new_informative_na creates empty vector by default", {
  x <- new_informative_na()
  expect_s3_class(x, "informative_na")
  expect_length(x, 0)
})

test_that("new_informative_na accepts value and type vectors", {
  x <- new_informative_na(c(1.5, 2.3), c(0L, 1L))
  expect_length(x, 2)
  expect_identical(vctrs::field(x, "value"), c(1.5, NA_real_))
  expect_identical(vctrs::field(x, "type"), c(0L, 1L))
})

test_that("type != 0L forces value to NA_real_", {
  x <- new_informative_na(c(5.5, 6.6, 7.7), c(0L, 1L, 2L))
  val <- vctrs::field(x, "value")
  expect_equal(val[1], 5.5)
  expect_true(is.na(val[2]))
  expect_true(is.na(val[3]))
})

test_that("length mismatch errors", {
  expect_error(
    new_informative_na(c(1.0, 2.0), c(0L, 1L, 2L)),
    "must have the same length"
  )
})

test_that("invalid type errors", {
  expect_error(
    new_informative_na(c(1.0), c(4L)),
    "0L \\(observed\\)"
  )
})

test_that("informative_na auto-detects missing", {
  x <- why_na(c(1.5, NA, 2.3))
  typ <- vctrs::field(x, "type")
  expect_identical(typ, c(0L, 1L, 0L))
})

test_that("informative_na coerces to double", {
  x <- why_na(c(1, 2, 3), c(0L, 1L, 2L))
  expect_s3_class(x, "informative_na")
  val <- vctrs::field(x, "value")
  expect_type(val, "double")
})

test_that("is.na() works correctly", {
  x <- new_informative_na(c(1.5, 2.3, 3.1), c(0L, 1L, 2L))
  expect_identical(is.na(x), c(FALSE, TRUE, TRUE))
})
