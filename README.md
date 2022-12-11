
<!-- README.md is generated from README.Rmd. Please edit that file -->

# biathlonResults

<!-- badges: start -->

[![R CMD
Check](https://github.com/thieled/biathlonResults/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/thieled/biathlonResults/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

biathlonResults is an inofficial wrapper around the API provided by
[biathlonresults.com](https://biathlonresults.com/). The API is free and
public, but undocumented. I drew on
[this](https://github.com/prtkv/biathlonresults/blob/master/biathlonresults/api.py)
implementation in python.

The package covers most of the API’s functions and follows a
[tidy-data](https://r4ds.had.co.nz/tidy-data.html) logic in the returned
output (…well, mostly).

## Installation

You can install the development version of biathlonResults from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("thieled/biathlonResults")
```

## Example

Here are a few examples how to use it. To get a list of all cups this
season, call:

``` r
library(biathlonResults)
library(dplyr)
#> Warning: Paket 'dplyr' wurde unter R Version 4.2.2 erstellt
#> 
#> Attache Paket: 'dplyr'
#> Die folgenden Objekte sind maskiert von 'package:stats':
#> 
#>     filter, lag
#> Die folgenden Objekte sind maskiert von 'package:base':
#> 
#>     intersect, setdiff, setequal, union
get_cups("2223") %>% select(CupId, Description, Level) %>% head(3)
#> # A tibble: 3 × 3
#>   CupId              Description                     Level
#>   <chr>              <chr>                           <int>
#> 1 BT2223SWRLCP__SWTS Women's World Cup Total Score       1
#> 2 BT2223SWRLCP__SWSP Women's World Cup Sprint Score      1
#> 3 BT2223SWRLCP__SWPU Women's World Cup Pursuit Score     1
```

Now, lets get the current (Season 22/23) Women’s World Cup:

``` r
get_cup_results("BT2223SWRLCP__SWTS") %>% select(Rank, IBUId, Name) %>% head(3)
#> # A tibble: 3 × 3
#>   Rank  IBUId            Name                      
#>   <chr> <chr>            <chr>                     
#> 1 1     BTFRA20910199601 SIMON Julia               
#> 2 2     BTNOR22309199601 TANDREVOLD Ingrid Landmark
#> 3 3     BTITA20402199501 VITTOZZI Lisa
```

Let’s get Tandrevold’s complete race result record and her skiiing and
shooting stats of the past 4 seasons:

``` r
get_results("BTNOR22309199601") %>% head(3) %>% select(RaceId, Comp, Place, Rank, Pen, Shootings)
#>               RaceId Comp      Place Rank  Pen Shootings
#> 1 BT2223SWRLCP02SWRL   RL Hochfilzen   5. <NA>      <NA>
#> 2 BT2223SWRLCP02SWPU   PU Hochfilzen   2.    1   0+0+1+0
#> 3 BT2223SWRLCP02SWSP   SP Hochfilzen  13.    1       0+1

get_stats("BTNOR22309199601")  %>% select(FullName, starts_with("Stat"))
#> # A tibble: 4 × 7
#>   FullName                   StatSeasons StatS…¹ StatS…² StatS…³ StatS…⁴ StatS…⁵
#>   <chr>                      <chr>       <chr>   <chr>   <chr>   <chr>   <chr>  
#> 1 Ingrid Landmark TANDREVOLD 22/23       93%     96%     90%     -4%     2.8    
#> 2 Ingrid Landmark TANDREVOLD 21/22       87%     93%     82%     -3%     3.7    
#> 3 Ingrid Landmark TANDREVOLD 20/21       83%     91%     74%     -4%     1.6    
#> 4 Ingrid Landmark TANDREVOLD 19/20       82%     90%     73%     -3%     4.1    
#> # … with abbreviated variable names ¹​StatShooting, ²​StatShootingProne,
#> #   ³​StatShootingStanding, ⁴​StatSkiing, ⁵​StatSkiKMB
```

Of course, we can also get the results of a specific race:

``` r
get_race_results("BT2223SWRLCP02SMPU") %>% select(Comp.Description, Event.Organizer,
                                                  ShortName, Rank, TotalTime, Behind, Shootings) %>% head()
#> # A tibble: 6 × 7
#>   Comp.Description                Event.O…¹ Short…² Rank  Total…³ Behind Shoot…⁴
#>   <chr>                           <chr>     <chr>   <chr> <chr>   <chr>  <chr>  
#> 1 Men 12.5 km Pursuit Competition Hochfilz… BOE J.… 1     33:50.7 0.0    0+1+0+1
#> 2 Men 12.5 km Pursuit Competition Hochfilz… LAEGRE… 2     34:38.6 +47.9  0+0+1+1
#> 3 Men 12.5 km Pursuit Competition Hochfilz… JACQUE… 3     35:04.6 +1:13… 0+1+1+1
#> 4 Men 12.5 km Pursuit Competition Hochfilz… FILLON… 4     35:12.9 +1:22… 0+1+0+0
#> 5 Men 12.5 km Pursuit Competition Hochfilz… HARTWE… 5     35:26.2 +1:35… 0+1+0+0
#> 6 Men 12.5 km Pursuit Competition Hochfilz… GIACOM… 6     35:33.5 +1:42… 0+1+0+1
#> # … with abbreviated variable names ¹​Event.Organizer, ²​ShortName, ³​TotalTime,
#> #   ⁴​Shootings
```

Have fun!
