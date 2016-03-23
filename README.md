---
title: "About"
author: "Franz Eder"
date: "23. März 2016"
output: html_document
---
<br>
This ``Shiny App`` gathers opinion polls from the [*HUFFPOST POLLSTER API*](http://elections.huffingtonpost.com/pollster/api),
using the R-package [**pollstR**](https://cran.r-project.org/web/packages/pollstR/index.html)
as a client.

Users can have a look at the opinion polls (these are not election results!!!) of
the 2016 presidential primaries and caucauses by the Democratic and Republican parties.

*First*, users choose between the two parties (**Dem**ocrats or **Rep**ublicans). Based
on this decision, the app allows users to choose **candidates** in the *second step*.
Because of relevance, not all candidates are selectable. Only the candidates with
the most chances of winning the election (at least at the begining of the whole process),
where chosen.

*Finally*, users have to decide, on which **states** they want to look at. Because
this app compares opininon polls between the candidates of the same party, only
these states are selectable, where all the chosen candidates were eligible and where
opinion polls were made (including US wide polls). 

The *results* are ploted reactively as **ggplot2 barcharts** and as a **datatable**.