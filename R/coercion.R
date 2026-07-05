# Shared helpers for coercion

wn_ptype2 <- function(x, y) {
  x_val <- vctrs::field(x, "value")
  y_val <- vctrs::field(y, "value")
  v_ptype <- vctrs::vec_ptype2(x_val, y_val)
  new_informative_na(value = v_ptype)
}

wn_cast_from <- function(x, to) {
  v_ptype <- vctrs::field(to, "value")
  v_cast <- vctrs::vec_cast(x, to = v_ptype)
  t_cast <- rep(0L, vctrs::vec_size(v_cast))
  new_informative_na(value = v_cast, type = t_cast)
}

wn_cast_to <- function(x, to) {
  x_val <- vctrs::field(x, "value")
  vctrs::vec_cast(x_val, to = to)
}

# vec_ptype2 dispatchers and methods

#' @export
#' @method vec_ptype2 informative_na
vec_ptype2.informative_na <- function(x, y, ...) {
  UseMethod("vec_ptype2.informative_na")
}

#' @export
#' @method vec_ptype2.informative_na informative_na
vec_ptype2.informative_na.informative_na <- function(x, y, ...) {
  wn_ptype2(x, y)
}

#' @export
#' @method vec_ptype2.informative_na logical
vec_ptype2.informative_na.logical <- function(x, y, ...) {
  wn_ptype2(x, new_informative_na(value = y))
}

#' @export
#' @method vec_ptype2.logical informative_na
vec_ptype2.logical.informative_na <- function(x, y, ...) {
  wn_ptype2(new_informative_na(value = x), y)
}

#' @export
#' @method vec_ptype2.informative_na integer
vec_ptype2.informative_na.integer <- function(x, y, ...) {
  wn_ptype2(x, new_informative_na(value = y))
}

#' @export
#' @method vec_ptype2.integer informative_na
vec_ptype2.integer.informative_na <- function(x, y, ...) {
  wn_ptype2(new_informative_na(value = x), y)
}

#' @export
#' @method vec_ptype2.informative_na double
vec_ptype2.informative_na.double <- function(x, y, ...) {
  wn_ptype2(x, new_informative_na(value = y))
}

#' @export
#' @method vec_ptype2.double informative_na
vec_ptype2.double.informative_na <- function(x, y, ...) {
  wn_ptype2(new_informative_na(value = x), y)
}

#' @export
#' @method vec_ptype2.informative_na character
vec_ptype2.informative_na.character <- function(x, y, ...) {
  wn_ptype2(x, new_informative_na(value = y))
}

#' @export
#' @method vec_ptype2.character informative_na
vec_ptype2.character.informative_na <- function(x, y, ...) {
  wn_ptype2(new_informative_na(value = x), y)
}

#' @export
#' @method vec_ptype2.informative_na complex
vec_ptype2.informative_na.complex <- function(x, y, ...) {
  wn_ptype2(x, new_informative_na(value = y))
}

#' @export
#' @method vec_ptype2.complex informative_na
vec_ptype2.complex.informative_na <- function(x, y, ...) {
  wn_ptype2(new_informative_na(value = x), y)
}

#' @export
#' @method vec_ptype2.informative_na Date
vec_ptype2.informative_na.Date <- function(x, y, ...) {
  wn_ptype2(x, new_informative_na(value = y))
}

#' @export
#' @method vec_ptype2.Date informative_na
vec_ptype2.Date.informative_na <- function(x, y, ...) {
  wn_ptype2(new_informative_na(value = x), y)
}

#' @export
#' @method vec_ptype2.informative_na POSIXct
vec_ptype2.informative_na.POSIXct <- function(x, y, ...) {
  wn_ptype2(x, new_informative_na(value = y))
}

#' @export
#' @method vec_ptype2.POSIXct informative_na
vec_ptype2.POSIXct.informative_na <- function(x, y, ...) {
  wn_ptype2(new_informative_na(value = x), y)
}

#' @export
#' @method vec_ptype2.informative_na difftime
vec_ptype2.informative_na.difftime <- function(x, y, ...) {
  wn_ptype2(x, new_informative_na(value = y))
}

