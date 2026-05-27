# vec_ptype2 dispatchers and methods

#' @export
#' @method vec_ptype2 informative_na
vec_ptype2.informative_na <- function(x, y, ...) {
  UseMethod("vec_ptype2.informative_na")
}

#' @export
#' @method vec_ptype2.informative_na informative_na
vec_ptype2.informative_na.informative_na <- function(x, y, ...) {
  new_informative_na()
}

#' @export
#' @method vec_ptype2.informative_na double
vec_ptype2.informative_na.double <- function(x, y, ...) {
  new_informative_na()
}

#' @export
#' @method vec_ptype2.double informative_na
vec_ptype2.double.informative_na <- function(x, y, ...) {
  new_informative_na()
}

# vec_cast dispatchers and methods

#' @export
#' @method vec_cast informative_na
vec_cast.informative_na <- function(x, to, ...) {
  UseMethod("vec_cast.informative_na")
}

#' @export
#' @method vec_cast.informative_na informative_na
vec_cast.informative_na.informative_na <- function(x, to, ...) {
  x
}

#' @export
#' @method vec_cast.informative_na double
vec_cast.informative_na.double <- function(x, to, ...) {
  why_na(x)
}

#' @export
#' @method vec_cast.double informative_na
vec_cast.double.informative_na <- function(x, to, ...) {
  vctrs::field(x, "value")
}

# NA detection override

#' @keywords internal
#' @export
#' @method vec_detect_missing informative_na
vec_detect_missing.informative_na <- function(x) {
  is.na(vctrs::field(x, "value"))
}

#' @keywords internal
#' @export
is.na.informative_na <- function(x) {
  is.na(vctrs::field(x, "value"))
}

# Implement c() method to use vctrs::vec_c
#' @keywords internal
#' @export
c.informative_na <- function(..., recursive = FALSE, use.names = TRUE) {
  vctrs::vec_c(...)
}

# Proxy methods for equality and comparison

#' @export
#' @method vec_proxy_equal informative_na
vec_proxy_equal.informative_na <- function(x, ...) {
  data.frame(
    value = vctrs::field(x, "value"),
    type = vctrs::field(x, "type")
  )
}

#' @export
#' @method vec_proxy_compare informative_na
vec_proxy_compare.informative_na <- function(x, ...) {
  vctrs::field(x, "value")
}
