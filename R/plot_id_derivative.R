#' Plot identification curve with rate of change curve
#'
#' Plots the identification curve with given polynomial term coefficients
#' and intercept along with the first derivative approximation from
#' `numDeriv::grad`, reflecting the rate of change in the identification curve.
#'
#' Take note of the double y-axis.
#'
#' @param betas Numeric vector of polynomial term coefficients
#' @param intercept Intercept to use
#' @param link Link function, defaults to `plogis`
#' @param domain Domain of the x-axis for the function, default `c(-3, 3)`
#' @param smooth_by Precision of the numeric sequence between the domain ends
#' @param curve_color Color of the identification curve and left y-axis,
#' default `'black'`
#' @param deriv_color Color of the rate of change curve and right y-axis,
#' default `'royalblue4`
#'
#' @return A ggplot with the identification curve and rate of change curve
#' @export
plot_id_derivative <- function(betas = c(1,0,-10),
                               intercept = 0,
                               link = plogis,
                               domain = c(-3, 3),
                               smooth_by = .1,
                               curve_color = "black",
                               deriv_color = "royalblue4") {
  requireNamespace("numDeriv", quietly = TRUE)
  requireNamespace("tidyr", quietly = TRUE)
  curve_fx <- .get_values_factory(betas, intercept, link)
  xseq <- seq(domain[1L], domain[2L], by = smooth_by)

  curves_df <- data.frame(x = xseq,
                          y = curve_fx(xseq),
                          rate = numDeriv::grad(curve_fx, xseq))

  ylabels <- .make_derivative_ylabs(curves_df)

  curves_df |>
    tidyr::pivot_longer(c('y','rate'),
                        names_to = 'fx',
                        values_to = 'value') |>
    ggplot2::ggplot(ggplot2::aes(x = x,
                                 y=value,
                                 color = fx)) +
    ggplot2::geom_line(size = .9) +
    ggplot2::theme_minimal() +
    ggplot2::scale_x_continuous(breaks = seq(domain[1L], domain[2L], by =1),
                                labels = seq(domain[1L], domain[2L], by =1)) +
    ggplot2::scale_y_continuous(
      name = "Probability",
      breaks = ylabels[["breaks"]],
      labels = ylabels[["labels"]],
      sec.axis = ggplot2::sec_axis(trans = ~.,
                                   breaks = ylabels[["breaks"]],
                                   labels = ylabels[["breaks"]],
                                   name="Rate of Change\ny'")
    ) +
    ggplot2::scale_color_discrete(type=c(deriv_color,
                                         curve_color)) +
    ggplot2::theme(
      axis.text.y.right = ggplot2::element_text(color = deriv_color),
      axis.title.y.right = ggplot2::element_text(color = deriv_color),
      axis.title.y.left = ggplot2::element_text(hjust = ylabels[["hjust"]],
                                                color = curve_color),
      legend.position = 'none',
      panel.grid.minor = ggplot2::element_blank()
    ) +
    ggplot2::coord_cartesian(ylim = c(min(ylabels[["breaks"]]),
                                      max(ylabels[["breaks"]])))


}

#' Calculate y-axis breaks and labels
#'
#' Helper to get the y-axis breaks, labels, and justification
#'
#' @param curves_df Dataframe with the y and yprime values
#'
#' @return A list with breaks, labels, and hjust values
.make_derivative_ylabs <- function(curves_df) {
  yaxis_breaks <- c(seq(min(c(0,round(min(curves_df[['rate']]),1))),0, by=.5),
                    seq(0,1,by=.25),
                    seq(1, max(1, round(max(curves_df[['rate']]),1)+.5), by = .5))
  yaxis_breaks <- yaxis_breaks[!duplicated(yaxis_breaks)]
  yaxis_labels <- as.character(yaxis_breaks)
  yaxis_labels[yaxis_breaks<0 | yaxis_breaks > 1] <- ""

  label_hjust <- which(yaxis_breaks==.5)/length(yaxis_breaks)

  list(breaks = yaxis_breaks,
       labels = yaxis_labels,
       hjust = label_hjust)
}


