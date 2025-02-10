#' Create LAEA-aligned Grid from Spatial Object
#'
#' @param obj An sf object with LAEA CRS (EPSG:3035)
#' @param size Grid cell size ("100m" or "1km"), default: "1km"
#' 
#' @return An sf grid object aligned to LAEA coordinates
#' @export

make_laea_grid <- function(obj, size = c("1km", "100m")) {
  # Validate inputs
  if (!inherits(obj, "sf")) {
    stop("Input object must be an sf object")
  }
  
  # Convert character size to numeric meters
  size <- match.arg(size)
  cell_size <- switch(size,
                      "100m" = 100,
                      "1km" = 1000,
                      stop("Invalid size. Use '100m' or '1km'")
  )
  
  # Verify CRS is LAEA (EPSG:3035)
  if (is.na(st_crs(obj))) {
    warning("Object has no CRS - assuming EPSG:3035 (LAEA)")
    obj <- st_set_crs(obj, 3035)
  } else if (!identical(st_crs(obj)$epsg, 3035L)) {
    stop("Object CRS must be EPSG:3035 (LAEA)")
  }
  
  # Calculate grid offset for alignment
  bbox <- st_bbox(obj)
  offset_x <- floor(bbox["xmin"] / cell_size) * cell_size - (cell_size / 2)
  offset_y <- floor(bbox["ymin"] / cell_size) * cell_size - (cell_size / 2)
  
  # Create grid with precise alignment
  st_make_grid(
    obj,
    cellsize = cell_size,
    offset = c(offset_x, offset_y),
    what = "polygons"
  )
}
