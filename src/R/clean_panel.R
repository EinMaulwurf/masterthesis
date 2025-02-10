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
