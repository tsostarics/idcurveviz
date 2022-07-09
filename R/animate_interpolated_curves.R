#' Animate between interpolated curves
#'
#' Given a list of polynomials, animate how the identification function changes
#'
#' @param betas List of numeric vectors (all of same length)
#' @param nsteps_between Number of steps to interpolate between, integer
#' @param link link function, defaults to `plogis`
#' @param colors Colors to use for the gradient, recommended to provide as many
#' colors as there are curves to interpolate between
#' @param linesize Size for the lines, defaults to 1
#' @param animations `gganimate` `exit_` and `enter_` functions to use, as a list
#'
#' @return Animated ggplot
#' @export
animate_interpolated_curves <- function(betas = list(c(0,0,0),
                                                     c(2,0,0),
                                                     c(2,.5,0),
                                                     c(2,.5,-.15)),
                                        nsteps = 10,
                                        link = plogis,
                                        colors = c('black','blue','gray','red'),
                                        linesize = 1,
                                        animations = list(gganimate::enter_fade(),
                                                          gganimate::exit_disappear())){
  requireNamespace("gganimate", quietly = TRUE)

  n_curves <- length(betas)
  color_vals <- grDevices::colorRampPalette(colors)(nsteps*(n_curves-1))

  stopifnot(n_curves > 1)

  curve_steps <- lapply(seq_len(n_curves-1),
                        \(i)
                        .interpolate_polynomials(from = betas[[i]],
                                                 to = betas[[i+1]],
                                                 nsteps)
  ) |>
    do.call(rbind, args = _)

  poly_strings <- .curve_df_to_strings(curve_steps)

  gradual_lines <-
    lapply(seq_len(nrow(curve_steps)),
           function(i){
             betas <- unlist(curve_steps[i,])
             get_vals <- .get_values_factory(betas, link)
             ggplot2::stat_function(fun = \(x) get_vals(x),
                                    color = color_vals[i],
                                    size = linesize)
           }
    )

  ggplot2::ggplot(data.frame(x = c(-3, 3)),
                  ggplot2::aes(x = x)) +
    gradual_lines +
    ggplot2::theme_minimal() +
    gganimate::transition_layers(from_blank = FALSE,
                                 keep_layers = rep(0,length(gradual_lines)),
                                 layer_names = poly_strings) +
    animations +
    ggplot2::ggtitle("{next_layer}")


}

#' Write out polynomial
#'
#' @param curve_df Data frame defining the curves
#'
#' @return Character vector of polynomials
.curve_df_to_strings <- function(curve_df) {
  n_terms <- ncol(curve_df)
  vapply(seq_len(nrow(curve_df)),
         \(i) .format_poly_string(curve_df[i,]),
         "char")
}

.format_poly_string <- function(betas) {
  paste(round(betas[[1L]], 2L),
        paste0(round(betas[-1L], 2L),
               "x^",
               seq_along(betas[-1L]),
               collapse = " + "),
        sep = " + "
  )
}
