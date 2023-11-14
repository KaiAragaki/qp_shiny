ui <- fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
  ),
  titlePanel("Quantify Protein"),
  sidebarLayout(
    sidebarPanel(
      fileInput(
        "file", NULL, buttonLabel = "Upload", placeholder = "spectramax.txt"
      ),
      downloadButton("get_report", "Download Report"),
      radioButtons(
        "replicate_orientation", "Replicate Orientation",
        c("Horizonal" = "h", "Vertical" = "v"),
        selected = "h"
      ),
      textAreaInput(
        "sample_names", "Sample Names",
        value = NULL,
        placeholder = "Sample_1, Sample_2, Sample_3...",
        resize = "vertical"
      ),
      checkboxGroupInput(
        "ignore_outliers",
        "Remove Outliers From:",
        choices = c("Samples" = "samples", "Standards" = "standards"),
        selected = c("samples", "standards")
      ),
      numericInput(
        "target_conc", "Target Conc.",
        NULL
      ),
      numericInput(
        "target_vol", "Target Vol. (uL)",
        15
      ),
      textAreaInput(
        "standard_scale",
        "Standard Scale",
        value = "0, 0.125, 0.25, 0.5, 1, 2, 4",
        resize = "vertical"
      ),
      numericInput(
        "n_replicates", "# Replicates",
        3,
        min = 0, max = NA
      ),
      checkboxInput(
        "remove_empty",
        "Remove Empty Wells",
        TRUE
      ),
      numericInput(
        "wavelength", "λ",
        562,
        min = 0, max = 1000
      ),
      width = 2),
    mainPanel(
      tabsetPanel(
        type = "pills",
        tabPanel(
          "Plots",
          fluidRow(
            splitLayout(
              cellWidths = c("50%", "50%"),
              plotOutput("plate_plot", width = "100%"),
              plotOutput("standards_plot", width = "100%")
            )
          ),
          fluidRow(
            column(width = 12, tableOutput("dilution_table"))
          )
        ),
        tabPanel(
          "Samples Table",
          tableOutput("samples_table")
        ),
        tabPanel(
          "All Samples Table",
          tableOutput("samples_table_all")
        ),
      ),
      width = 10
    )
  )
)
