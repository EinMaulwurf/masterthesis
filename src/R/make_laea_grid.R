make_laea_grid <- function(obj, size = 100) {
  obj_bbox <- st_bbox(obj)
  obj_offset_x <- floor(obj_bbox["xmin"]/size)*size - (size/2)
  obj_offset_y <- floor(obj_bbox["ymin"]/size)*size - (size/2)
  
  st_make_grid(obj, cellsize = size, offset = c(obj_offset_x, obj_offset_y))
}

# Beispiel
darmstadt %>%
  make_laea_grid(size = 1000) %>%
  ggplot()+
  geom_sf()+
  geom_sf(data = darmstadt, fill = NA)