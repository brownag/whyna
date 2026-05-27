#' Extract missingness predicates
#'
#' These functions extract logical masks indicating which values have a specific
#' missingness type (MCAR, MAR, or MNAR).
#'
#' @param x A informative_na vector.
#'
#' @return A logical vector of the same length as x.
#'
#' @examples
#' x <- why_na(c(1.5, NA, 2.3, NA), c(0L, 1L, 0L, 3L))
#' is_mcar(x)   # TRUE where type == 1L
#' is_mar(x)    # TRUE where type == 2L
#' is_mnar(x)   # TRUE where type == 3L
#'
#' @name missing_predicates
NULL

#' @rdname missing_predicates
#' @export
is_observed <- function(x) {
  stopifnot(inherits(x, "informative_na"))
  vctrs::field(x, "type") == 0L
}

#' @rdname missing_predicates
#' @export
is_mcar <- function(x) {
  stopifnot(inherits(x, "informative_na"))
  vctrs::field(x, "type") == 1L
}

#' @rdname missing_predicates
#' @export
is_mar <- function(x) {
  stopifnot(inherits(x, "informative_na"))
  vctrs::field(x, "type") == 2L
}

#' @rdname missing_predicates
#' @export
is_mnar <- function(x) {
  stopifnot(inherits(x, "informative_na"))
  vctrs::field(x, "type") == 3L
}

#' @rdname missing_predicates
#' @export
is_ignorable <- function(x) {
  stopifnot(inherits(x, "informative_na"))
  !is_mnar(x)
}

#' Return missingness type as a factor
#'
#' @param x A informative_na vector.
#'
#' @return A factor with levels "Observed", "MCAR", "MAR", "MNAR".
#'
#' @examples
#' x <- why_na(c(1.5, NA, 2.3, NA), c(0L, 1L, 0L, 3L))
#' missing_reason(x)
#'
#' @export
missing_reason <- function(x) {
  stopifnot(inherits(x, "informative_na"))
  typ <- vctrs::field(x, "type")
  factor(typ,
    levels = 0L:3L,
    labels = c("Observed", "MCAR", "MAR", "MNAR")
  )
}

#' Summarise missingness patterns
#'
#' Returns a data.frame with counts and proportions by missingness mechanism.
#'
#' @param x A informative_na vector.
#'
#' @return A data.frame with columns: `mechanism` (factor), `n` (int), `proportion` (double).
#'
#' @examples
#' x <- why_na(c(1.5, NA, 2.3, NA), c(0L, 1L, 0L, 3L))
#' missing_summary(x)
#'
#' @export
missing_summary <- function(x) {
  stopifnot(inherits(x, "informative_na"))
  r <- missing_reason(x)
  tab <- table(r)
  data.frame(
    mechanism = factor(names(tab), levels = levels(r)),
    n = as.integer(tab),
    proportion = as.double(tab) / length(x)
  )
}

#' Recode sentinel codes to whyna vector
#'
#' Maps domain-specific sentinel codes (e.g., "-9999", "LOD", "Null-broken") to
#' a informative_na vector. Numeric values pass through as observed.
#'
#' @param x A character or numeric vector containing raw data with sentinel codes.
#' @param map A named list mapping sentinel strings to mechanism types.
#'   Values must be "MCAR", "MAR", or "MNAR".
#'   Example: `list("-9999" = "MAR", "LOD" = "MNAR", "NULL-broken" = "MCAR")`.
#'
#' @return A informative_na vector.
#'
#' @examples
#' raw <- c("12.5", "-9999", "LOD", "15.1", "NULL-broken")
#' x <- sentinel_recode(raw, list("-9999" = "MAR", "LOD" = "MNAR", "NULL-broken" = "MCAR"))
#' x
#' missing_summary(x)
#'
#' @export
sentinel_recode <- function(x, map) {
  type_lookup <- c("MCAR" = 1L, "MAR" = 2L, "MNAR" = 3L)
  x_chr <- as.character(x)
  values <- suppressWarnings(as.double(x_chr))
  types <- rep(0L, length(x_chr))

  for (sentinel in names(map)) {
    hit <- x_chr == sentinel
    mech <- map[[sentinel]]
    if (!mech %in% names(type_lookup)) {
      rlang::abort(paste0("Unknown mechanism '", mech, "'. Must be MCAR, MAR, or MNAR."))
    }
    types[hit] <- type_lookup[[mech]]
  }

  new_informative_na(value = values, type = types)
}
