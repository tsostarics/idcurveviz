#' Plot bivariate identification surface
#'
#' Given coefficients and intercepts for 2 polynomials, plots a 3d surface of
#' the crossed continua. Quantized points can also be added by setting
#' `show_quantized_points` to TRUE (the default). Adding the points is handled
#' by `add_quantized_surface()` but it's a pain to pass all the (mostly same)
#' arguments to two functions.
#'
#' @param betas1 Numeric vector of polynomial term coefficients for polynomial 1
#' @param betas2 Numeric vector of polynomial term coefficients for polynomial 2
#' @param domain1 Numeric vector of length 2 for start and end points of the domain
#' of polynomial 1, defaults to `c(-3, 3)`
#' @param domain2 Numeric vector of length 2 for start and end points of the domain
#' of polynomial 2, defaults to `c(-3, 3)`
#' @param label1 Label to use for polynomial 1's axis, defaults to `X1`
#' @param label2 Label to use for polynomial 2's axis, defaults to `X2`
#' @param labeldv Label to use for the vertical dependent variable between 0 and
#' 1, defaults to `Probability`
#' @param link Link function to use, defaults to `plogis`
#' @param smooth_by Numeric value to use to interpolate steps along the polynomial
#' axes, defaults to `.1` (i.e., `seq(-3, 3, by=.1)`)
#' @param nsteps Number of steps to interpolate between for quantized points,
#' defaults to `5`
#' @param steps1 Numeric vector of step values for polynomial 1
#' @param steps2 Numeric vector of step values for polynomial 2
#' @param point_colors Character vector of color names to create a gradient
#' between, defaults to `c('blue','gray','red')`
#' @param color_by Either 1 to color the points by each step along `X1` or 2
#' to color by each step along `X2`. Bivariate gradient currently not supported.
#' @param show_quantized_points Logical, defaults to `TRUE`, whether to show
#' the quantized points. Wireframes are too much effort so all there is are the
#' points, unfortunately.
#'
#' @return Plotly figure of a bivariate surface
#' @export
plot_bivariate_surface <- function(betas1 = c(0, 1, .25, -.01),
                                   betas2 = c(0, 2, -.25, -.01),
                                   domain1 = c(-3, 3),
                                   domain2 = c(-3, 3),
                                   label1 = "X1",
                                   label2 = "X2",
                                   labeldv = "Probability",
                                   link = plogis,
                                   smooth_by = .1,
                                   nsteps = 5,
                                   steps1,
                                   steps2,
                                   point_colors = c('blue','gray','red'),
                                   color_by = 1L,
                                   show_quantized_points = TRUE) {
  requireNamespace("plotly", quietly = TRUE)


  f1 <- .get_values_factory(betas1, \(x) x)
  f2 <- .get_values_factory(betas2, \(x) x)

  stopifnot(length(domain1) == 2L)
  stopifnot(length(domain2) == 2L)

  x1seq <- seq(domain1[1L], domain1[2L], by=smooth_by)
  x2seq <- seq(domain2[1L], domain2[2L], by=smooth_by)

  surface_df <- expand.grid(x1 = x1seq, x2 = x2seq)
  colnames(surface_df) <- c(label1, label2)

  surface_df[['y1']] <- f1(surface_df[[label1]])
  surface_df[['y2']] <- f2(surface_df[[label2]])
  surface_df[[labeldv]] <- link(surface_df[['y1']] + surface_df[['y2']])


  fig <-
    surface_df |>
    plotly::plot_ly(x = stats::as.formula(paste0("~",label1)), # there has to be a better way than this
                    y = stats::as.formula(paste0("~",label2)),
                    z = stats::as.formula(paste0("~",labeldv)),
                    intensity = stats::as.formula(paste0("~",labeldv)),
                    type='mesh3d')

  if (show_quantized_points){
    parent_args <- as.list(match.call())[-1]
    fig <- do.call("add_quantized_surface",
                   args = c(plotly_fig = list(fig), parent_args))
  }

  fig
}

