library(ggplot2)
library(qp)
server <- function(input, output, session) {
  output$plate_plot <- renderPlot({
      qp_plot_plate(
        qp_tidy(
          input$file$datapath,
          replicate_orientation = input$replicate_orientation,
          n_standards = length(strsplit(input$standard_scale, ",")[[1]]),
          n_replicates = input$n_replicates,
          wavelength = input$wavelength
        ),
        size = 30
      ) +
        theme_void() +
        theme(
          legend.position = "none",
          plot.margin = unit(c(2, 2, 2, 2), "lines")
        ) +
        coord_cartesian(clip = "off")
  })
  output$wavelength <- renderText({ input$wavelength })
}
