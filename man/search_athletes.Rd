% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/api.R
\name{search_athletes}
\alias{search_athletes}
\title{Search athletes}
\usage{
search_athletes(family_name, given_name = NULL)
}
\arguments{
\item{family_name}{Character. Family name.}

\item{given_name}{Character. First name. Default is NULL.}
}
\value{
A data.frame. Listing all matches.
}
\description{
Search for athletes by name.
}
\examples{
search_athletes("boe")
}
