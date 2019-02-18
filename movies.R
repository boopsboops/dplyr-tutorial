library(ggplot2movies)
library(tidyverse)
library(magrittr)

data(movies)
data(starwars)
glimpse(movies)

# https://minimaxir.com/2018/07/imdb-data-analysis/
# https://www.imdb.com/interfaces/
write_csv(movies,path="~/movies.csv")

?movies

movies %>% ggplot(aes(x=year,y=rating,group=year)) + geom_boxplot()


basics <- read_tsv(file="https://datasets.imdbws.com/name.basics.tsv.gz")

basics %>% filter(str_detect(primaryProfession,"actress|actor"))