#' Plot an identification curve
#'
#' Plots an identification curve using the given polynomial terms and
#' intercepts. If no intercepts are given, a preset range of -3 to 3 will be
#' plotted. A reference curve of link(1x+0) is shown in a dashed line.
#'
#' Link function should be of the `p*` family of functions, such as
#' `pnorm`, `plogis`, `plaplace` etc.
#'
#' @param betas Numeric vector of polynomial term coefficients
#' @param intercepts Intercepts to use when plotting the same polynomial terms
#' with different intercepts
#' @param colors Discrete points for a continuous color gradient. Defaults
#' to blue, gray, red (ascending from blue towards red)
#' @param link Link function to use, defaults to plogis (i.e., logit link)
#' @param linesize Width of the lines to use. Defaults to 1.
#'
#' @return A ggplot of the plotted polynomials
#' @export
#'
#' @examples
#'
#' plot_id_curve(c(2, .2, -.3), 0)
#'
#' @importFrom stats plogis
plot_id_curve <- function(betas,
                          intercepts,
                          colors = c('blue','gray','red'),
                          link = plogis,
                          linesize = 1){

  # The vector of beta terms is given in order of polynomial coefficients
  # e.g., c(3, 2, 1) = 3x + 2x^2 + 1x^3
  get_vals <- .get_values_factory(betas, 0, link)

  # If no intercepts are given, use a preset range of values and colors
  if (missing(intercepts)) {
    colors = c('black','blue','red','blue','red')
    intercepts = c(0,1,3,-1,-3)

    # Save intercepts to use in plot subcaption
    intercept_labels <- paste0(intercepts, collapse = ", ")
  }

  # If colors aren't provided for the given intercepts, use these values
  if (missing(colors)) {
    if (length(intercepts) == 1){
      colors <- 'red'
    } else {
      colors <- grDevices::colorRampPalette(colors)(length(intercepts))
    }
  }

  # If c(...) is passed use ..., otherwise use the call passed to the function
  # Helps to avoid lots of numbers printed when eg seq(-3, 3, by = .1) is used
  if (identical(eval(substitute(intercepts)[[1]]), base::c)){
    intercept_labels <- paste0(intercepts, collapse = ", ")
  } else {
    intercept_labels <- deparse(substitute(intercepts))
  }


  stopifnot(length(colors) == length(intercepts))

  # Create ggplot layers for the curves for each intercept w/ the given colors
  curves <- lapply(seq_along(colors),
                   \(i) {
                     ggplot2::stat_function(fun = \(x) get_vals(x, intercepts[i]),
                                            color = colors[i],
                                            size = linesize)
                   })

  # Paste together the coefficient terms
  plot_title <- paste0(betas,
                       paste0("x^", seq_len(length(betas))),
                       collapse = " + ")

  plot_subcaption <- glue::glue("Link fx = {deparse(substitute(link))}
                                intercepts = {intercept_labels}")

  ggplot2::ggplot(data.frame(x = c(-3, 3)),
                  ggplot2::aes(x = x)) +
    ggplot2::geom_hline(yintercept = c(.5,1,0),
                        linetype = 'solid',
                        size = .25,
                        color = "gray")+
    ggplot2::stat_function(fun = \(x) link(x), color = 'black',
                           linetype = 'dashed',
                           size = .75) +
    curves +
    ggplot2::theme_minimal() +
    ggplot2::ggtitle(plot_title,
                     subtitle = plot_subcaption) +
    ggplot2::theme(panel.grid = ggplot2::element_blank())
}
