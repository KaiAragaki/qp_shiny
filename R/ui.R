ui <- fluidPage(
  titlePanel("Quantify Protein"),
  sidebarLayout(
      sidebarPanel(
          radioButtons(
              "replicate_orientation", "Replicate orientation",
              c("Horizonal" = "h", "Vertical" = "v"),
              selected = "h"
          ),
          textAreaInput(
              "sample_names", "Sample names",
              value = "Sample_1; Sample_2; Sample_3..."
          ),
          checkboxInput("remove_empty", "Remove empty wells from analysis?", TRUE),
          checkboxGroupInput(
              "ignore_outliers",
              "Remove outliers from which subset(s) during concentration calculation?",
              c("Samples" = "samples", "Standards" = "standards"),
              c(TRUE, TRUE)
          ),
          textAreaInput(
              "standard_scale",
              "Known concentrations of standards, in the order they appear",
              value = "0, 0.125, 0.25, 0.5, 1, 2, 4"
          ),
          numericInput("n_replicates", "Number of technical replicates",
              3,
              min = 0, max = NA
          ),
          numericInput("wavelength", "Wavelength (nm) of absorbance captured",
              562,
              min = 0, max = 1000
          ),
        width = 2),
    mainPanel()
  )
)
