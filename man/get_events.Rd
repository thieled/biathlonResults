% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/api.R
\name{get_events}
\alias{get_events}
\title{Get events}
\usage{
get_events(season_id, level = 0)
}
\arguments{
\item{season_id}{Character. Indicating the season
by the last two digits of two following years, e.g. "1819" for 2018-2019.}

\item{level}{Integer.  Indicates the Cup level. \itemize{
\item 0: All.
\item 1: World Cup.
\item 2: IBU Cup.
\item 3: Junior Cup.
\item 4: Other.
}}
}
\value{
A data.frame.
}
\description{
Get schedule of events per season.
}
\examples{
get_events("2223", "1")
}
