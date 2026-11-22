# Project 2: RDU Air Quality Analysis

Author: Minghui Gao
Date: November 22, 2026

## Purpose

Clean daily air quality measurements and explore patterns
in CO, PM2.5, and ozone using tables and plots.

## Data source

The supplied data come from the EPA air quality monitor
at RDU airport. The files cover 2018, 2019, and
January-April 2020.

## File structure

- data/: original annual CSV files.
- R/process_air_quality.R: annual data cleaning function.
- Gao_Minghui_Project2.Rmd: analysis and report source.
- Gao_Minghui_Project2.docx: knitted Word report.
- output/: cleaned data, summary tables, plots, and software information.

## Reproduce the analysis

1. Open the RStudio project.
2. Install dplyr, tidyr, ggplot2, knitr, and rmarkdown.
3. Open Gao_Minghui_Project2.Rmd.
4. Click Knit to Word.

Keep the original CSV files in the data folder.
All file paths are relative to the project directory.

## Processing decisions

Exact duplicate rows are removed before negative measurements
are set to zero and daily means are calculated.
Missing measurements remain missing.
Ozone is reported in ppm by default; the function also supports ppb.
Monthly confidence intervals pool all available daily values
for each calendar month across years.