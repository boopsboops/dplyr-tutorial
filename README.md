# dplyr-tutorial
A tutorial for dplyr

Some elements of this tutorial are very closely based on the free online book "R for Data Science" by Hadley Wickham and Garrett Grolemund [https://r4ds.had.co.nz]
This is definitely worth a read if you want to get to grips with dplyr. It doesn't take too long to go through and is very clear and easy to follow. It's a very worthwhile investment. 

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

Here is an example of an untidy data set, which is fictional data about the number of farms infected with foot and mouth during March and April:

|County       | March | April | 
|-------------|:-----:|------:|
|Oxfordshire  | 20    | 24    |
|Hertfordshire| 89    | 103   |
|Devon        | 300   | 293   |

Code in R to create this tibble
```FootNMouth <- tibble(
  County = c("Oxfordshire", "Hertfordshire", "Devon"),
  March = c(20,89, 300),
  April = c(24,103,293),
  
)
```

And the same data set, now tidied:

|County       | Month | Number of farms infected | 
|-------------|:-----:|-------------------------:|
|Oxfordshire  | March | 20                       |
|Oxfordshire  | April | 24                       |
|Hertfordshire| March | 89                       |
|Hertfordshire| April | 103                      |
|Devon        | March | 300                      |
|Devon        | April | 293                      |


The problem with this dataset is that the column names were not names of variables, but values of a variable. March and April are values of the variable "Month" and so each row represented two observations, not one. 

There are a two functions you can use to tidy your data, gather() and spread ()

### gather()

gather() takes columns that are values of a variable and creates extra rows so that each row is showing just one observation. 

The tidy data above can be achieved using gather() like so:

```FootNMouth %>%
  gather(March, April, key = "Month", value = "Number of farms infected")
```

Again you can see the pipe ```%>%``` has been used here. More will be revealed later, but essentially this is making the data from the FootnMouth tibble be used in the gather() function. 

You can see that you need to first need to specify in gather() the columns that represent values, not variables, in this case ```March``` and ```April```. 

Then you provide the name of the variable whose values are in the collumn names, so in this case ```Month``` and the name of the variable which is in the cells, ```Number of farms infected```. 

NOTE: If the columns that you are gathering do not start with a letter, then you need to surround them with backticks ``` `` ``` in gather()

### spread()




## relational data
leftjoin()






