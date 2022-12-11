#' Get cups
#'
#' Get a list of all cups per season.
#'
#' @param season Character. Indicating the season
#' by the last two digits of two following years, e.g. "1819" for 2018-2019.
#'
#' @return A data.frame. Lists all cups of the queried season.
#' @importFrom magrittr `%>%`
#' @export
#'
#' @examples
#' get_cups("2122")
get_cups <- function(season) {
  base_url <- "http://biathlonresults.com/modules/sportapi/api/"

  q <- paste0(base_url, "Cups?SeasonId=", season)

  r <- tryCatch(
    {
      httr::GET(
        q,
        httr::add_headers(.headers = c("Content-Type" = "application/json"))
      ) %>%
        httr::content()
    },
    error = function(e) {
      message(paste0("An error occured while calling getPost: ", e))
      NA
    }
  )

  df <- dplyr::bind_rows(r)

  return(df)
}




#' Get cup results
#'
#' Get past or current standings in a Cup.
#'
#' @param cup_id Character. Cup identifier.
#' Find it by calling [get_cups()].
#'
#' @return A data.frame. Listing the standings for the queried cup.
#' @importFrom magrittr `%>%`
#' @export
#'
#' @examples
#' get_cup_results("BT2122SWRLCP__SWTS")
get_cup_results <- function(cup_id) {
  base_url <- "http://biathlonresults.com/modules/sportapi/api/"

  q <- paste0(base_url, "CupResults?CupId=", cup_id)

  r <- tryCatch(
    {
      httr::GET(
        q,
        httr::add_headers(.headers = c("Content-Type" = "application/json"))
      ) %>%
        httr::content()
    },
    error = function(e) {
      message(paste0("An error occured while calling getPost: ", e))
      NA
    }
  )

  if (!is.na(r)[[1]]) {
    # bind results
    cup_results <- dplyr::bind_rows(r$Rows)
    # save "meta" info
    cup_info <- r[!(names(r) %in% c("Rows"))] %>%
      dplyr::bind_cols() %>%
      dplyr::rename_with(~ paste0("Cup.", .x))

    df <- dplyr::bind_cols(cup_results, cup_info)
  } else {
    df <- data.frame()
  }

  return(df)
}




#' Search athletes
#'
#' Search for athletes by name.
#'
#' @param family_name Character. Family name.
#' @param given_name  Character. First name. Default is NULL.
#'
#' @return A data.frame. Listing all matches.
#' @importFrom magrittr `%>%`
#' @export
#'
#' @examples
#' search_athletes("boe")
search_athletes <- function(family_name, given_name = NULL) {
  base_url <- "http://biathlonresults.com/modules/sportapi/api/"

  q <- paste0(base_url, "Athletes?FamilyName=", family_name, "&GivenName=", given_name)

  r <- tryCatch(
    {
      httr::GET(
        q,
        httr::add_headers(.headers = c("Content-Type" = "application/json"))
      ) %>%
        httr::content()
    },
    error = function(e) {
      message(paste0("An error occured while calling getPost: ", e))
      NA
    }
  )

  if (!is.na(r)[[1]]) {
    df <- dplyr::bind_rows(r$Athletes)
  } else {
    df <- data.frame()
  }

  return(df)
}




#' Get bios
#'
#' Get a wide range of athlete-specific data.
#'
#' @param ibu_id Character. IBU athlete ID.
#' Find it, e.g. by calling [search_athletes()] first.
#'
#' @return A list.
#' @details Note: The list includes a wide range of information, nested in further lists
#' which is time-consuming to expand into one 'tidy' data.frame.
#' To get more specific information in tidy format, use the
#' functions [get_stats()], [get_recent()], and [get_ranks()].
#' @importFrom magrittr `%>%`
#' @export
#'
#' @examples
#' get_cisbios("BTNOR11605199301")
get_cisbios <- function(ibu_id) {
  base_url <- "http://biathlonresults.com/modules/sportapi/api/"

  q <- paste0(base_url, "CISBios?IBUId=", ibu_id)

  r <- tryCatch(
    {
      httr::GET(
        q,
        httr::add_headers(.headers = c("Content-Type" = "application/json"))
      ) %>%
        httr::content()
    },
    error = function(e) {
      message(paste0("An error occured while calling getPost: ", e))
      NA
    }
  )


  return(r)
}





