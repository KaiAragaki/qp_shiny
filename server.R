library(ggplot2)
library(dplyr)
library(stringr)
library(bladdr)
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

  with_names <- reactive({
    if (!isTruthy(input$sample_names)) {
      qp_add_names(std_conc())
    } else {
      split_samples <- strsplit(input$sample_names, ",")[[1]]
      parsed_samples <- stringr::str_squish(split_samples)
      qp_add_names(std_conc(), parsed_samples)
    }
  })

  fit <- reactive({
    qp_fit(with_names())
  })

  calc_conc <- reactive({
    qp_calc_conc(fit())
  })

  conditional_rm <- reactive({
    if (input$remove_empty) {
      qp_remove_empty(calc_conc())
    } else {
      calc_conc()
    }
  })

  output$standards_plot <- renderPlot({
    qp_plot_standards(conditional_rm()) +
      theme_minimal() +
      theme(
        text = element_text(size = 15)
      ) +
      labs(color = "Sample Type", shape = "Outlier")
  }, bg = "#FFFFFF44")

  output$plate_plot <- renderPlot({
    qp_plot_plate(data(), size = 15) +
      theme_void() +
      theme(
        legend.position = "none",
        plot.margin = unit(c(2, 2, 2, 2), "lines")
      ) +
      coord_cartesian(clip = "off")
  }, bg = "#FFFFFF44")

  output$samples_table <- renderTable({
    qp_summarize(conditional_rm()$qp)
  })
  output$samples_table_all <- renderTable({
    conditional_rm()$qp
  })
  output$dilution_table <- renderTable({
    if (!isTruthy(input$target_conc)) {
      qp_dilute(
        qp_summarize(conditional_rm()$qp),
        target_conc = NULL,
        input$target_vol,
        remove_standards = TRUE
      ) |>
        select(Name = .sample_name,
               `Mean Conc` = .pred_conc_mean,
               `Sample to Add` = sample_to_add,
               `Add to` = add_to)
    } else {
      qp_dilute(
        qp_summarize(conditional_rm()$qp),
        input$target_conc, input$target_vol,
        remove_standards = TRUE
      ) |>
        select(Name = .sample_name,
               `Mean Conc` = .pred_conc_mean,
               `Sample to Add` = sample_to_add,
               `Add to` = add_to)
    }
  })

  make_filename <- reactive({
    str_replace(input$file$name, "\\..*$", "_report.html")
  })

  output$get_report <- downloadHandler(
    filename = function() {
      make_filename()
    },
    content = function(file) {
      params <- list(
        file = input$file,
        sample_orientation = input$replicate_orientation,
        sample_names = input$sample_names,
        ignore_outliers = input$ignore_outliers,
        target_vol = input$target_vol,
        target_conc = input$target_conc,
        standard_scale = input$standard_scale,
        replicates = input$n_replicates,
        remove_empty = input$remove_empty,
        wavelength = input$wavelength
      )
      qp_report(conditional_rm() |>
                  qp_dilute(input$target_conc, input$target_vol),
                file, params)
    }
  )
}
