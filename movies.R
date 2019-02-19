library(ggplot2movies)
library(tidyverse)
library(magrittr)
library(parallel)
library(omdbapi)#https://github.com/hrbrmstr/omdbapi
#sudo R; devtools::install_github("hrbrmstr/omdbapi")

# data(movies)
# glimpse(movies)

# load up a 5000+ movie table from a researcher
mm.df <- read_csv("https://github.com/sundeepblue/movie_rating_prediction/raw/master/movie_metadata.csv")
# take a look
glimpse(mm.df)

# get the IMDB id
mm.df %<>% mutate(tconst=str_split_fixed(movie_imdb_link,"/",6)[,5])

# pull out the IDs into a vector
imdb.ids <- mm.df %>% filter(!is.na(tconst)) %>% select(tconst) %>% pull(tconst)

# now query the OMBD, but limited at 1000 max per day
daily.one <- mclapply(imdb.ids[1:999],find_by_id,api_key="2c95f6b7", include_tomatoes=TRUE)
daily.two <- mclapply(imdb.ids[1000:1999],find_by_id,api_key="2c95f6b7", include_tomatoes=TRUE)
daily.three <- mclapply(imdb.ids[2000:2999],find_by_id,api_key="2c95f6b7", include_tomatoes=TRUE)
daily.four <- mclapply(imdb.ids[3000:3999],find_by_id,api_key="2c95f6b7", include_tomatoes=TRUE)
daily.five <- mclapply(imdb.ids[4000:4999],find_by_id,api_key="2c95f6b7", include_tomatoes=TRUE)
daily.six <- mclapply(imdb.ids[5000:5043],find_by_id,api_key="2c95f6b7", include_tomatoes=TRUE)
# create daily copy
daily.df <- daily.one

# join all the data frames
# first extract the rotten tomato ratings from the ratings lists using Map
# write it out
daily.df %>% 
    bind_rows() %>% 
    mutate(ratingSite=map(Ratings,1),tomatoMeter=map(Ratings,2)) %>% 
    unnest(ratingSite,tomatoMeter) %>% 
    filter(ratingSite=="Rotten Tomatoes") %>% 
    select(-Ratings) %>% 
    write_csv("dailyX.csv")
    # remember to change file name by hand

# read back in 
omdb.df <- read_csv(file="daily1.csv", na=c("","NA","N/A"))

omdb.df %<>% 
    rename(tconst=imdbID) %>% 
    mutate(tomatoMeter=as.numeric(str_replace_all(tomatoMeter,"%",""))) %>% 
    select(tconst,tomatoMeter)


# join and clean
mm.df %<>% 
    left_join(omdb.df,by="tconst") %>% 
    select(tconst,movie_title,title_year,director_name,duration,genres,actor_1_name,actor_1_facebook_likes,content_rating,budget,gross,imdb_score,tomatoMeter) %>%
    mutate(genreSingle=str_replace_all(genres,"\\|.+",""))

# plot tomato against imdb
mm.df %>% filter(!is.na(tomatoMeter) & !is.na(imdb_score) & !is.na(budget) & !is.na(gross)) %>% 
    filter(budget >= 500000 & budget <= 500000000) %>%
    ggplot(aes(x=tomatoMeter,y=imdb_score,size=gross),na.rm=TRUE) + 
    geom_point(alpha=0.75,shape=16,colour="tomato") + #
    #scale_color_gradient(low="yellow", high="tomato") + 
    theme_bw()


# gather by genre
hh <- mm.df %>% 
    separate(genres, into=c("genre1","genre2","genre3","genre4","genre5","genre6","genre7","genre8","genre9"), sep="\\|") %>% 
    gather(key="ngenre",value="genre",genre1,genre2,genre3,genre4,genre5,genre6,genre7,genre8,genre9, na.rm=TRUE) %>% 
    group_by(genre) %>% 
    mutate(ngenre=length(unique(tconst))) %>% 
    ungroup() 

# filter outliers and plot
hh  %>% 
    #filter(!is.na(budget), !is.na(gross)) %>% 
    filter(ngenre > 100 & budget >= 500000 & budget <= 500000000) %>% 
    ggplot(aes(x=budget,y=imdb_score),na.rm=TRUE) + 
    #ggplot(aes(x=budget,y=gross)) + 
    geom_point(alpha=0.2,shape=18) + 
    scale_x_log10() + 
    scale_y_log10() + 
    geom_smooth(method="lm") + 
    facet_wrap(~genre, scales="free") + 
    theme_bw()

# look for the best and worst directors
hh %>% filter(!is.na(director_name)) %>% 
    group_by(director_name) %>% 
    summarise(mean=mean(imdb_score),sd=sd(imdb_score),nmovies=length(unique(tconst))) %>%
    filter(nmovies >= 5) %>%
    #arrange(desc(mean)) %>% 
    arrange(desc(sd)) %>% 
    print(n=20)

    
    
    
    


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