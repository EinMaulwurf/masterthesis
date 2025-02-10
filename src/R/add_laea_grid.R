add_laea_grid <- function(obj, size = 100, x_mp = "x_mp", y_mp = "y_mp") {
  obj %>%
    st_as_sf(coords = c(x_mp, y_mp), crs = 3035) %>%
    st_buffer(dist = size/2, endCapStyle = "SQUARE")
}

get_breitband_stadt("Darmstadt", size = "1km", variables = down_fn_hh_ftthb_1000) %>%
  filter(date == 202312) %>%
  add_laea_grid(size = 1000) %>%
  ggplot()+
  geom_sf(aes(fill = down_fn_hh_ftthb_1000), color = NA)+
  scale_fill_viridis_c()