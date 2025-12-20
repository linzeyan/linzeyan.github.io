---
title: "一次搞懂密碼學中的三兄弟 — Encode、Encrypt 跟 Hash"
date: 2021-10-18T14:24:01+08:00
menu:
  sidebar:
    name: "一次搞懂密碼學中的三兄弟 — Encode、Encrypt 跟 Hash"
    identifier: what-are-encoding-encrypt-and-hashing
    weight: 10
tags: ["URL", "Encode", "Encrypt", "Hash"]
categories: ["URL", "Encode", "Encrypt", "Hash"]
---

- [一次搞懂密碼學中的三兄弟 — Encode、Encrypt 跟 Hash](https://medium.com/starbugs/what-are-encoding-encrypt-and-hashing-4b03d40e7b0c)

### 編碼（Encoding）

> 不會修改資料、也沒有任何加密的效果，單純就是 換個方式來表達資料 而已，其中最有名的例子就是`摩斯密碼`
>
> - JavaScript 中有兩個很實用的 function 分別是 `encodeURI` 跟 `decodeURI` 把網址中的特殊字元（空白、標點符號等等）編碼成符合 URL 的格式
> - `Base64` 是一種可以把二進位的資料編碼成 ASCII 字元的方法
> - `霍夫曼編碼（Huffman Coding）` 一種用來進行 無失真壓縮 的編碼演算法，說穿了他的概念就是把常用的字記成縮寫，從而降低資料量、達到壓縮的效果

### 加密（Encrypt）

> 加密跟解密必須要有金鑰（Key）才能進行。以最簡單的 凱薩加密法 來說，他加密的方式就是把每個英文字母加上一個 偏移量，這個偏移量就是用來執行加解密的 Key
>
> - AES (Advanced Encryption Standard) 是一種對稱加密演算法，所謂的對稱就是說加密解密 都是用同一個 key，這點跟上面說到的凱薩加密法一樣，但 AES 不像凱薩的 key 只有 0-25 這麼少種，而是可以有超過 10³⁸ 種
> - RSA 這類非對稱加密法有個很特別的地方，就是他會產生一組兩個 Key 分別叫公鑰（Public Key）跟私鑰（Private Key），而且 用公鑰加密的內容只能用私鑰解

### 雜湊（Hashing）

> 各個 欄位/字元 丟進去某個公式計算的方式就叫做雜湊（Hash），而這個計算公式就稱為 雜湊函數（Hash function），過程可能會做各種加減乘除，最後算出一個值或字串，因為不可能由雜湊後的結果回推，所以雜湊的過程是 不可逆的
