library(ggplot2)
library(rmarkdown)
library(knitr)
library(gt)
library(dplyr)
library(stringr)
library(bladdr)
library(qp)
report_path <- tempfile(fileext = ".Rmd")

file.copy(
  system.file(
    "rmarkdown/templates/quantify-protein-report/skeleton/skeleton.Rmd",
    package = "qp"
  ),
  report_path,
  overwrite = TRUE
)

file.copy(
  system.file(
    "rmarkdown/templates/quantify-protein-report/skeleton/style.css",
    package = "qp"
  ),
  tempdir(),
  overwrite = TRUE
)


render_report <- function(input, output, params) {
  rmarkdown::render(
    input,
    output_file = output,
    params = params,
    envir = new.env(parent = globalenv())
  )
}
