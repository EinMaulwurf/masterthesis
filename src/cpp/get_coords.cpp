#include <Rcpp.h>
#include <vector>
#include <cmath>
#include <algorithm>

//' Generate Grid Cell Centers Around Input Coordinates
//' 
//' For each input coordinate pair, generates all grid cell centers within a 250x250 unit square 
//' centered at the input point, using a specified grid cell size.
//'
//' @param x_mp_vec Numeric vector of x-coordinates for input points
//' @param y_mp_vec Numeric vector of y-coordinates for input points (must match length of x_mp_vec)
//' @param size Grid cell size (width and height) in units. Default = 100.0
//'
//' @return A DataFrame with four columns:
//' \describe{
//'   \item{x_mp_raw}{Original x-coordinates from input}
//'   \item{y_mp_raw}{Original y-coordinates from input}
//'   \item{x_mp}{Generated grid cell center x-coordinates}
//'   \item{y_mp}{Generated grid cell center y-coordinates}
//' }
//' Each row represents a grid cell center generated within 125 units (half of 250) in all directions
//' from the original coordinates, using the specified grid size.
//'
//' @details For each input coordinate (x,y), calculates grid cell centers within a square from 
//' (x-125, y-125) to (x+125, y+125). Grid cells are spaced at intervals of `size` units, offset 
//' by half-size to create center points. The function returns all valid grid cell centers within 
//' this area for all input points.
//'
//' @examples
//' # Generate grid points around a single coordinate
//' get_coords_rcpp(c(500), c(500), size = 100)
//'
//' # Generate grid points for multiple coordinates
//' get_coords_rcpp(c(100, 200), c(300, 400), size = 50)
// [[Rcpp::export]]

Rcpp::DataFrame get_coords_rcpp(Rcpp::NumericVector x_mp_vec,
                                Rcpp::NumericVector y_mp_vec,
                                double size = 100.0) {
  // Check that the input vectors have the same length
  if (x_mp_vec.size() != y_mp_vec.size()) {
    Rcpp::stop("Vectors must have the same length.");
  }
  
  // Precompute size_half
  double size_half = size / 2.0;
  
  // Initialize vectors to store results
  std::vector<double> x_mp_res;
  std::vector<double> y_mp_res;
  std::vector<double> x_mp_new_res;
  std::vector<double> y_mp_new_res;
  
  // Estimate initial capacity (adjust as needed)
  size_t initial_capacity = x_mp_vec.size() * 10;
  x_mp_res.reserve(initial_capacity);
  y_mp_res.reserve(initial_capacity);
  x_mp_new_res.reserve(initial_capacity);
  y_mp_new_res.reserve(initial_capacity);
  
  // Iterate over each element
  for (size_t i = 0; i < x_mp_vec.size(); ++i) {
    double x_mp = x_mp_vec[i];
    double y_mp = y_mp_vec[i];
    
    double x_min = x_mp - 125.0;
    double x_max = x_mp + 125.0;
    double y_min = y_mp - 125.0;
    double y_max = y_mp + 125.0;
    
    // Calculate sequences for x
    double seq_x_start = std::ceil(x_min / size_half) * size_half;
    double seq_x_end = std::floor(x_max / size_half) * size_half;
    std::vector<double> seq_x;
    
    for (double x = seq_x_start; x <= seq_x_end; x += size_half) {
      if (std::fmod(x, size) == size_half) {
        seq_x.push_back(x);
      }
    }
    
    // Calculate sequences for y
    double seq_y_start = std::ceil(y_min / size_half) * size_half;
    double seq_y_end = std::floor(y_max / size_half) * size_half;
    std::vector<double> seq_y;
    
    for (double y = seq_y_start; y <= seq_y_end; y += size_half) {
      if (std::fmod(y, size) == size_half) {
        seq_y.push_back(y);
      }
    }
    
    // Combine sequences (Cartesian product)
    for (auto &x_new : seq_x) {
      for (auto &y_new : seq_y) {
        x_mp_res.push_back(x_mp);
        y_mp_res.push_back(y_mp);
        x_mp_new_res.push_back(x_new);
        y_mp_new_res.push_back(y_new);
      }
    }
  }
  
  // Convert to R vectors
  return Rcpp::DataFrame::create(
    Rcpp::Named("x_mp_raw") = x_mp_res,
    Rcpp::Named("y_mp_raw") = y_mp_res,
    Rcpp::Named("x_mp") = x_mp_new_res,
    Rcpp::Named("y_mp") = y_mp_new_res,
    Rcpp::Named("stringsAsFactors") = false
  );
}