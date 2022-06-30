#' Table of interpolated values
#'
#' Used to create a kind of legend for plots from `plot_interpolated_curves`.
#' Note that the colors used should be the same in order to match the plot.
#'
#' @param from Numeric vector of polynomial terms to start at
#' @param to Numeric vector of polynomial terms to end at
#' @param nsteps Integer number of steps to interpolate between
#' @param precision Rounding precision for table, defaults to 2
#' @param colors Discrete points for a continuous color gradient. Defaults
#' to blue, gray, red (ascending from blue towards red)
#'
#' @return A gt table of the interpolated polynomial coefficients with colored
#' labels following the gradient defined by `colors`
#' @export
table_interpolations <- function(from = c(0,0),
                                 to = c(5,2),
                                 nsteps = 6L,
                                 precision = 2L,
                                 colors = c('blue', 'gray', 'red')) {
  requireNamespace("gt", quietly = TRUE)
  requireNamespace("gtExtras", quietly = TRUE)
  stopifnot(nsteps == as.integer(nsteps))

  polynomial_table <-
    .interpolate_polynomials(from, to, nsteps) |>
    round(precision) |>
    cbind(curve = seq_len(nsteps)) |>
    gt::gt() |>
    gtExtras::gt_color_box(columns = 'curve',
                           palette = colors,
                           domain  = c(1, nsteps))

  polynomial_table
}
