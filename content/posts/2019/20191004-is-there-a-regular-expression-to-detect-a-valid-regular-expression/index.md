---
title: "Is there a regular expression to detect a valid regular expression?"
date: 2019-10-04T14:44:38+08:00
menu:
  sidebar:
    name: "Is there a regular expression to detect a valid regular expression?"
    identifier: is-there-a-regular-expression-to-detect-a-valid-regular-expression
    weight: 10
tags: ["URL", "Regex"]
categories: ["URL", "Regex"]
---

- [Is there a regular expression to detect a valid regular expression?](https://stackoverflow.com/questions/172303/is-there-a-regular-expression-to-detect-a-valid-regular-expression)

This is a recursive regex, and is not supported by many regex engines. PCRE based ones should support it.

```
/
^                                             # start of string
(                                             # first group start
  (?:
    (?:[^?+*{}()[\]\\|]+                      # literals and ^, $
     | \\.                                    # escaped characters
     | \[ (?: \^?\\. | \^[^\\] | [^\\^] )     # character classes
          (?: [^\]\\]+ | \\. )* \]
     | \( (?:\?[:=!]|\?<[=!]|\?>)? (?1)?? \)  # parenthesis, with recursive content
     | \(\? (?:R|[+-]?\d+) \)                 # recursive matching
     )
    (?: (?:[?+*]|\{\d+(?:,\d*)?\}) [?+]? )?   # quantifiers
  | \|                                        # alternative
  )*                                          # repeat content
)                                             # end first group
$                                             # end of string
/
```

Without whitespace and comments

`/^((?:(?:[^?+*{}()[\]\\|]+|\\.|\[(?:\^?\\.|\^[^\\]|[^\\^])(?:[^\]\\]+|\\.)*\]|\((?:\?[:=!]|\?<[=!]|\?>)?(?1)??\)|\(\?(?:R|[+-]?\d+)\))(?:(?:[?+*]|\{\d+(?:,\d*)?\})[?+]?)?|\|)*)$/`

.NET does not support recursion directly. (The (?1) and (?R) constructs.) The recursion would have to be converted to counting balanced groups

```
^                                         # start of string
(?:
  (?: [^?+*{}()[\]\\|]+                   # literals and ^, $
   | \\.                                  # escaped characters
   | \[ (?: \^?\\. | \^[^\\] | [^\\^] )   # character classes
        (?: [^\]\\]+ | \\. )* \]
   | \( (?:\?[:=!]
         | \?<[=!]
         | \?>
         | \?<[^\W\d]\w*>
         | \?'[^\W\d]\w*'
         )?                               # opening of group
     (?<N>)                               #   increment counter
   | \)                                   # closing of group
     (?<-N>)                              #   decrement counter
   )
  (?: (?:[?+*]|\{\d+(?:,\d*)?\}) [?+]? )? # quantifiers
| \|                                      # alternative
)*                                        # repeat content
$                                         # end of string
(?(N)(?!))                                # fail if counter is non-zero.
```

Compacted

`^(?:(?:[^?+*{}()[\]\\|]+|\\.|\[(?:\^?\\.|\^[^\\]|[^\\^])(?:[^\]\\]+|\\.)*\]|\((?:\?[:=!]|\?<[=!]|\?>|\?<[^\W\d]\w*>|\?'[^\W\d]\w*')?(?<N>)|\)(?<-N>))(?:(?:[?+*]|\{\d+(?:,\d*)?\})[?+]?)?|\|)*$(?(N)(?!))`
