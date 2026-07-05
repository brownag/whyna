test_that("informative_na column in tibble displays with type abbr", {
  skip_if_not_installed("tibble")
  x <- why_na(c(1.5, NA), c(0L, 1L))
  df <- tibble::tibble(val = x)
  output <- capture.output(print(df))
  expect_true(any(grepl("why_dbl", output)))
})

test_that("tibble preserves informative_na class", {
  skip_if_not_installed("tibble")
  x <- why_na(c(1.5, 2.3, NA), c(0L, 0L, 1L))
  df <- tibble::tibble(val = x)
  expect_s3_class(df$val, "informative_na")
})

test_that("tibble slice preserves class", {
  skip_if_not_installed("tibble")
  x <- why_na(c(1.5, 2.3, 3.1), c(0L, 1L, 2L))
  df <- tibble::tibble(val = x)
  result <- df[c(1, 3), ]
  expect_s3_class(result$val, "informative_na")
})

test_that("dplyr::slice preserves class", {
  skip_if_not_installed("dplyr")
  x <- why_na(c(1.5, 2.3, 3.1), c(0L, 1L, 2L))
  df <- tibble::tibble(val = x)
  result <- dplyr::slice(df, 1, 3)
  expect_s3_class(result$val, "informative_na")
})

test_that("is.na() in filter works", {
  skip_if_not_installed("dplyr")
  x <- why_na(c(1.5, 2.3, 3.1), c(0L, 1L, 2L))
  df <- tibble::tibble(val = x)
  result <- dplyr::filter(df, !is.na(val))
  expect_equal(nrow(result), 1)
})

test_that("bind_rows upgrades double to informative_na", {
  skip_if_not_installed("dplyr")
  x <- why_na(c(1.5, 2.3), c(0L, 1L))
  df1 <- tibble::tibble(val = x)
  df2 <- tibble::tibble(val = c(3.1, 4.2))
  result <- dplyr::bind_rows(df1, df2)
  expect_s3_class(result$val, "informative_na")
})

test_that("tibble with multiple columns preserves class", {
  skip_if_not_installed("tibble")
  x <- why_na(c(1.5, 2.3), c(0L, 1L))
  df <- tibble::tibble(a = 1:2, val = x, b = c("x", "y"))
  expect_s3_class(df$val, "informative_na")
})

test_that("filtering preserves type information", {
  skip_if_not_installed("dplyr")
  x <- why_na(c(1.5, NA, 2.3, NA), c(0L, 1L, 0L, 2L))
  df <- tibble::tibble(val = x)
  result <- dplyr::filter(df, is_mcar(val))
  expect_equal(nrow(result), 1)
  expect_identical(vctrs::field(result$val, "type"), 1L)
})
