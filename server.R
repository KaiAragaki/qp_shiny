library(ggplot2)
library(qp)
server <- function(input, output, session) {

  data <- reactive({
    req(input$file)
    qp_tidy(
      input$file$datapath,
      replicate_orientation = input$replicate_orientation,
      n_standards = length(strsplit(input$standard_scale, ",")[[1]]),
      n_replicates = input$n_replicates,
      wavelength = input$wavelength
    )
  })

  outliers <- reactive({
    choice <- input$ignore_outliers
    if (all(c("samples", "standards") %in% choice)) {
      rm <- "all"
    } else if (!any(c("samples", "standards") %in% choice)) {
      rm <- "none"
    } else {
      rm <- choice
    }
    qp_mark_outliers(data(), ignore_outliers = rm)
  })

  std_conc <- reactive({
    split_standards <- strsplit(input$standard_scale, ",")[[1]]
    parsed_standards <- stringr::str_squish(split_standards) |> as.numeric()
    qp_add_std_conc(outliers(), parsed_standards)
  })

  fit <- reactive({
    qp_fit(std_conc())
  })

  calc_conc <- reactive({
    qp_calc_conc(fit())
  })

  output$standards_plot <- renderPlot({
    qp_plot_standards(calc_conc())
  })

  output$plate_plot <- renderPlot({
    qp_plot_plate(data(), size = 30) +
      theme_void() +
      theme(
        legend.position = "none",
        plot.margin = unit(c(2, 2, 2, 2), "lines")
      ) +
      coord_cartesian(clip = "off")
  })
}
