---
title: "Regex for Markdown Syntax"
date: 2021-10-29T10:19:41+08:00
menu:
  sidebar:
    name: "Regex for Markdown Syntax"
    identifier: regular-expression-for-markdown
    weight: 10
tags: ["URL", "Markdown", "Regex"]
categories: ["URL", "Markdown", "Regex"]
---

- [Regex for Markdown Syntax](https://chubakbidpaa.com/interesting/2021/09/28/regex-for-md.html)
- [basic-syntax](https://www.markdownguide.org/basic-syntax/)

```
# Headings
headerOne   = `(#{1}\s)(.*)`
headeTwo    = `(#{2}\s)(.*)`
headerThree = `(#{3}\s)(.*)`
headerFour  = `(#{4}\s)(.*)`
headerFive  = `(#{5}\s)(.*)`
headerSix   = `(#{6}\s)(.*)`

# Bold and Italic Text
boldItalicText   = `(\*|\_)+(\S+)(\*|\_)+`

# Links
linkText         = `(\[.*\])(\((http)(?:s)?(\:\/\/).*\))`

# Images
imageFile        = `(\!)(\[(?:.*)?\])(\(.*(\.(jpg|png|gif|tiff|bmp))(?:(\s\"|\')(\w|\W|\d)+(\"|\'))?\)`

# Unordered List
listText         = `(^(\W{1})(\s)(.*)(?:$)?)+`

# Numbered Text
numberedListText = `(^(\d+\.)(\s)(.*)(?:$)?)+`

# Block Quotes
blockQuote       = `((^(\>{1})(\s)(.*)(?:$)?)+`

# Inline Code
inlineCode       = "(\\`{1})(.*)(\\`{1})"

# Code Block
codeBlock        = "(\\`{3}\\n+)(.*)(\\n+\\`{3})"

# Horizontal Line
horizontalLine   = `(\=|\-|\*){3}`

# Email Text
emailText        = `(\<{1})(\S+@\S+)(\>{1})`

# TABLES
tableText        = `(((\|)([a-zA-Z\d+\s#!@'"():;\\\/.\[\]\^<={$}>?(?!-))]+))+(\|))(?:\n)?((\|)(-+))+(\|)(\n)((\|)(\W+|\w+|\S+))+(\|$)`
```
