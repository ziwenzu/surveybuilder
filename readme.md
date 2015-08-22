---
title: "readme for surveybuilder"
author: "Author One and Author Two"
date: "August 22, 2015"
output: html_document
---

# surveybuilder: Make Surveys and Randomized Survey Experiments in R

`surveybuilder` is a package for creating surveys in PDF format using R, 
and can accomodate a range of in-built and custom randomization schemes. 
It also makes the generation and numbering of survey modules and questions
much easier and quicker than manual PDF methods. 
`surveybuilder` compiles surveys in the $\LaTeX$ environmet, using the 
`paperandpencil` package, 
designed by Miriam Dieter & Anja Zwingenberger at 
University of Duisburg-Essen in 2009, 
[see here for more details](http://www.qdds.org/).

You can install `surveybuilder` using the following code:


```r
library(devtools)
install_github(repo = "surveybuilder",
               username = "jaspercooper")
```

Load as follows:


```r
library(surveybuilder)
```

# Making questions 

## Open questions 

All questions have an optional question prompt and comment option. 
Open questions can be followed by an arbitrary number of lines or dots. 


```r
# No lines, no comment
make_open_question(
  question_prompt = "How was your day?",
  concat = T)
```

```
## \question{{How was your day?}}
```

```r
# With comment
make_open_question(
  question_prompt = "How was your day?",
  comment = "\\emph{I honestly want to know!}",
  concat = T)
```

```
## \question{{How was your day?} \\\emph{I honestly want to know!}}
```

```r
# With 1 line
make_open_question(
  question_prompt = "How was your day?",
  comment = "\\emph{I honestly want to know!}",
  N_lines = 1,
  concat = T)
```

```
## \question{{How was your day?} \\\emph{I honestly want to know!}} 
##  \openone
```

```r
# With 2 dotted lines
make_open_question(
  question_prompt = "How was your day?",
  comment = "\\emph{I honestly want to know!}",
  N_dot_lines = 2,
  concat = T)
```

```
## \question{{How was your day?} \\\emph{I honestly want to know!}} 
##  \opendotstwo
```

## Multiple choice questions 

Multiple choice questions can be formatted in horizontal or vertical styles.


```r
# Horizontal with labels on top
make_horizontal_question(
  question_prompt = "How likely are you to use this package?",
  upper_labels = c("Not a chance",
                   "Maybe once in a while",
                   "Literally. Every. Day."),  
  concat = T)
```

```
## \question{{How likely are you to use this package?}} 
##  \horizontalthree{\upthree{Not a chance}{Maybe once in a while}{Literally. Every. Day.}} 
##  {\downthree{}{}{}}
```

```r
# Horizontal with labels on bottom
make_horizontal_question(
  question_prompt = "How likely are you to use this package?",
  lower_labels = c("Not a chance",
                   "Maybe once in a while",
                   "Literally. Every. Day."),
  concat = T)
```

```
## \question{{How likely are you to use this package?}} 
##  \horizontalthree{\upthree{}{}{}} 
##  {\downthree{Not a chance}{Maybe once in a while}{Literally. Every. Day.}}
```

```r
# Horizontal with labels on top and bottom
make_horizontal_question(
  question_prompt = "How likely are you to use this package?",
  upper_labels = c("Not a chance",
                   "Maybe once in a while",
                   "Literally. Every. Day."),
  lower_labels = c(1,2,3),
  concat = T)
```

```
## \question{{How likely are you to use this package?}} 
##  \horizontalthree{\upthree{Not a chance}{Maybe once in a while}{Literally. Every. Day.}} 
##  {\downthree{1}{2}{3}}
```

```r
# Vertical
make_vertical_question(
  question_prompt = "How likely are you to use this package?",
  labels = c("Not a chance",
             "Maybe once in a while",
             "Literally. Every. Day."),
  concat = T)
```

```
## \question{{How likely are you to use this package?}} 
##  \begin{longanswersC} 
##  
##  \item Not a chance 
##  \item Maybe once in a while 
##  \item Literally. Every. Day. 
##   
##  \end{longanswersC}
```

## Numeric questions

You can add questios with number boxes for measurement (years, meters, events, etc.).


```r
# For a single box
make_numeric_question(
  question_prompt = "How many hours have you spent writing surveys in Excel and Word?",
  labels = c("minutes","hours","days"),
  N_boxes = c(2,2,1),
  concat = T)
```

```
## \question{{How many hours have you spent writing surveys in Excel and Word?}} 
##   $\hspace{8cm}$  $ \bbox\bbox $ minutes  $ \bbox\bbox $ hours  $ \bbox $ days  $\hfill$
```

```r
# For five boxes, with different labels at different points
make_numeric_question(
  question_prompt = "How many hours have you spent writing surveys in Excel and Word?",
  labels = c("minutes","hours","days"),
  N_boxes = c(2,2,1),
  concat = T)
```

```
## \question{{How many hours have you spent writing surveys in Excel and Word?}} 
##   $\hspace{8cm}$  $ \bbox\bbox $ minutes  $ \bbox\bbox $ hours  $ \bbox $ days  $\hfill$
```

Note that `cm_from_left` can be used to set the location of the numeric boxes
on the page. 

## Grids of questions

You can also ask multiple horizontal or vertical questions using 
answers that share the same scale.


```r
# Vertical questions, horizontal answers
make_grid_question(
  question_prompt = "Rate the following items from 1 (not great) to 5 (not bad).",
  comment = "\\emph{Try to remain unenthused}",
  vertical_labels = c("Hi-Fives","Rollercoasters","Quiet Strolls"),
  horizontal_labels = 1:5,
  concat = T)
```

```
## \question{{Rate the following items from 1 (not great) to 5 (not bad).} \\\emph{Try to remain unenthused}} 
##  \vertikalblockfive{1}{2}{3}{4}{5}{ 
## \blocktextfive{Hi-Fives} 
## \blocktextfive{Rollercoasters} 
## \blocktextfive{Quiet Strolls} 
## }
```

```r
# Horizontal questions, vertical answers
make_grid_question(
  question_prompt = "Rate the following items from 1 (not great) to 5 (not bad).",
  comment = "\\emph{Try to remain unenthused}",
  vertical_labels = 1:5,
  horizontal_labels = c("Hi-Fives","Rollercoasters","Quiet Strolls"),
  concat = T)
```

```
## \question{{Rate the following items from 1 (not great) to 5 (not bad).} \\\emph{Try to remain unenthused}} 
##  \vertikalblockthree{Hi-Fives}{Rollercoasters}{Quiet Strolls}{ 
## \blocktextthree{1} 
## \blocktextthree{2} 
## \blocktextthree{3} 
## \blocktextthree{4} 
## \blocktextthree{5} 
## }
```

## Prompts or arbitrary additions 

You can also add in any of the usual `.tex` elements, such as  
lines, page breaks, prompts, or section titles. Be sure to add in an extra
"\\" whenever you need to add a backslash.


```r
make_prompt(prompt = "\\clearpage",concat = T)
```

```
## \clearpage
```

# Making Surveys 

## Non-Randomized Surveys

## Simple-Randomized Surveys

## Complete-Randomized Surveys

## Arbitrary Randomization Schemes

To be continued...




