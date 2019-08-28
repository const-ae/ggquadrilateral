test_that("quadrilateral geom works", {
  df <- data.frame(id = LETTERS[1:11],
         left = seq(0, 10),
         right = seq(1, 11),
         yleft_top = 0,
         yright_top = seq(1, 11))
  ggplot(df, aes(fill=id)) +
    geom_quadrilateral(aes(x1 = left, y1 = 0, x2 = left, y2 = yleft_top,
                           x3 = right, y3 = yright_top, x4 = right, y4 = 0,
                           alpha=right), color="black")

})
