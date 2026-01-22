---
title: "是否有正規表示式可以檢測有效的正規表示式？"
date: 2019-10-04T14:44:38+08:00
menu:
  sidebar:
    name: "是否有正規表示式可以檢測有效的正規表示式？"
    identifier: is-there-a-regular-expression-to-detect-a-valid-regular-expression
    weight: 10
tags: ["Links", "Regex"]
categories: ["Links", "Regex"]
---

- [是否有正規表示式可以檢測有效的正規表示式？](https://stackoverflow.com/questions/172303/is-there-a-regular-expression-to-detect-a-valid-regular-expression)

這是一個遞迴正則，許多正則引擎不支援。基於 PCRE 的引擎應該支援。

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

移除空白與註解後

`/^((?:(?:[^?+*{}()[\]\\|]+|\\.|\[(?:\^?\\.|\^[^\\]|[^\\^])(?:[^\]\\]+|\\.)*\]|\((?:\?[:=!]|\?<[=!]|\?>)?(?1)??\)|\(\?(?:R|[+-]?\d+)\))(?:(?:[?+*]|\{\d+(?:,\d*)?\})[?+]?)?|\|)*)$/`

.NET 不直接支援遞迴（(?1) 和 (?R) 結構）。必須將遞迴改寫成平衡群組計數。

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

精簡版

`^(?:(?:[^?+*{}()[\]\\|]+|\\.|\[(?:\^?\\.|\^[^\\]|[^\\^])(?:[^\]\\]+|\\.)*\]|\((?:\?[:=!]|\?<[=!]|\?>|\?<[^\W\d]\w*>|\?'[^\W\d]\w*')?(?<N>)|\)(?<-N>))(?:(?:[?+*]|\{\d+(?:,\d*)?\})[?+]?)?|\|)*$(?(N)(?!))`
