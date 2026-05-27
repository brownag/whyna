#' Create an informative NA vector
#'
#' Low-level constructor that creates a vctrs record with value and type fields.
#' Enforces immutability: values with type != 0L are forced to NA_real_.
#'
#' @param value A double vector of values. Will be coerced to double.
#' @param type An integer vector indicating missingness type.
#'   0L = Observed, 1L = MCAR, 2L = MAR, 3L = MNAR.
#'
#' @return A vctrs_rcrd of class informative_na.
#'
#' @keywords internal
#' @export
new_informative_na <- function(value = double(), type = integer()) {
  vctrs::vec_assert(value, ptype = double())
  vctrs::vec_assert(type, ptype = integer())

  if (length(value) != length(type)) {
    rlang::abort("`value` and `type` must have the same length.")
  }

  invalid <- !type %in% 0L:3L
  if (any(invalid, na.rm = TRUE)) {
    rlang::abort(
      "`type` must be 0L (observed), 1L (MCAR), 2L (MAR), or 3L (MNAR)."
    )
  }

  # Force value to NA_real_ for all non-observed types
  value[type != 0L] <- NA_real_

  vctrs::new_rcrd(
    list(value = value, type = type),
    class = "informative_na"
  )
}

#' @rdname new_informative_na
#' @param x A vector to coerce to double (or NULL).
#' @aliases informative_na
#' @export
why_na <- function(x, type = NULL) {
  if (missing(x)) {
    return(new_informative_na())
  }

  x <- vctrs::vec_cast(x, to = double())

  if (is.null(type)) {
    # Auto-detect: observed if not NA, MCAR if NA
    type <- ifelse(is.na(x), 1L, 0L)
  } else {
    type <- vctrs::vec_cast(type, to = integer())
  }

  new_informative_na(value = x, type = type)
}

#' @rdname why_na
#' @export
informative_na <- why_na

