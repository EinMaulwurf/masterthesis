library(dplyr)

# Only keeps longest consecutive observation chains for each individual
clean_panel <- function(data, id_var, time_var, keep_ties = c("all", "first", "last")) {
  # Match the keep_ties argument
  keep_ties <- match.arg(keep_ties)
  
  data %>%
    arrange({{ id_var }}, {{ time_var }}) %>%
    group_by({{ id_var }}) %>%
    mutate(
      consec_group = cumsum(c(TRUE, diff({{ time_var }}) > 1))
    ) %>%
    group_by({{ id_var }}, consec_group) %>%
    mutate(
      group_length = n(),
      group_start = min({{ time_var }})
    ) %>%
    group_by({{ id_var }}) %>%
    mutate(
      max_group_length = max(group_length),
      # Rank groups by start time for tie-breaking
      group_rank = case_when(
        keep_ties == "first" ~ rank(group_start, ties.method = "first"),
        keep_ties == "last" ~ rank(-group_start, ties.method = "first"),
        TRUE ~ 1L # Placeholder for "all"
      )
    ) %>%
    filter(
      group_length == max_group_length,
      if(keep_ties != "all") group_rank == 1 else TRUE
    ) %>%
    ungroup() %>%
    select(-consec_group, -group_length, -max_group_length, -group_start, -group_rank)
}

# create a balanced panel by trimming observations to a specified length and direction
create_balanced_panel <- function(data, id_var, time_var, length, trim_from = c("end", "start")) {
  trim_from <- match.arg(trim_from)
  
  data %>%
    # First identify valid sequences
    arrange({{ id_var }}, {{ time_var }}) %>%
    group_by({{ id_var }}) %>%
    mutate(
      consec_group = cumsum(c(TRUE, diff({{ time_var }}) > 1))
    ) %>%
    group_by({{ id_var }}, consec_group) %>%
    mutate(
      group_length = n(),
      group_start = min({{ time_var }}),
      group_end = max({{ time_var }})
    ) %>%
    group_by({{ id_var }}) %>%
    filter(max(group_length) >= length) %>%
    # Find best candidate group for trimming
    mutate(
      valid_groups = group_length >= length,
      candidate = if(trim_from == "end") {
        # Prefer later groups with sufficient length
        group_start == max(group_start[valid_groups])
      } else {
        # Prefer earlier groups with sufficient length
        group_start == min(group_start[valid_groups])
      }
    ) %>%
    filter(candidate) %>%
    # Trim to desired length
    group_by({{ id_var }}, consec_group) %>%
    {
      if(trim_from == "end") {
        slice_tail(., n = length)
      } else {
        slice_head(., n = length)
      }
    } %>%
    ungroup() %>%
    select(-consec_group, -group_length, -group_start, -group_end, -valid_groups, -candidate)
}

# for simulations
simulate_panel <- function(n_ids = 15, 
                           n_time = 10, 
                           treatment_percentage = 0.5, 
                           treatment_groups = NULL, 
                           base_slopes = c(1, 1), 
                           seed = NULL) {
  
  # Input validation
  if (!is.numeric(n_ids) || length(n_ids) != 1 || n_ids <= 0 || n_ids %% 1 != 0) {
    stop("n_ids must be a positive integer")
  }
  if (!is.numeric(n_time) || length(n_time) != 1 || n_time <= 0 || n_time %% 1 != 0) {
    stop("n_time must be a positive integer")
  }
  if (!is.numeric(treatment_percentage) || length(treatment_percentage) != 1 || 
      treatment_percentage < 0 || treatment_percentage > 1) {
    stop("treatment_percentage must be a numeric value between 0 and 1")
  }
  if (!is.null(seed) && (!is.numeric(seed) || length(seed) != 1)) {
    stop("seed must be NULL or a single numeric value")
  }
  if (!is.numeric(base_slopes) || length(base_slopes) != 2) {
    stop("base_slopes must be a numeric vector of length 2")
  }
  
  # Set default treatment groups if not provided
  if (is.null(treatment_groups)) {
    treatment_groups <- tibble(
      group = 1,
      treatment_time = 5,
      treatment_multiplier = 1.5,
      treatment_jump = 0
    )
  } else {
    # Validate treatment_groups structure
    required_cols <- c("group", "treatment_time", "treatment_multiplier", "treatment_jump")
    if (!all(required_cols %in% colnames(treatment_groups))) {
      stop("treatment_groups must contain columns: group, treatment_time, treatment_multiplier, treatment_jump")
    }
    if (any(duplicated(treatment_groups$group))) {
      stop("treatment_groups must have unique group identifiers")
    }
  }
  
  # Set seed if specified
  if (!is.null(seed)) set.seed(seed)
  
  # Calculate number of treated units
  n_treated <- ceiling(n_ids * treatment_percentage)
  
  # Check treatment_groups validity when needed
  if (n_treated > 0 && nrow(treatment_groups) == 0) {
    stop("treatment_groups must have at least one group when there are treated units")
  }
  
  # Assign treated IDs to groups
  if (n_treated == 0) {
    treated_assignments <- tibble(id = integer(),
                                  group = integer(),
                                  treatment_time = integer(),
                                  treatment_multiplier = numeric(),
                                  treatment_jump = numeric())
  } else {
    treated_assignments <- treatment_groups %>%
      slice(rep(1:n(), length.out = n_treated)) %>%
      mutate(id = 1:n_treated) %>%
      select(id, everything())
  }
  
  # Create base slopes vector
  base_slopes_vector <- c(rep(base_slopes[1], n_treated), 
                          rep(base_slopes[2], n_ids - n_treated))
  
  # Generate panel data
  expand_grid(
    id = 1:n_ids,
    time = 1:n_time
  ) %>%
    left_join(treated_assignments, by = "id") %>%
    mutate(
      first_treat = if_else(!is.na(treatment_time), treatment_time, 0),
      treat = if_else(first_treat != 0 & time >= first_treat, 1, 0),
      slope = base_slopes_vector[id],
      treatment_multiplier = coalesce(treatment_multiplier, 1),
      treatment_jump = coalesce(treatment_jump, 0)
    ) %>%
    group_by(id) %>%
    mutate(
      y = if_else(
        treat == 0,
        slope * time + rnorm(n(), 0, 0.5),
        slope * first_treat + 
          slope * treatment_multiplier * (time - first_treat) + 
          treatment_jump + 
          rnorm(n(), 0, 0.5)
      )
    ) %>%
    ungroup() %>%
    select(time, id, y, treat, first_treat)
}
