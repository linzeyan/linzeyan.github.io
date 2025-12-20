---
title: "Google Search Operators: The Complete List (44 Advanced Operators)"
date: 2020-08-14T14:21:06+08:00
menu:
  sidebar:
    name: "Google Search Operators: The Complete List (44 Advanced Operators)"
    identifier: google-advanced-search-operators
    weight: 10
tags: ["URL", "Google"]
categories: ["URL", "Google"]
---

- [Google Search Operators: The Complete List (44 Advanced Operators)](https://ahrefs.com/blog/google-advanced-search-operators/)

#### Working

| Search operator | What it does                                                | Example                   |
| --------------- | ----------------------------------------------------------- | ------------------------- |
| `" "`           | Search for results that mention a word or phrase.           | `"steve jobs"`            |
| `OR`            | Search for results related to X or Y.                       | `jobs OR gates`           |
| `\|`            | Same as `OR`.                                               | `jobs \| gates`           |
| `AND`           | Search for results related to X and Y.                      | `jobs AND gates`          |
| `-`             | Search for results that don't mention a word or phrase.     | `jobs -apple`             |
| `*`             | Wildcard matching any word or phrase.                       | `steve * apple`           |
| `( )`           | Group multiple searches.                                    | `(ipad OR iphone) apple`  |
| `define:`       | Search for the definition of a word or phrase.              | `define:entrepreneur`     |
| `cache:`        | Find the most recent cache of a webpage.                    | `cache:apple.com`         |
| `filetype:`     | Search for particular types of files (e.g., PDF).           | `apple filetype:pdf`      |
| `ext:`          | Same as `filetype:`                                         | `apple ext:pdf`           |
| `site:`         | Search for results from a particular website.               | `site:apple.com`          |
| `related:`      | Search for sites related to a given domain.                 | `related:apple.com`       |
| `intitle:`      | Search for pages with a particular word in the title tag.   | `intitle:apple`           |
| `allintitle:`   | Search for pages with multiple words in the title tag.      | `allintitle:apple iphone` |
| `inurl:`        | Search for pages with a particular word in the URL.         | `inurl:apple`             |
| `allinurl:`     | Search for pages with multiple words in the URL.            | `allinurl:apple iphone`   |
| `intext:`       | Search for pages with a particular word in their content.   | `intext:apple iphone`     |
| `allintext:`    | Search for pages with multiple words in their content.      | `allintext:apple iphone`  |
| `weather:`      | Search for the weather in a location.                       | `weather:san francisco`   |
| `stocks:`       | Search for stock information for a ticker.                  | `stocks:aapl`             |
| `map:`          | Force Google to show map results.                           | `map:silicon valley`      |
| `movie:`        | Search for information about a movie.                       | `movie:steve jobs`        |
| `in`            | Convert one unit to another.                                | `$329 in GBP`             |
| `source:`       | Search for results from a particular source in Google News. | `apple source:the_verge`  |
| `before:`       | Search for results from before a particular date.           | `apple before:2007-06-29` |
| `after:`        | Search for results from after a particular date.            | `apple after:2007-06-29`  |

#### Unreliable

| Search operator | What it does                                                                    | Example                          |
| --------------- | ------------------------------------------------------------------------------- | -------------------------------- |
| `#..#`          | Search within a range of numbers.                                               | `iphone case $50..$60`           |
| `inanchor:`     | Search for pages with backlinks containing specific anchor text.                | `inanchor:apple`                 |
| `allinanchor:`  | Search for pages with backlinks containing multiple words in their anchor text. | `allinanchor:apple iphone`       |
| `AROUND(X)`     | Search for pages with two words or phrases within X words of one another.       | `apple AROUND(4) iphone`         |
| `loc:`          | Find results from a given area.                                                 | `loc:"san francisco" apple`      |
| `location:`     | Find news from a certain location in Google News.                               | `location:"san francisco" apple` |
| `daterange:`    | Search for results from a particular date range.                                | `daterange:11278-13278`          |

#### Not working (officially dropped by Google)

| Search operator    | What it does                                                                           | Example                      |
| ------------------ | -------------------------------------------------------------------------------------- | ---------------------------- |
| `~`                | Include synonyms in the search (dropped 2013).                                         | `~apple`                     |
| `+`                | Search for results mentioning an exact word or phrase (dropped 2011).                  | `jobs +apple`                |
| `inpostauthor:`    | Search for posts by a specific author in Google Blog Search (discontinued).            | `inpostauthor:"steve jobs"`  |
| `allinpostauthor:` | Same as `inpostauthor:`, but removes the need for quotes.                              | `allinpostauthor:steve jobs` |
| `inposttitle:`     | Search for posts with certain words in the title in Google's discontinued Blog Search. | `inposttitle:apple iphone`   |
| `link:`            | Search for pages linking to a particular domain or URL (dropped 2017).                 | `link:apple.com`             |
| `info:`            | Search for information about a specific page or website (dropped 2017).                | `info:apple.com`             |
| `id:`              | Same as `info:`                                                                        | `id:apple.com`               |
| `phonebook:`       | Search for someone's phone number (dropped 2010).                                      | `phonebook:tim cook`         |
| `#`                | Search for hashtags on Google+ (dropped 2019).                                         | `#apple`                     |
