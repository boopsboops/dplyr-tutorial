library(tidyverse)
library(lubridate)
library(magrittr)
library(parallel)
library(omdbapi)#https://github.com/hrbrmstr/omdbapi
#sudo R; devtools::install_github("hrbrmstr/omdbapi")

# load up a 5000+ movie table from a researcher
# https://github.com/sundeepblue/movie_rating_prediction
mm.df <- read_csv("https://github.com/sundeepblue/movie_rating_prediction/raw/master/movie_metadata.csv")
# take a look
glimpse(mm.df)

# get the IMDB id
mm.df %<>% mutate(tconst=str_split_fixed(movie_imdb_link,"/",6)[,5])

# pull out the IDs into a vector
imdb.ids <- mm.df %>% filter(!is.na(tconst)) %>% select(tconst) %>% pull(tconst)

# now query the OMBD, but limited at 1000 max per day
daily.one <- mclapply(imdb.ids[1:999],find_by_id,api_key="2c95f6b7",include_tomatoes=TRUE)
daily.two <- mclapply(imdb.ids[1000:1999],find_by_id,api_key="2c95f6b7",include_tomatoes=TRUE)
daily.three <- mclapply(imdb.ids[2000:2999],find_by_id,api_key="2c95f6b7",include_tomatoes=TRUE)
daily.four <- mclapply(imdb.ids[3000:3999],find_by_id,api_key="2c95f6b7",include_tomatoes=TRUE)
daily.five <- mclapply(imdb.ids[4000:4999],find_by_id,api_key="2c95f6b7",include_tomatoes=TRUE)
daily.six <- mclapply(imdb.ids[5000:5043],find_by_id,api_key="2c95f6b7",include_tomatoes=TRUE)
# create daily copy
daily.df <- daily.six

# join all the data frames
# first extract the rotten tomato ratings from the ratings lists using Map
# write it out
daily.df %>% 
    bind_rows() %>% 
    mutate(ratingSite=map(Ratings,1),tomatoMeter=map(Ratings,2)) %>% 
    unnest(ratingSite,tomatoMeter) %>% 
    filter(ratingSite=="Rotten Tomatoes") %>% 
    select(-Ratings) %>% 
    write_csv("daily6.csv")
    # remember to change file name by hand


### analyse the final datasets 


# read in the list of tomato files
movies.data.list <- lapply(list.files(pattern=".csv"),read_csv,na=c("","NA","N/A"))

# join together
movies.data <- bind_rows(movies.data.list)

# take a look
movies.data %>% glimpse()

# edit and remove junk columns
movies.data %<>% 
    mutate(tomatoMeter=as.numeric(str_replace_all(tomatoMeter,"%","")), 
        Released=ymd(Released), 
        BoxOffice=as.numeric(str_replace_all(BoxOffice,"\\$|,","")),
        Runtime=as.numeric(str_replace_all(Runtime," min","")),
        month=month(Released,label=TRUE)) %>%
    select(-Type,-tomatoImage,-tomatoRating,-tomatoReviews,-tomatoFresh,-tomatoRotten,-tomatoConsensus,
        -tomatoUserMeter,-tomatoUserRating,-tomatoUserReviews,-tomatoURL,-DVD,-Website,-Response,-Season,
        -Episode,-seriesID,-totalSeasons,-ratingSite)

# take a look
movies.data %>% glimpse()

### read in the budget data
budget.data <- read_tsv("movie-budgets.tsv")

# take a look
budget.data %>% glimpse()

# get IMDB id and remove other cols
budget.data %<>% 
    mutate(imdbID=str_split_fixed(url,"/",6)[,5]) %>%
    select(imdbID,budget,gross)

# look at the data
budget.data %>% glimpse()

# join with 
movies.data %<>% left_join(budget.data,by="imdbID")

# add any missing BoxOffice data
movies.data %>% filter(is.na(BoxOffice))
movies.data %<>% mutate(BoxOffice=if_else(is.na(BoxOffice),gross,BoxOffice))

