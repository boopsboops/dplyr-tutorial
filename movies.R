library(ggplot2movies)
library(tidyverse)
library(magrittr)
library(omdbapi)#https://github.com/hrbrmstr/omdbapi


data(movies)
data(starwars)
glimpse(movies)

# https://minimaxir.com/2018/07/imdb-data-analysis/
# https://www.imdb.com/interfaces/
write_csv(movies,path="~/movies.csv")

?movies

movies %>% ggplot(aes(x=year,y=rating,group=year)) + geom_boxplot()

movies %>% filter(!is.na(budget)) %>% ggplot(aes(x=budget,y=rating)) + geom_point() + scale_x_log10()


name.basics <- read_tsv(file="https://datasets.imdbws.com/name.basics.tsv.gz")

title.basics <- read_tsv(file="https://datasets.imdbws.com/title.basics.tsv.gz")
title.basics %>% filter(isAdult==0,titleType=="movie",startYear>=1977)

ratings <-  read_tsv(file="https://datasets.imdbws.com/title.ratings.tsv.gz")

ratings %>% summary(numVotes) 

ratings %<>% filter(numVotes > 20)



titles <-  read_tsv(file="https://datasets.imdbws.com/title.akas.tsv.gz")
titles %<>% rename(tconst=titleId)

table(titles.ratings$language)

titles.ratings <- left_join(titles,ratings)

titles.ratings %<>% filter(language=="en") %>% arrange(desc(numVotes)) %>% select(tconst,title,averageRating,numVotes) %>% distinct()

titles.j <- left_join(title.basics,titles.ratings)
titles.j %>% filter(isAdult==0,titleType=="movie",startYear>=1977)

titles.ratings %>% filter(types=="original")

unique(titles.ratings$types)


basics %>% filter(str_detect(primaryProfession,"actress|actor"))




g <- find_by_title("star wars", api_key="2c95f6b7")

g <- find_by_id("tt0458339;tt1843866", api_key="2c95f6b7")

jj <- c("tt0458339",
"tt1843866",
"tt3498820",
"tt0103923",
"tt0078937",
"tt3911200",
"tt0078938",
"tt0036697",
"tt0206474",
"tt1740721")


lapply(jj,find_by_id,api_key="2c95f6b7")


search_by_title("Captain America", api_key="2c95f6b7")
ichi <- search_by_title("", api_key="2c95f6b7")