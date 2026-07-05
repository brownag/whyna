test_that("c() combines same type", {
  x <- why_na(c(1.5, 2.3), c(0L, 1L))
  y <- why_na(c(3.1, 4.2), c(0L, 2L))
  result <- c(x, y)
  expect_s3_class(result, "informative_na")
  expect_length(result, 4)
})

test_that("c() upgrades double to informative_na", {
  x <- why_na(c(1.5, 2.3), c(0L, 1L))
  y <- c(3.1, 4.2)
  result <- c(x, y)
  expect_s3_class(result, "informative_na")
  expect_length(result, 4)
})

test_that("c() upgrades informative_na when first", {
  x <- why_na(c(1.5, 2.3), c(0L, 1L))
  y <- c(3.1, 4.2)
  result <- c(x, y)
  expect_s3_class(result, "informative_na")
})

test_that("vec_c() combines in any order", {
  x <- why_na(c(1.5, 2.3), c(0L, 1L))
  y <- c(3.1, 4.2)
  result1 <- vctrs::vec_c(x, y)
  result2 <- vctrs::vec_c(y, x)
  expect_s3_class(result1, "informative_na")
  expect_s3_class(result2, "informative_na")
})

test_that("c() with character errors", {
  x <- why_na(c(1.5, 2.3), c(0L, 1L))
  y <- c("a", "b")
  expect_error(
    c(x, y),
    class = "vctrs_error_incompatible_type"
  )
})

test_that("c() with logical promotes to double", {
  x <- why_na(c(1.5, 2.3), c(0L, 1L))
  y <- c(TRUE, FALSE)
  result <- c(x, y)
  expect_s3_class(result, "informative_na")
  expect_equal(typeof(vctrs::field(result, "value")), "double")
})

test_that("[subsetting preserves class", {
  x <- why_na(c(1.5, 2.3, 3.1, 4.2), c(0L, 1L, 2L, 3L))
  result <- x[c(1, 3)]
  expect_s3_class(result, "informative_na")
  expect_length(result, 2)
})

test_that("[subsetting preserves type field", {
  x <- why_na(c(1.5, 2.3, 3.1), c(0L, 1L, 2L))
  result <- x[c(1, 3)]
  typ <- vctrs::field(result, "type")
  expect_identical(typ, c(0L, 2L))
})

test_that("cast to double extracts value field", {
  x <- why_na(c(1.5, 2.3), c(0L, 1L))
  result <- vctrs::vec_cast(x, to = double())
  expect_type(result, "double")
  expect_length(result, 2)
  expect_identical(result, c(1.5, NA_real_))
})

test_that("cast to double silently extracts value field", {
  x <- why_na(c(1.5, 2.3), c(0L, 1L))
  result <- vctrs::vec_cast(x, to = double())
  expect_identical(result, c(1.5, NA_real_))
})

test_that("ptype2 same type returns empty informative_na", {
  x <- why_na(c(1.5, 2.3), c(0L, 1L))
  y <- why_na(c(3.1, 4.2), c(2L, 3L))
  result <- vctrs::vec_ptype2(x, y)
  expect_s3_class(result, "informative_na")
  expect_length(result, 0)
})

test_that("ptype2 informative_na and double returns informative_na", {
  x <- why_na(c(1.5, 2.3), c(0L, 1L))
  y <- c(3.1, 4.2)
  result1 <- vctrs::vec_ptype2(x, y)
  result2 <- vctrs::vec_ptype2(y, x)
  expect_s3_class(result1, "informative_na")
  expect_s3_class(result2, "informative_na")
})

test_that("vec_proxy_equal makes unique() type-aware", {
  x <- why_na(c(1.5, NA, NA), c(0L, 1L, 3L))
  result <- unique(x)
  expect_length(result, 3)
  expect_true(is_mcar(result)[2])
  expect_true(is_mnar(result)[3])
})

test_that("vec_proxy_equal treats different NA types as distinct in unique()", {
  x <- why_na(c(NA, NA), c(1L, 3L))
  result <- unique(x)
  expect_length(result, 2)
})

test_that("vec_proxy_equal makes duplicated() type-aware", {
  x <- why_na(c(1.5, NA, NA, 1.5), c(0L, 1L, 1L, 0L))
  result <- duplicated(x)
  expect_identical(result, c(FALSE, FALSE, TRUE, TRUE))
})

test_that("vec_proxy_compare makes sort() preserve observed order", {
  x <- why_na(c(3, NA, 1, NA, 2), c(0L, 1L, 0L, 3L, 0L))
  result <- sort(x)
  obs_values <- result[!is.na(result)]
  expect_identical(vctrs::field(obs_values, "value"), c(1, 2, 3))
})

test_that("vec_proxy_compare enables sorting mixed observed and NA values", {
  x <- why_na(c(5, NA, 2, NA, 8), c(0L, 1L, 0L, 3L, 0L))
  result <- sort(x)
  expect_s3_class(result, "informative_na")
  expect_equal(vctrs::field(result, "value")[1], 2)
  expect_equal(vctrs::field(result, "value")[2], 5)
  expect_equal(vctrs::field(result, "value")[3], 8)
})
