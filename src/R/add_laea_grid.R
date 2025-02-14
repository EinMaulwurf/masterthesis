#' Convert Data Frame to LAEA Grid Polygons
#'
#' @param obj A data frame/tibble with coordinate columns
#' @param size Grid cell size ("100m" or "1km"), default: "1km"
#' @param x_mp Name of x-coordinate column
#' @param y_mp Name of y-coordinate column
#'
#' @return An sf object with square polygon geometry
#' @export

add_laea_grid <- function(obj, size = c("1km", "100m"), x_mp = "x_mp", y_mp = "y_mp") {
  # Input validation pipeline
  if (!inherits(obj, "data.frame")) {
    stop("Input object must be a data frame or tibble")
  }

  if (!all(c(x_mp, y_mp) %in% names(obj))) {
    stop(paste("Missing coordinate columns:", x_mp, "and/or", y_mp))
  }

  # Validate and convert size parameter
  size <- match.arg(size)
  grid_size <- switch(size,
    "100m" = 100,
    "1km" = 1000,
    stop("Invalid grid size. Use '100m' or '1km'")
  )

  # CRS definition (LAEA Europe EPSG:3035)
  laea_crs <- 3035

  # Create sf object and buffer
  sf_obj <- sf::st_as_sf(
    obj,
    coords = c(x_mp, y_mp),
    remove = FALSE,
    crs = laea_crs
  )

  sf::st_buffer(
    sf_obj,
    dist = grid_size / 2,
    endCapStyle = "SQUARE"
  )
}