#' Get stats
#'
#' Get the athlete's shooting and skiing stats for the last four seasons.
#'
#' @param ibu_id Character. IBU athlete ID.
#' Find it, e.g. by calling [search_athletes()] first.
#'
#' @return A data.frame. Lists overall shooting and skiing performance stats.
#' @importFrom magrittr `%>%`
#' @export
#'
#' @examples
#' get_stats("BTNOR11605199301")
get_stats <- function(ibu_id) {
  base_url <- "http://biathlonresults.com/modules/sportapi/api/"

  q <- paste0(base_url, "CISBios?IBUId=", ibu_id)

  r <- tryCatch(
    {
      httr::GET(
        q,
        httr::add_headers(.headers = c("Content-Type" = "application/json"))
      ) %>%
        httr::content()
    },
    error = function(e) {
      message(paste0("An error occured while calling getPost: ", e))
      NA
    }
  )


  if (!is.na(r)[[1]]) {
    ## Athlete basic data
    athlete <- r[lapply(r, typeof) != "list"] %>% dplyr::bind_rows()
    # Stats for the last 4 seasons
    s <- r[lapply(r, length) == 4] # subset list to all elements of lenth 4
    stats <- lapply(s[lapply(names(s), stringr::str_detect, "Stat*") == T], unlist) %>% dplyr::bind_rows() # further subsetting to lists staring with Stats
    # Bind
    df <- dplyr::bind_cols(athlete, stats)
  } else {
    df <- data.frame()
  }

  return(df)
}



#' Get recent results
#'
#' Get the athlete's recent performaces in races.
#'
#' @param ibu_id Character. IBU athlete ID.
#' Find it, e.g. by calling [search_athletes()] first.
#'
#' @return A data.frame. Lists recent race results.
#' @importFrom magrittr `%>%`
#' @export
#'
#' @examples
#' get_recent("BTNOR11605199301")
get_recent <- function(ibu_id) {
  base_url <- "http://biathlonresults.com/modules/sportapi/api/"

  q <- paste0(base_url, "CISBios?IBUId=", ibu_id)

  r <- tryCatch(
    {
      httr::GET(
        q,
        httr::add_headers(.headers = c("Content-Type" = "application/json"))
      ) %>%
        httr::content()
    },
    error = function(e) {
      message(paste0("An error occured while calling getPost: ", e))
      NA
    }
  )


  if (!is.na(r)[[1]]) {
    ## Athlete basic data
    athlete <- r[lapply(r, typeof) != "list"] %>% dplyr::bind_rows()
    # Get recent results
    recent <- r$Recent %>% dplyr::bind_rows()
    # Bind
    df <- dplyr::bind_cols(athlete, recent)
  } else {
    df <- data.frame()
  }

  return(df)
}



#' Get ranks
#'
#' Get the athlete's cumulative ranks
#'
#' @param ibu_id Character. IBU athlete ID.
#' Find it, e.g. by calling [search_athletes()] first.
#'
#' @return A data.frame. Lists (incomplete?) cumulative ranks of the athlete.
#' The variable 'Description' indicates the ranks.
#' @details Note: Due to lacking API documentation, it is somewhat unclear what is returned here.
#' If you need a complete list of all results of that athlete, use the call [get_results()].
#' @importFrom magrittr `%>%`
#' @export
#'
#' @examples
#' get_ranks("BTNOR11605199301")
get_ranks <- function(ibu_id) {
  base_url <- "http://biathlonresults.com/modules/sportapi/api/"

  q <- paste0(base_url, "CISBios?IBUId=", ibu_id)

  r <- tryCatch(
    {
      httr::GET(
        q,
        httr::add_headers(.headers = c("Content-Type" = "application/json"))
      ) %>%
        httr::content()
    },
    error = function(e) {
      message(paste0("An error occured while calling getPost: ", e))
      NA
    }
  )


  if (!is.na(r)[[1]]) {
    ## Athlete basic data
    athlete <- r[lapply(r, typeof) != "list"] %>% dplyr::bind_rows()
    # Get cumulative ranks
    ranks <- r$RNKS %>% dplyr::bind_rows()
    if (nrow(ranks) == 0) ranks <- data.frame(Total = NA)

    # Bind
    df <- dplyr::bind_cols(athlete, ranks)
  } else {
    df <- data.frame()
  }

  return(df)
}



