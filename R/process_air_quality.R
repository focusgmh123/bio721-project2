# Clean one year of RDU air quality measurements.
process_air_quality <- function(file_path, ozone_units = "ppm") {
  
  # Check the requested ozone unit.
  ozone_units <- match.arg(ozone_units, c("ppm", "ppb"))
  
  # Import data while preserving original column names.
  raw <- read.csv(
    file_path,
    check.names = FALSE,
    stringsAsFactors = FALSE,
    na.strings = c("", "NA")
  )
  
  # Remove exact duplicate source rows before calculating means.
  raw <- dplyr::distinct(raw)
  
  # Check original units.
  stopifnot(
    all(na.omit(raw$units_CO) == "ppm"),
    all(na.omit(raw$units_PM) == "ug/m3 LC"),
    all(na.omit(raw$units_O3) == "ppm")
  )
  
  # Rename and select variables.
  clean <- raw |>
    dplyr::transmute(
      date = as.Date(Date, format = "%m/%d/%Y"),
      CO = `Daily Max 8-hour CO Concentration`,
      PM25 = `Daily Mean PM2.5 Concentration`,
      O3 = `Daily Max 8-hour Ozone Concentration`
    )
  
  if (anyNA(clean$date)) {
    stop("Some dates could not be parsed.")
  }
  
  # Replace negative individual measurements before averaging.
  pollutants <- c("CO", "PM25", "O3")
  
  for (pollutant in pollutants) {
    negative <- !is.na(clean[[pollutant]]) &
      clean[[pollutant]] < 0
    
    clean[[pollutant]][negative] <- 0
  }
  
  # Preserve missingness when every measurement is missing.
  safe_mean <- function(x) {
    if (all(is.na(x))) {
      return(NA_real_)
    }
    
    mean(x, na.rm = TRUE)
  }
  
  # Calculate one mean per pollutant per day.
  daily <- clean |>
    dplyr::group_by(date) |>
    dplyr::summarise(
      dplyr::across(
        dplyr::all_of(pollutants),
        safe_mean
      ),
      .groups = "drop"
    )
  
  # Add absent dates within the observed period.
  # Do not create May-December observations for 2020.
  daily <- daily |>
    tidyr::complete(
      date = seq.Date(
        min(date),
        max(date),
        by = "day"
      )
    ) |>
    dplyr::arrange(date)
  
  # Convert ozone units if requested.
  if (ozone_units == "ppb") {
    daily$O3 <- daily$O3 * 1000
  }
  
  daily$units_O3 <- ozone_units
  
  return(daily)
}