#' Create an informative NA vector
#'
#' Low-level constructor that creates a vctrs record with value and type fields.
#' Enforces immutability: values with type != 0L are forced to their type's NA.
#'
#' @param value A vector of values. Supported types: logical, integer, double,
#'   character, complex, Date, POSIXct, difftime, factor. Will coerce to double if omitted.
#' @param type An integer vector indicating missingness type.
#'   0L = Observed, 1L = MCAR, 2L = MAR, 3L = MNAR.
#'
#' @return A vctrs_rcrd of class informative_na.
#'
#' @keywords internal
#' @export
new_informative_na <- function(value = double(), type = integer()) {
  if (!vctrs::vec_is(value)) {
    rlang::abort("`value` must be a vector.")
  }

  if (inherits(value, c("list", "data.frame", "vctrs_rcrd"))) {
    rlang::abort("`value` cannot be a list, data.frame, or rcrd.")
  }

  vctrs::vec_assert(type, ptype = integer())

  if (vctrs::vec_size(value) != vctrs::vec_size(type)) {
    rlang::abort("`value` and `type` must have the same length.")
  }

  invalid <- !type %in% 0L:3L
  if (any(invalid, na.rm = TRUE)) {
    rlang::abort(
      "`type` must be 0L (observed), 1L (MCAR), 2L (MAR), or 3L (MNAR)."
    )
  }

  # Force value to its type's NA for all non-observed types
  idx <- which(type != 0L)
  if (length(idx) > 0L) {
    value <- vctrs::vec_assign(
      value,
      idx,
      vctrs::vec_init(vctrs::vec_ptype(value), 1L)
    )
  }

  vctrs::new_rcrd(
    list(value = value, type = type),
    class = "informative_na"
  )
}

#' @rdname new_informative_na
#' @param x A vector (optional). If omitted, returns an empty double whyna.
#'   Type is preserved; use `ptype` for explicit casting.
#' @param ptype A prototype vector. If provided, `x` is cast to this type before construction.
#' @aliases informative_na
#' @export
why_na <- function(x, type = NULL, ptype = NULL) {
  if (missing(x)) {
    return(new_informative_na())
  }

  x <- vctrs::vec_cast(x, to = ptype %||% x)

  if (is.null(type)) {
    # Auto-detect: observed if not missing, MCAR if missing
    type <- ifelse(vctrs::vec_detect_missing(x), 1L, 0L)
  } else {
    type <- vctrs::vec_cast(type, to = integer())
    type <- vctrs::vec_recycle(type, size = vctrs::vec_size(x))
  }

  new_informative_na(value = x, type = type)
}

#' @rdname why_na
#' @export
informative_na <- why_na