# make a quick summary of some stats
movies.data %>% 
    summarise(
        nmovies=length(unique(imdbID)), 
        maxDur=max(Runtime,na.rm=TRUE), 
        minDur=min(Runtime,na.rm=TRUE), 
        minBudget=min(budget,na.rm=TRUE), 
        maxBudget=max(budget,na.rm=TRUE),
        minYear=min(Year,na.rm=TRUE), 
        maxYear=max(Year,na.rm=TRUE)
        )


# plot movies per year
movies.data %>% ggplot(aes(Year)) + geom_histogram(fill="tomato") + theme_bw()

# get all the unique rows
movies.data %<>% 
    distinct() %>% 
    filter(between(Runtime,60,240), between(budget,500000,500000000), between(Year,1977,max(Year,na.rm=TRUE)))
    # filter(Runtime >= 60 & Runtime <= 240 & budget >= 500000 & budget <= 500000000 & Year >= 1977)
    #filter(!is.na(imdbRating) & !is.na(budget) & !is.na(gross))

# plot tomato against imdb
movies.data %>% filter(!is.na(tomatoMeter) & !is.na(imdbRating) & !is.na(budget) & !is.na(BoxOffice)) %>% 
    ggplot(aes(x=tomatoMeter,y=imdbRating,size=budget)) + # CHANGE "BoxOffice" to "budget"
    geom_point(alpha=0.3,shape=16,colour="tomato") +
    #geom_point(alpha=0.5,shape=16) +
    #scale_color_gradient(low="yellow", high="red") + 
    theme_bw()

# gather by genre
movies.data.genre <- movies.data %>% 
    separate(Genre, into=c("genre1","genre2","genre3","genre4","genre5","genre6","genre7","genre8"), sep=", ") %>% 
    gather(key="genreN",value="Genre",genre1,genre2,genre3,genre4,genre5,genre6,genre7,genre8, na.rm=TRUE) %>% 
    group_by(Genre) %>% 
    mutate(perGenre=length(unique(imdbID))) %>% 
    ungroup() %>% 
    select(-genreN) %>% 
    mutate(Genre=as_factor(Genre))

# filter outliers and plot
movies.data.genre  %>% 
    filter(!is.na(budget) & !is.na(BoxOffice) & !is.na(imdbRating) & !is.na(tomatoMeter)) %>% 
    filter(perGenre > 100) %>% 
    # plot
    ggplot(aes(x=budget,y=imdbRating)) + # change y= to "BoxOffice", "imdbRating", or "tomatoMeter"
    geom_point(alpha=0.2,shape=18) + 
    scale_x_log10() + 
    scale_y_log10() + 
    geom_smooth(method="lm") + 
    facet_wrap(~Genre, scales="free") + 
    theme_bw()


# look for the best and worst directors
movies.data %>% 
    filter(!is.na(Director) & !is.na(imdbRating)) %>% 
    mutate(Director=str_replace_all(Director,", .+","")) %>% 
    group_by(Director) %>% 
    summarise(meanIMDB=mean(imdbRating),sd=sd(imdbRating),nMovies=length(unique(imdbID))) %>%
    filter(nMovies >= 5) %>%
    arrange(desc(meanIMDB)) %>% # best
    #arrange(meanIMDB) %>% # best
    #arrange(desc(sd)) %>% # inconsistent
    print(n=20)


# takings by month
movies.data %>% 
    filter(!is.na(BoxOffice) & !is.na(month)) %>% 
    group_by(month) %>% 
    summarise(meanBox=mean(BoxOffice),sd=sd(BoxOffice),n=length(unique(imdbID)),CI=qnorm(0.975)*sd/sqrt(n)) %>% 
    ggplot(aes(x=month,y=meanBox,group=1)) + 
    geom_ribbon(aes(ymax=meanBox+CI,ymin=meanBox-CI,group=1),fill="tomato",alpha=0.3) + 
    geom_line() +
    theme_bw()



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