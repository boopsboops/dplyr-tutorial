# dplyr-tutorial
A tutorial for dplyr

Some elements of this tutorial are very closely based on the free online book "R for Data Science" by Hadley Wickham and Garrett Grolemund [https://r4ds.had.co.nz]
This is definitely worth a read if you want to get to grips with dplyr. It doesn't take too long to go through and is very clear and easy to follow. It's a very worthwhile investment. 

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

These set of packages usually work best with "tibbles" which are an alternative data frame to R's traditional ```data.frame```

We will be working with tibbles today. If you have installed the tidyverse, this will have included the tibble package. If you want to find out more about how they work then there is a whole section on them in Chapter 10 of the book that I mentioned at the beginning. For now I will just give you the code that you need to use them.

To import data as a tibble you use ``` read_csv() ```as opposed to ```read.csv```.

To change an existing data.frame to a tibble, you use ```as_tibble()```.

You can create a new tibble from invidiual vectors using ```tibble()```, e.g.

``` tibble(
  flowers = c("roses", "poppies"),
  number = c(5,6)
  )
```

Tibbles automatically print the first 10 rows and so you don't need to use ``` head()``` to look at the top of your data.

However, if you want to print everything then you can use e.g.``` print(n=20 , width=Inf) ```, where n is specifying the number of rows and width, the number of columns. Width = Inf means all columns.

If you want to pull out a single variable, you can use ```$``` or ```[[]]```, where $ automatically will provide names of variables to select from. ```[[]]``` can be used to extract by name ```df[["x"]]```or by position ```[[1]]```. 

Later on, we will introduce the pipe ```%>%```. Bear in mind that when we do, you will use ``` . ``` instead of the name of data frame within the pipe.

## Tidy Data

For the functions in dplyr to work, it is necessary to "tidy" your data. 

Tidy data in R has each column as a variable, each row as an observation and each cell as one value. This means that row names should not be used.
There are a two functions you can use to tidy your data, gather() and spread ().

### gather()

gather() takes columns that are values of a variable and creates extra rows so that each row is showing just one observation.

Here is an example of an untidy data set, which is fictional data about the number of farms infected with foot and mouth during March and April:

```# A tibble: 3 x 3
  County        March April
  <chr>         <dbl> <dbl>
1 Oxfordshire      20    24
2 Hertfordshire    89   103
3 Devon           300   293
```


Code in R to create this tibble
```FootNMouth <- tibble(
  County = c("Oxfordshire", "Hertfordshire", "Devon"),
  March = c(20,89, 300),
  April = c(24,103,293),
  
)
```

And the same data set, now tidied:

```# A tibble: 6 x 3
  County        Month `Number of farms infected`
  <chr>         <chr>                      <dbl>
1 Oxfordshire   March                         20
2 Hertfordshire March                         89
3 Devon         March                        300
4 Oxfordshire   April                         24
5 Hertfordshire April                        103
6 Devon         April                        293
```

The problem with this dataset is that the column names were not names of variables, but values of a variable. March and April are values of the variable "Month" and so each row represented two observations, not one. 

The tidy data above can be achieved using gather() like so:

```FootNMouth %>%
  gather(March, April, key = "Month", value = "Number of farms infected")
```
Again you can see the pipe ```%>%``` has been used here. More will be revealed later, but essentially this is making the data from the FootnMouth tibble be used in the gather() function. 

NOTE: If you want to keep this tidy data, you need to assign the result to an object

```FootNMouth <- FootNMouth %>%
  gather(March, April, key = "Month", value = "Number of farms infected")
```

Or you can use backward-piping, which means that it will override the previous version of "FootNMouth"

RUPERT PLEASE INSERT AN EXAMPLE HERE

You can see that you need to first need to specify in gather() the columns that represent values, not variables, in this case ```March``` and ```April```. 

Then you provide the name of the variable whose values are in the collumn names, so in this case ```Month``` and the name of the variable which is in the cells, ```Number of farms infected```. 

NOTE: If the columns that you are gathering do not start with a letter, then you need to surround them with backticks ``` `` ``` in gather()

### spread()

spread ()) does the opposite of gather (), it creates extra columns when an observation is scattered accross multiple rows.

Take this untidy data set as an example (same data as above, other than it also includes data on the average number of cows infected per farm that is infected): 


```# A tibble: 12 x 4
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


Code to make this tibble in R
``` FootNMouth2 <- tibble(
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

``` # A tibble: 6 x 4
  County        Month AvNoCowsInfPerFarm NoFarmsInf
  <chr>         <chr>              <dbl>      <dbl>
1 Devon         April                  7        293
2 Devon         March                 10        300
3 Hertfordshire April                 63        103
4 Hertfordshire March                 50         89
5 Oxfordshire   April                102         24
6 Oxfordshire   March                100         20

```


Using spread():

``` spread(key=type, value=count)```







### separate()

### unite()

## dplyr functions

Once you've got your data in tibble format and it is tidy, then you're ready to start using the dplyr functions. We will briefly go through what each one does here and then you can use this as a reference when you start to use them later on in the tutorial. 


### filter()
### mutate()
### arrange()
### select ()
### summarise() and groupby()



## Combining data sets
leftjoin()

## pipes