#' Get results per athlete
#'
#' @param ibu_id Character. IBU athlete ID.
#' Find it, e.g. by calling [search_athletes()] first.
#'
#' @return A data.frame. Lists all race results of an athlete.
#' @importFrom magrittr `%>%`
#' @export
#'
#' @examples
#' get_results("BTNOR11605199301")
get_results <- function(ibu_id) {
  base_url <- "http://biathlonresults.com/modules/sportapi/api/"

  q <- paste0(base_url, "AllResults?IBUId=", ibu_id)

  r <- tryCatch(
    {
      httr::GET(
        q,
        httr::add_headers(.headers = c("Content-Type" = "application/json"))
      ) %>%
        httr::content()
    },
    error = function(e) {
      message(paste0("An error occured while calling getPost: ", e))
      NA
    }
  )


  if (!is.na(r)[[1]]) {
    # IBUid
    id <- data.frame(IBUId = r$IBUId)
    # Get all results
    results <- r$Results %>% dplyr::bind_rows()

    if (nrow(results) == 0) {
      results <- data.frame(
        RaceID = NA,
        Season = NA,
        Comp = NA,
        Level = NA,
        Place = NA,
        PlaceNat = NA,
        Rank = NA,
        SO = NA,
        Pen = NA,
        Shootings = NA
      )
    }

    # Bind
    df <- dplyr::bind_cols(id, results)
  } else {
    df <- data.frame()
  }

  return(df)
}



#' Get events
#'
#' Get schedule of events per season.
#'
#' @param season_id Character. Indicating the season
#' by the last two digits of two following years, e.g. "1819" for 2018-2019.
#' @param level Integer.  Indicates the Cup level. \itemize{
#'   \item 0: All.
#'   \item 1: World Cup.
#'   \item 2: IBU Cup.
#'   \item 3: Junior Cup.
#'   \item 4: Other.
#'   }
#' @return A data.frame.
#' @importFrom magrittr `%>%`
#' @export
#'
#' @examples
#' get_events("2223", "1")
get_events <- function(season_id, level = 0) {
  base_url <- "http://biathlonresults.com/modules/sportapi/api/"

  q <- paste0(base_url, "Events?SeasonId=", season_id, "&Level=", level)

  r <- tryCatch(
    {
      httr::GET(
        q,
        httr::add_headers(.headers = c("Content-Type" = "application/json"))
      ) %>%
        httr::content()
    },
    error = function(e) {
      message(paste0("An error occured while calling getPost: ", e))
      NA
    }
  )

  if (!is.na(r)[[1]]) {
    r <- r %>% dplyr::bind_rows()
  } else {
    r <- data.frame()
  }

  return(r)
}



#' Get competitions
#'
#' Get detailed schedule of competitions
#'
#' @param event_id Character. Event ID. Find by calling [get_events()].
#'
#' @return A data.frame.
#' @importFrom magrittr `%>%`
#' @export
#'
#' @examples
#' get_competition(get_events("1819", "1")$EventId[1])
get_competition <- function(event_id) {
  base_url <- "http://biathlonresults.com/modules/sportapi/api/"

  q <- paste0(base_url, "Competitions?EventId=", event_id)

  r <- tryCatch(
    {
      httr::GET(
        q,
        httr::add_headers(.headers = c("Content-Type" = "application/json"))
      ) %>%
        httr::content()
    },
    error = function(e) {
      message(paste0("An error occured while calling getPost: ", e))
      NA
    }
  )

  if (!is.na(r)[[1]]) {
    r <- r %>% dplyr::bind_rows()
  } else {
    r <- data.frame()
  }

  return(r)
}


#' Get race results
#'
#' Get the results of a race.
#'
#' @param race_id Character. Race ID. Find by calling [get_competition()].
#'
#' @return A data.frame. One athlete per row. The first block of variables
#' contains information about the event.
#' @importFrom magrittr `%>%`
#' @export
#'
#' @examples
#' get_race_results("BT2223SWRLCP02SMSP")
get_race_results <- function(race_id) {
  base_url <- "http://biathlonresults.com/modules/sportapi/api/"

  q <- paste0(base_url, "Results?RaceId=", race_id)

  r <- tryCatch(
    {
      httr::GET(
        q,
        httr::add_headers(.headers = c("Content-Type" = "application/json"))
      ) %>%
        httr::content()
    },
    error = function(e) {
      message(paste0("An error occured while calling getPost: ", e))
      NA
    }
  )
  #
  if (!is.na(r)[[1]]) {
    # Race meta data
    race <- r[lapply(r, typeof) != "list"] %>% dplyr::bind_rows()

    # Competition details
    comp <- r$Competition %>%
      dplyr::bind_rows() %>%
      dplyr::rename_with(~ paste0("Comp.", .x))

    # Event details
    event <- r$SportEvt %>%
      dplyr::bind_rows() %>%
      dplyr::rename_with(~ paste0("Event.", .x))

    # Get Results/Startlist
    results <- r$Results %>% dplyr::bind_rows()
    if (nrow(results) == 0) {
      results <- data.frame(
        StartOrder = NA,
        ResultOrder = NA
      )
    }

    # Bind
    df <- dplyr::bind_cols(
      race,
      comp,
      event,
      results
    )
  } else df = data.frame()

  return(df)
}


