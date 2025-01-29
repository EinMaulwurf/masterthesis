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