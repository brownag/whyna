#' Format method for informative_na
#'
#' @param x A informative_na vector.
#' @param ... Additional arguments passed to [format()].
#' @keywords internal
#' @export
format.informative_na <- function(x, ...) {
  val <- vctrs::field(x, "value")
  typ <- vctrs::field(x, "type")

  # Format observed values numerically
  out <- format(val, ...)

  # Replace with missingness type labels
  out[typ == 1L] <- "<NA:MCAR>"
  out[typ == 2L] <- "<NA:MAR>"
  out[typ == 3L] <- "<NA:MNAR>"

  out
}

#' @rdname format.informative_na
#' @keywords internal
#' @export
vec_ptype_abbr.informative_na <- function(x, ...) {
  val_ptype <- vctrs::field(x, "value")
  val_abbr <- vctrs::vec_ptype_abbr(val_ptype, ...)
  paste0("why_", val_abbr)
}

#' @rdname format.informative_na
#' @keywords internal
#' @export
vec_ptype_full.informative_na <- function(x, ...) {
  val_ptype <- vctrs::field(x, "value")
  val_full <- vctrs::vec_ptype_full(val_ptype, ...)
  paste0("informative_na<", val_full, ">")
}
