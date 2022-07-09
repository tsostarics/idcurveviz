#' Plot quantized identification curve
#'
#' A quantized curve is an approximation of a continuous curve using a smaller
#' discrete set of points with straight-line interpolations between the points.
#'
#' Plots an identification curve quantized to a given a number of evenly-spaced
#' steps or a given vector of step locations (that don't have to be evenly-spaced).
#'
#'
#'
#' @param betas Numeric vector of polynomial term coefficients
#' @param intercept Intercept to use
#' @param nsteps Number of points to use in the quantized curve
#' @param link Link function to use, defaults to `plogis`
#' @param steps Specific steps to use (i.e., x-values to use)
#' @param center Logical, if `steps` is specified, whether to center the values.
#' Defaults to TRUE.
#' @param expand Logical, whether to expand the x-axis a bit to show more of
#' the identification curve. Defaults to TRUE, if FALSE it will essentially zoom
#' in on the quantized portion.
#' @param curve_color Color to use for the identification curve
#' @param quant_color Color to use for the quantized curve
#' @param curve_linesize Line width for the identification curve, default 1
#' @param quant_linesize Line width for the quantized curve, default .9
#' @param quant_pointsize Point size for the quantized curve, default 3
#' @param hide_curve Logical, defaults to FALSE, whether to hide the identification
#' curve and ONLY show the quantized curve.
#'
#' @return A ggplot of the identification curve with the quantized curve on top
#' of it.
#' @export
#'
#' @examples
#'
#' plot_quantized_curve(c(0, 1, 4, -.1), nsteps = 5)
plot_quantized_curve <- function(betas = c(0, 2, .3),
                                 nsteps = 5,
                                 link = plogis,
                                 steps,
                                 center = TRUE,
                                 expand = TRUE,
                                 curve_color = 'black',
                                 quant_color = 'red',
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

  # Default nudge of 1 if true, 0 if false, else the given expand value
  # Nudges the x axis a bit, useful if the range of the steps is narrow
  nudge <- as.numeric(expand)
  plot_range <- c(min(steps)-nudge, max(steps+nudge))

  if (hide_curve) {
    id_curve <- NULL
  } else {
    id_curve <- ggplot2::stat_function(fun = \(x) get_vals(x),
                                       color = curve_color,
                                       size = curve_linesize)
  }

  ggplot2::ggplot(data.frame(x = plot_range),
                  ggplot2::aes(x = x)) +
    ggplot2::geom_hline(yintercept = c(.5,1,0),
                        linetype = 'solid',
                        size = .25,
                        color = "gray")+
    ggplot2::geom_vline(xintercept = 0,
                        linetype = 'solid',
                        size = .25,
                        color = "gray") +
    id_curve +
    ggplot2::geom_line(data = quant_points,
                       ggplot2::aes(x = x, y = y),
                       inherit.aes = FALSE,
                       color = quant_color,
                       size = quant_linesize) +
    ggplot2::geom_point(data = quant_points,
                        ggplot2::aes(x = x, y = y),
                        inherit.aes = FALSE,
                        color = quant_color,
                        size = quant_pointsize) +
    ggplot2::theme_minimal() +
    ggplot2::theme(panel.grid = ggplot2::element_blank())

}
