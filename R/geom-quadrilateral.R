#' @import ggplot2
NULL


GeomQuadrilateral <- ggproto("GeomQuadrilateral", Geom,
  required_aes = c("x1", "y1", "x2", "y2",
                  "x3", "y3", "x4", "y4"),
  default_aes = aes(colour  = NA, fill = "grey35", size = 0.5, linetype = 1, alpha=NA),
  setup_data = function(data, params){
    # Make sure that the plot is properly scaled
    if(! "xmax" %in% names(data)){
      data$xmax <- pmax(data$x1, data$x2, data$x3, data$x4)
    }
    if(! "xmin" %in% names(data)){
      data$xmin <- pmin(data$x1, data$x2, data$x3, data$x4)
    }
    if(! "ymax" %in% names(data)){
      data$ymax <- pmax(data$y1, data$y2, data$y3, data$y4)
    }
    if(! "ymin" %in% names(data)){
      data$ymin <- pmin(data$y1, data$y2, data$y3, data$y4)
    }
    data
  },
  draw_panel = function(data, panel_params, coord, linejoin = "mitre"){
    data_trnsf <- rescale_custom_positions(data, panel_params)
    coords <- coord$transform(data_trnsf, panel_params)
    grid::polygonGrob(
      c(coords$x1, coords$x2, coords$x3, coords$x4, coords$x1),
      c(coords$y1, coords$y2, coords$y3, coords$y4, coords$y1),
      # Note that the order in x and y is weird...
      id = rep(seq_len(nrow(coords)), times=5),
      gp = grid::gpar(
        col = coords$colour,
        fill = alpha(coords$fill, coords$alpha),
        lwd = coords$size * .pt,
        lty = coords$linetype,
        linejoin = linejoin,
        # `lineend` is a workaround for Windows and intentionally kept unexposed
        # as an argument. (c.f. https://github.com/tidyverse/ggplot2/issues/3037#issuecomment-457504667)
        lineend = if (identical(linejoin, "round")) "round" else "square"
      )
    )
  },
  draw_key = draw_key_polygon
)

#' Quadrilaterals
#'
#' The geom is similar to `geom_rect` and `geom_tile` but can take
#' arbitrary positions of four corners.
#'
#' @inheritParams ggplot2::geom_tile
#'
#'
#' @examples
#'  library(ggplot2)
#'  df <- data.frame(id = LETTERS[1:11],
#'                   left = seq(0, 10),
#'                   right = seq(1, 11),
#'                   yleft_top = 0,
#'                   yright_top = seq(1, 11))
#'  ggplot(df, aes(fill=id), color="black") +
#'    geom_quadrilateral(aes(x1 = left, y1 = 0, x2 = left, y2 = yleft_top,
#'                           x3 = right, y3 = yright_top, x4 = right, y4 = 0,
#'                           alpha=right))
#'
#' @export
geom_quadrilateral <- function(mapping = NULL, data = NULL, stat = "identity",
                               position = "identity", ...,
                               linejoin = "mitre",
                               na.rm = FALSE, show.legend = NA,
                               inherit.aes = TRUE) {
  layer(
    geom = GeomQuadrilateral, mapping = mapping,  data = data, stat = stat,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(linejoin = linejoin, na.rm = na.rm, ...)
  )
}

# Copied from ggplot source

rescale_custom_positions <- function(data, panel_params){
  rescale_x <- function(data) scales::rescale(data, from = panel_params$x.range)
  rescale_y <- function(data) scales::rescale(data, from = panel_params$y.range)
  transform_custom_position(data, rescale_x, rescale_y)
}


transform_custom_position <- function (df, trans_x = NULL, trans_y = NULL, ...) {
  oldclass <- class(df)
  df <- unclass(df)
  scales <- custom_aes_to_scale(names(df))
  if (!is.null(trans_x)) {
    df[scales == "x"] <- lapply(df[scales == "x"], trans_x,
                                ...)
  }
  if (!is.null(trans_y)) {
    df[scales == "y"] <- lapply(df[scales == "y"], trans_y,
                                ...)
  }
  class(df) <- oldclass
  df
}

custom_aes_to_scale <- function (var) {
  var[var %in% c("x1", "x2", "x3", "x4")] <- "x"
  var[var %in% c("y1", "y2", "y3", "y4")] <- "y"
  var
}