#' Add quantized bivariate surface
#'
#' Add quantized points to a given surface
#'
#' @param plotly_fig Plotly figure to add to, result of `plot_bivariate_surface`
#' @param betas1 Numeric vector of polynomial term coefficients for polynomial 1
#' @param betas2 Numeric vector of polynomial term coefficients for polynomial 2
#' @param domain1 Numeric vector of length 2 for start and end points of the domain
#' of polynomial 1, defaults to `c(-3, 3)`
#' @param domain2 Numeric vector of length 2 for start and end points of the domain
#' of polynomial 2, defaults to `c(-3, 3)`
#' @param label1 Label to use for polynomial 1's axis, defaults to `X1`
#' @param label2 Label to use for polynomial 2's axis, defaults to `X2`
#' @param labeldv Label to use for the vertical dependent variable between 0 and
#' 1, defaults to `Probability`
#' @param link Link function to use, defaults to `plogis`
#' @param smooth_by Numeric value to use to interpolate steps along the polynomial
#' axes, defaults to `.1` (i.e., `seq(-3, 3, by=.1)`)
#' @param nsteps Number of steps to interpolate between for quantized points,
#' defaults to `5`
#' @param steps1 Numeric vector of step values for polynomial 1
#' @param steps2 Numeric vector of step values for polynomial 2
#' @param point_colors Character vector of color names to create a gradient
#' between, defaults to `c('blue','gray','red')`
#' @param color_by Either 1 to color the points by each step along `X1` or 2
#' to color by each step along `X2`. Bivariate gradient currently not supported.
#' @param show_quantized_points Holdover from `plot_bivariate_surface`, does
#' nothing here
#'
#' @return Plotly figure with a point trace added
#' @export
add_quantized_surface <- function(plotly_fig,
                                  betas1 = c(0, 1, .25, -.01),
                                  betas2 = c(0, 2, -.25, -.01),
                                  domain1 = c(-3, 3),
                                  domain2 = c(-3, 3),
                                  label1 = "X1",
                                  label2 = "X2",
                                  labeldv = "Probability",
                                  link = plogis,
                                  smooth_by = .1,
                                  nsteps = 5,
                                  steps1,
                                  steps2,
                                  point_colors = c('blue','gray','red'),
                                  color_by = 1L,
                                  show_quantized_points = TRUE) {
  f1 <- .get_values_factory(betas1, \(x) x)
  f2 <- .get_values_factory(betas2, \(x) x)

  if (missing(steps1)) {
    x1seq_quant <- seq(domain1[1L], domain1[2L], length.out=nsteps)
  } else {
    x1seq_quant <- steps1
  }

  if (missing(steps2)) {
    x2seq_quant <- seq(domain2[1L], domain2[2L], length.out=nsteps)
  } else {
    x2seq_quant <- steps2
  }

  points_df <-
    expand.grid(x1 = x1seq_quant,
                x2 = x2seq_quant)

  stopifnot(color_by %in% c(1, 2))

  key <- paste0("x", color_by)
  color_seq <- get(paste0(key, "seq_quant"))

  color_df <- data.frame(x1 = color_seq)
  color_df[['color']] <- grDevices::colorRampPalette(point_colors)(length(color_seq))

  points_df <- merge(points_df,
                     color_df,
                     by.x = key,
                     by.y = 'x1')

  colnames(points_df)[1L:2L] <- c(label1, label2)

  points_df[['y1']] <- f1(points_df[[label1]])
  points_df[['y2']] <- f2(points_df[[label2]])
  points_df[[labeldv]] <- link(points_df[['y1']] + points_df[['y2']])


  plotly::add_trace(p = plotly_fig,
                    data = points_df,
                    intensity = NULL,
                    type = 'scatter3d',
                    mode = 'markers',
                    marker = list(color = ~color))
}
