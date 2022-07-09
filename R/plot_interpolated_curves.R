#' Plot interpolated identification curves
#'
#' Given starting and ending points for each polynomial term coefficient,
#' generate new curves that are interpolated between the two. The number
#' of total curves is given by `nsteps`. So, if `nsteps=4` then you'll get
#' the 2 endpoint curves passed to the function as well as 2 interpolated
#' curves between those endpoints.
#'
#' Note that this function assumes a single intercept for the time being.
#'
#' @param from Numeric vector of polynomial terms to start at
#' @param to Numeric vector of polynomial terms to end at
#' @param nsteps Number of steps to interpolate between
#' @param intercept Intercept to use
#' @param link Link function to use, defaults to plogis (i.e., logit link)
#' @param colors Discrete points for a continuous color gradient. Defaults
#' to blue, gray, red (ascending from blue towards red)
#' @param linesize Width of the lines to use. Defaults to 1, but you may
#' want to decrease if plotting many lines
#'
#' @return A ggplot of the interpolated curves
#' @export
#'
#' @examples
#'
#' plot_interpolated_curves(c(0,0,0), to = c(2, 1, -3))
plot_interpolated_curves <- function(from = c(0,0),
                                     to = c(5,2),
                                     nsteps = 6L,
                                     intercept = 0,
                                     link = plogis,
                                     colors = c('blue', 'gray', 'red'),
                                     linesize = 1){
  color_vals <- grDevices::colorRampPalette(colors)(nsteps)

  stopifnot(length(from) == length(to)) # change later to pad 0s

  betas <- .interpolate_polynomials(from, to, nsteps)

  gradual_lines <-
    lapply(seq_len(nsteps),
           function(i){
             betas <- unlist(betas[i,])
             get_vals <- .get_values_factory(betas, intercept, link)
             ggplot2::stat_function(fun = \(x) get_vals(x),
                                    color = color_vals[i],
                                    size = linesize)
           }
    )

  from_label <- paste0(from, paste("x", seq_along(from), sep = "^"), collapse = " + ")
  to_label <- paste0(to, paste("x", seq_along(to), sep = "^"), collapse = " + ")

  plot_title <- glue::glue("from:  {from_label}  ({colors[1]})
                           to:  {to_label}  ({colors[length(colors)]})
                           intercept: {intercept}")

  ggplot2::ggplot(data.frame(x = c(-3, 3)),
                  ggplot2::aes(x = x)) +
    ggplot2::geom_hline(yintercept = c(.5,1,0),
                        linetype = 'solid',
                        size = .25,
                        color = "gray") +
    ggplot2::stat_function(fun = \(x) plogis(x),
                           color = 'black',
                           linetype = 'dashed',
                           size = .75) +
    gradual_lines +
    ggplot2::theme_minimal() +
    ggplot2::labs(subtitle = plot_title) +
    ggplot2::theme(panel.grid = ggplot2::element_blank())
}

