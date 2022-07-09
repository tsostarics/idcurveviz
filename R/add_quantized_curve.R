#' Add another quantized curve to quantized curve plot
#'
#' Same usage as `plot_quantized_curve` but only returns the ggplot layers
#' for the curve and quantized curve. This can be added to a previously made
#' plot from `plot_quantized_curve` to show two curves, or two different
#' quantizations.
#'
#' @param betas Numeric vector of polynomial term coefficients
#' @param nsteps Number of points to use in the quantized curve
#' @param link Link function to use, defaults to `plogis`
#' @param steps Specific steps to use (i.e., x-values to use)
#' @param center Logical, if `steps` is specified, whether to center the values.
#' Defaults to TRUE.
#' @param curve_color Color to use for the identification curve
#' @param quant_color Color to use for the quantized curve
#' @param curve_linesize Line width for the identification curve, default 1
#' @param quant_linesize Line width for the quantized curve, default .9
#' @param quant_pointsize Point size for the quantized curve, default 3
#' @param hide_curve Logical, defaults to FALSE, whether to hide the identification
#' curve and ONLY show the quantized curve.
#'
#' @return ggplot layers for an identification curve and its quantized curve
#' @export
#'
#' @examples
#'
#' plot_quantized_curve(c(1,0,1), 0, 5) +
#' add_quantized_curve(c(2,0,2), 0, 5, curve_color = "blue")
add_quantized_curve <- function(betas = c(0, 2, .3),
                                nsteps = 5,
                                link = plogis,
                                steps,
                                center = TRUE,
                                curve_color = "black",
                                quant_color = "red",
                                curve_linesize = 1,
                                quant_linesize = .9,
                                quant_pointsize = 3,
                                hide_curve = FALSE) {
  if (!missing(steps)) {
    # If steps are given, override nsteps for # of points then center values
    nsteps = length(steps)
    if (center) {
      steps <- as.vector(scale(steps, TRUE, FALSE))
    }
  } else {
    # If steps aren't provided, use a default value of -3 to 3
    steps <- seq(-3, 3, length.out = nsteps)
  }

  # Generates curve values for the given parameters
  get_vals <- .get_values_factory(betas, link)

  # Calculates the points for the quantization lines/points
  quant_points <- data.frame(x = steps, y = get_vals(steps))

  if (hide_curve) {
    id_curve <- NULL
  } else {
    id_curve <- ggplot2::stat_function(fun = \(x) get_vals(x),
                                       color = curve_color,
                                       size = curve_linesize)
  }

  list(id_curve,
       ggplot2::geom_line(data = quant_points,
                          ggplot2::aes(x = x, y = y),
                          inherit.aes = FALSE,
                          color = quant_color,
                          size = quant_linesize),
       ggplot2::geom_point(data = quant_points,
                           ggplot2::aes(x = x, y = y),
                           inherit.aes = FALSE,
                           color = quant_color,
                           size = quant_pointsize)
  )
}
