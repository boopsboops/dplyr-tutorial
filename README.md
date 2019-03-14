# dplyr-tutorial
A tutorial for dplyr

Some elements of this tutorial are very closely based on the free online book "R for Data Science" by Hadley Wickham and Garrett Grolemund [https://r4ds.had.co.nz]
This is definitely worth a read if you want to get to grips with dplyr. It doesn't take too long to go through and is very clear and easy to follow. It's a very worthwhile investment of your time!  

There are also various cheatsheets on this page [[https://www.rstudio.com/resources/cheatsheets/]] which provide good summaries of some of the functions you will be looking at and are useful as a quick reference guide (the Data Import and the Data Transformation ones are the most relevant for this session). 



## Installing the tidyverse

The tidyverse is a collection of many packages, including dplyr, which we will need for this tutorial. 

They can all be installed at once:

```
install.packages("tidyverse")
```

Don't forget to load them each time you open R with:

```
library(tidyverse)
```

If you are having issues with this on a university laptop, then specifying the location of where you want to install the packages and then specifying this location again when calling them, usually helps to solve most issues. 

```
install.packages("tidyverse", lib="/my R packages/")
```

```
library(tidyverse, lib.loc= "/my R packages/" )
```

## Tibbles

These set of packages usually work best with "tibbles" which are an alternative data frame to R's traditional `data.frame()`

We will be working with tibbles today. If you have installed the tidyverse, this will have included the tibble package. If you want to find out more about how they work then there is a whole section on them in Chapter 10 of the book that I mentioned at the beginning. For now I will just give you the code that you need to use them.

To import data as a tibble you use `read_csv()` as opposed to `read.csv()`.

To change an existing data.frame to a tibble, you use `as_tibble()`.

You can create a new tibble from invidiual vectors using `tibble()`, e.g.

```
tibble(
  flowers = c("roses", "poppies"),
  number = c(5,6)
  )
```

Tibbles automatically print the first 10 rows and so you don't need to use ` head()` to look at the top of your data.

However, if you do want to print everything then you can use e.g.`print(n=20 , width=Inf)`, where n is specifying the number of rows and width, the number of columns (`width = Inf` means all columns).

If you want to pull out a single variable, you can use `$` or `[[]]`, where $ automatically will provide names of variables to select from. `[[]]` can be used to extract by name `df[["x"]]` or by position `[[1]]`. 

Later on, we will introduce the pipe `%>%`. Bear in mind that when we do, you will use ` . ` instead of the name of data frame within the pipe.

## Tidy Data

For the functions in dplyr to work, it is necessary to "tidy" your data. 

Tidy data in R has each column as a variable, each row as an observation and each cell as one value. This means that row names should not be used.
We will now cover the functions that can be used to tidy data. 

### gather()

`gather()` takes columns that are values of a variable and creates extra rows so that each row is showing just one observation.

Here is an example of an untidy data set, which is fictional data about the number of farms infected with foot and mouth during March and April:

```
# A tibble: 3 x 3
  County        March April
  <chr>         <dbl> <dbl>
1 Oxfordshire      20    24
2 Hertfordshire    89   103
3 Devon           300   293
```


(Code in R to create this tibble)
```
FootNMouth <- tibble(
  County = c("Oxfordshire", "Hertfordshire", "Devon"),
  March = c(20,89, 300),
  April = c(24,103,293),
  )
```

The problem with this dataset is that the column names are not names of variables, but values of a variable. March and April are values of the variable "Month" and so each row represented two observations, not one. 

This is the same data set, now tidied:

```
# A tibble: 6 x 3
  County        Month `Number of farms infected`
  <chr>         <chr>                      <dbl>
1 Oxfordshire   March                         20
2 Hertfordshire March                         89
3 Devon         March                        300
4 Oxfordshire   April                         24
5 Hertfordshire April                        103
6 Devon         April                        293
```

The tidy data above can be achieved using `gather()`:

```
FootNMouth %>%
  gather(March, April, key = "Month", value = "Number of farms infected")
```

You can see the pipe `%>%` has been used here. More will be revealed later, but essentially this is making the data from the FootnMouth tibble be used in the `gather()` function. 

Using `gather()`, you need to first need to specify the columns that represent values, not variables, in this case "March" and "April". 

Then you provide the name of the variable whose values are in the collumn names, so in this case "Month" and the name of the variable which is in the cells, "Number of farms infected". 

NOTE: If the columns that you are gathering do not start with a letter, then you need to surround them with backticks ` `` ` 

### `spread()`

`spread()`` does the opposite of `gather()`, it creates extra columns when an observation is scattered accross multiple rows.

Take this untidy data set as an example (same data as above, other than it also includes data on the average number of cows infected per farm that is infected): 


```
# A tibble: 12 x 4
   County        Month type               count
   <chr>         <chr> <chr>              <dbl>
 1 Oxfordshire   March NoFarmsInf            20
 2 Oxfordshire   March AvNoCowsInfPerFarm   100
 3 Oxfordshire   April NoFarmsInf            24
 4 Oxfordshire   April AvNoCowsInfPerFarm   102
 5 Hertfordshire March NoFarmsInf            89
 6 Hertfordshire March AvNoCowsInfPerFarm    50
 7 Hertfordshire April NoFarmsInf           103
 8 Hertfordshire April AvNoCowsInfPerFarm    63
 9 Devon         March NoFarmsInf           300
10 Devon         March AvNoCowsInfPerFarm    10
11 Devon         April NoFarmsInf           293
12 Devon         April AvNoCowsInfPerFarm     7
```


(Code to make this tibble in R)

```
FootNMouth2 <- tibble(
  County = c(rep("Oxfordshire",4), rep("Hertfordshire",4), rep("Devon", 4)),
  Month = c(rep("March", 2), rep("April", 2), rep("March", 2), rep("April", 2),
            rep("March", 2), rep("April", 2)),
  type = c("NoFarmsInf", "AvNoCowsInfPerFarm", "NoFarmsInf", "AvNoCowsInfPerFarm", 
           "NoFarmsInf", "AvNoCowsInfPerFarm", "NoFarmsInf", "AvNoCowsInfPerFarm", 
           "NoFarmsInf", "AvNoCowsInfPerFarm", "NoFarmsInf", "AvNoCowsInfPerFarm"),
  count = c(20,100,24,102,89,50,103,63,300,10,293,7)
  )
```

This can be tidied to look like this:

```
# A tibble: 6 x 4
  County        Month AvNoCowsInfPerFarm NoFarmsInf
  <chr>         <chr>              <dbl>      <dbl>
1 Devon         April                  7        293
2 Devon         March                 10        300
3 Hertfordshire April                 63        103
4 Hertfordshire March                 50         89
5 Oxfordshire   April                102         24
6 Oxfordshire   March                100         20
```


Using `spread()`:

```
spread(key=type, value=count)
```

Where the "key" column is the column that contains the varible names and the "value" column contains the name of the column with values from multiple variables. 


### `separate()`

Sometimes you have one column with data in each row that you want to split into multiple columns.

For example, if you had one column with called "date", which had the date expressed as yyyy-mm-dd, but you wanted a column each for year, month and day.

`separate()` can achieve this by splitting wherever a separator character appears (in this case "-").

``` 
df %>%
    separate(date, into = c("year", "month", "day"))
```

### `unite()`

`unite()` is the reverse of this. You specify the name of the new column as your first argument and then the names of the columns to merge. You can use "sep =" to specify what type of separator to use.

```
df %>%
       unite(date, year, month, day, sep="-")
```


### Combining data sets

You can combine data from two data sets using the mutating join functions:

```
right_join(x,y)
left_join(x,y)
inner_join(x,y)
full_join(x,y)
```

For more information on these look at Chapter 13 of the book I mentioned, particularly section 13.4. 

## dplyr functions

Once you've got your data in tibble format and it is tidy, then you're ready to start using the dplyr functions. We will briefly go through what each one does here and then you can use this as a reference when you start to use them later on in the tutorial. 


### `filter()`

`filter()` is very similar to the `subset()` function in base R. The main advantage of `filter()` over `subset()` is that it is able to be operate on SQL databases without pulling the data into memory. We won't be doing this today and it doesn't matter if you don't know what that means! However, it's good to use `filter()` alongside other dplyr functions and it can be faster when you have lots of data. 

`filter()` subsets observations based on their values. 

So for example with the built in "starwars" data in R we can filter to find all the characters that have blue eyes:

```
filter(starwars, eye_color == "blue")
```

You can filter multiple columns simultaneously. Here we are filtering for humans that have blue eyes: 

```
filter(starwars, eye_color == "blue", species == "Human")
```

You always have the name of the tibble you want to filter as the first argument, followed by the arguments that specify the filtering.

You can use any of these comparison operators:

` > `, ` >= `, ` < `, ` <= ` , ` != ` (not equal to) and ` == ` (equal to)

or any of these logical operators:

` & ` (and) ` | ` (or) ` ! ` (not)

Be careful when using the logical operators, as you need to write out the same column multiple times if you are filtering for multiple things. For example if you wanted to find out which Star Wars characters had blue OR brown eyes you would need to write:

```
filter(starwars, eye_color == "blue"| eye_color == "brown")
```

not ... 

```
filter(starwars, eye_color == "blue"| "brown")
```

(Remember De Morgan's law : ` !(x&y) ` is the same as ` !x|!y ` and ` !x|y ` is the same as ` !x and !y `.

If this is still a bit confusing, the book I recommended explains this in more detail in Chapter 5.2.3).


One of the most useful operators I've found is: ` %in% ` which often can be used in place of some of the logical operators. For example if you wanted to find out which Star Wars characters had blue OR brown eyes, then for the blue OR brown example used above you could do:

```
filter(starwars, eye_color %in% c("blue", "brown"))
```

I find it most useful when using one dataframe to subset another one.

For example if I had an imaginary dataframe that had the student ID numbers of all students who had passed an exam (let's call it "passed") and then another dataframe containing information about all the students in the yeargroup, including their ID number (let's call it "studentInfo"), then we could filter the "studentInfo" dataframe using the studentID number to find out more information about only those students who had passed:

```
filter(studentInfo, studentInfo$studentID %in% passed$studentID)
```


### `arrange()`

This changes the order of rows based on columns and so for example, can be used in combination with `desc()` to re-order by a columnm in descending order. To rearrange the starwars data so that it is sorted from the character with the tallest height to the shortest height you can do:

```
arrange(starwars, desc(height))
```

This can be used in combination with lots of other functions. Missing values are always sorted at the end. 


### `select ()`

Select allows you to select specific columns that you want, e.g.

```
select(starwars, name, height, homeworld)
```

and can be used alongside the functions:

`starts_with("un")` - matches names that begin with "un".

`ends_with("ing")` - matches names that end with "ing".

`contains("he")`- matches names that contain "he".

`matches(".(.)\\1")` - selects variables that match a regular expression. Find out more about this in Chapter 14 "strings" of the book.

`num_range("y", 2:4)` - matches y2, y3, and y4.

### `rename()`

`rename()` can be used to rename columns

```
rename(starwars, name = Name)
```

### `mutate()`

You can add new columns with mutate that can use data from other columns. Say we wanted to calculate the BMI of the Star Wars characters. 
We could use the "height" and "mass" columns (not certain of their units, but doesn't matter for the sake of this example), as BMI is your weight divided by your height squared (in centimeters).

```
mutate(starwars, BMI = mass/((height)^2))
```

use `transmute()` if you only want to keep the new columns. 


### `summarise()` and `group_by()`

`summarise()` collapses a data frame into a single row. It is commonly used alongside `group_by()` which means that dplyr functions can be applied by group. It is also usually used with other functions such as `mean()`, `median()` etc.

If we wanted to find the mean height of the Star Wars characters by species then we would do:

```
heightSW <- group_by(starwars, species)
summarise(heightSW, AvHeightPerSp = mean(height, na.rm = TRUE))
```

`summarise()` and `group_by()` are often used with the pipe, which we will now get on to explaining ...

## The pipe

The pipe is written as ` %>% ` and can be interpreted as "then". 

It allows for results from one step, function or transformation to go straight to the next step, without needing to make intermediate objects.

So for example, if you had wanted to do find the average height of Star Wars characters by species as we had just described, but then arrange it in descending order (with `arrange()` and `desc()` as described earlier) then you could do the following:


```r
# pipe
AVHeightSPDf <- starwars %>%
  group_by(species) %>%
  summarise(AvHeightPerSp = mean(height, na.rm = TRUE)) %>%
  arrange(., desc(AvHeightPerSp))
```
  
To describe this code in words, I would say:
  
 (1) Create an object called "AVHeightSPDf". This will contain the results of the following:
 (2) You have the dataframe called "starwars"
 (3) Then group it by the column "species"
 (4) Then make a new column called "AVHeightPerSP" containing the mean height per species. Remove any NAs
 (5) Then rearrange the AVHeightPerSP column in descending order 
 
You can also use backward-piping, which means that instead of needing to create an new object, it will override the previous version of data that you are using

RUPERT PLEASE INSERT AN EXAMPLE HERE
  

## A real life example: movies!

Here we are going to analyse some real world data for movies. But because it it's someone else's data, we need to clean it first.

Here we have a dataset of various movie data. They are in several CSV files, so we read these in using `lapply()` and `read_csv()`. We specify our NAs too:

``` r
# comment
movies.data.list <- lapply(list.files(pattern=".csv"),read_csv,na=c("","NA","N/A"))
```

Now we merge all six dataframes together: 

``` r
# join together
movies.data <- bind_rows(movies.data.list)
```

``` r
# take a look
movies.data %>% glimpse()
```

Now clean it up, removing percent signs, coverting dates to date format, and dollar revenue and runtime to numeric. Then we ditch the columns we do't want with `select()`.

``` r
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
```

``` r
# take a look
movies.data %>% glimpse()
```

Those data don't have movie budgets though, which is important, so we get these from another TSV file.

``` r
# read in the budget data
budget.data <- read_tsv("movie-budgets.tsv")
```

``` r
# take a look
budget.data %>% glimpse()
```

To merge it with the other dataset we need a identifiers in common, in this case the IMDB code. But in this dataset this code is buried in a URL. We clean it:

``` r
# get IMDB id
budget.data %<>% 
    mutate(imdbID=str_split_fixed(url,"/",6)[,5]) %>%
    select(imdbID,budget,gross)
```

``` r
# take a look
budget.data %>% glimpse()
```

Now we can merge it with the other dataset by the new IMDB code.

``` r
# join dataframes
movies.joined <- left_join(movies.data, budget.data,by="imdbID")
```

``` r
# check for missing data add any missing BoxOffice data
movies.joined %>% filter(is.na(BoxOffice))
movies.joined %<>% mutate(BoxOffice=if_else(is.na(BoxOffice),gross,BoxOffice))
```