#' @export
#' @method vec_ptype2.difftime informative_na
vec_ptype2.difftime.informative_na <- function(x, y, ...) {
  wn_ptype2(new_informative_na(value = x), y)
}

#' @export
#' @method vec_ptype2.informative_na factor
vec_ptype2.informative_na.factor <- function(x, y, ...) {
  wn_ptype2(x, new_informative_na(value = y))
}

#' @export
#' @method vec_ptype2.factor informative_na
vec_ptype2.factor.informative_na <- function(x, y, ...) {
  wn_ptype2(new_informative_na(value = x), y)
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
  x_val <- vctrs::field(x, "value")
  to_val_ptype <- vctrs::field(to, "value")
  x_val_cast <- vctrs::vec_cast(x_val, to = to_val_ptype)
  new_informative_na(value = x_val_cast, type = vctrs::field(x, "type"))
}

#' @export
#' @method vec_cast.informative_na logical
vec_cast.informative_na.logical <- function(x, to, ...) {
  wn_cast_from(x, to)
}

#' @export
#' @method vec_cast.logical informative_na
vec_cast.logical.informative_na <- function(x, to, ...) {
  wn_cast_to(x, to)
}

#' @export
#' @method vec_cast.informative_na integer
vec_cast.informative_na.integer <- function(x, to, ...) {
  wn_cast_from(x, to)
}

#' @export
#' @method vec_cast.integer informative_na
vec_cast.integer.informative_na <- function(x, to, ...) {
  wn_cast_to(x, to)
}

#' @export
#' @method vec_cast.informative_na double
vec_cast.informative_na.double <- function(x, to, ...) {
  wn_cast_from(x, to)
}

#' @export
#' @method vec_cast.double informative_na
vec_cast.double.informative_na <- function(x, to, ...) {
  wn_cast_to(x, to)
}

#' @export
#' @method vec_cast.informative_na character
vec_cast.informative_na.character <- function(x, to, ...) {
  wn_cast_from(x, to)
}

#' @export
#' @method vec_cast.character informative_na
vec_cast.character.informative_na <- function(x, to, ...) {
  wn_cast_to(x, to)
}

#' @export
#' @method vec_cast.informative_na complex
vec_cast.informative_na.complex <- function(x, to, ...) {
  wn_cast_from(x, to)
}

#' @export
#' @method vec_cast.complex informative_na
vec_cast.complex.informative_na <- function(x, to, ...) {
  wn_cast_to(x, to)
}

#' @export
#' @method vec_cast.informative_na Date
vec_cast.informative_na.Date <- function(x, to, ...) {
  wn_cast_from(x, to)
}

#' @export
#' @method vec_cast.Date informative_na
vec_cast.Date.informative_na <- function(x, to, ...) {
  wn_cast_to(x, to)
}

#' @export
#' @method vec_cast.informative_na POSIXct
vec_cast.informative_na.POSIXct <- function(x, to, ...) {
  wn_cast_from(x, to)
}

#' @export
#' @method vec_cast.POSIXct informative_na
vec_cast.POSIXct.informative_na <- function(x, to, ...) {
  wn_cast_to(x, to)
}

#' @export
#' @method vec_cast.informative_na difftime
vec_cast.informative_na.difftime <- function(x, to, ...) {
  wn_cast_from(x, to)
}

#' @export
#' @method vec_cast.difftime informative_na
vec_cast.difftime.informative_na <- function(x, to, ...) {
  wn_cast_to(x, to)
}

#' @export
#' @method vec_cast.informative_na factor
vec_cast.informative_na.factor <- function(x, to, ...) {
  wn_cast_from(x, to)
}

#' @export
#' @method vec_cast.factor informative_na
vec_cast.factor.informative_na <- function(x, to, ...) {
  wn_cast_to(x, to)
}

# NA detection override

#' @keywords internal
#' @export
#' @method vec_detect_missing informative_na
vec_detect_missing.informative_na <- function(x) {
  vctrs::vec_detect_missing(vctrs::field(x, "value"))
}

#' @keywords internal
#' @export
is.na.informative_na <- function(x) {
  vctrs::vec_detect_missing(vctrs::field(x, "value"))
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
  vctrs::vec_proxy_compare(vctrs::field(x, "value"))
}
