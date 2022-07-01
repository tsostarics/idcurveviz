#' Interpolate polynomial terms
#'
#' This is a helper function to interpolate between two endpoints along each
#' polynomial term coefficient.
#'
#' @param from Numeric vector of polynomial terms to start at
#' @param to Numeric vector of polynomial terms to end at
#' @param nsteps Number of steps to interpolate between
#'
#' @return `data.frame` of numeric values where columns correspond to polynomial
#' terms and rows correspond to the interpolated values
.interpolate_polynomials <- function(from = c(0,0),
                                     to = c(5,2),
                                     nsteps = 6) {
  stopifnot(length(from) == length(to))

  lapply(seq_along(from),
         \(i) {
           seq(from[i], to[i], length.out = nsteps)
         }) |>
    as.data.frame(col.names = seq_along(from))
}
