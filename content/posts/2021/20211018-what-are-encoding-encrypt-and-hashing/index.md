---
title: "Understand the crypto trio: Encode, Encrypt, and Hash"
date: 2021-10-18T14:24:01+08:00
menu:
  sidebar:
    name: "Understand the crypto trio: Encode, Encrypt, and Hash"
    identifier: what-are-encoding-encrypt-and-hashing
    weight: 10
tags: ["Links", "Encode", "Encrypt", "Hash"]
categories: ["Links", "Encode", "Encrypt", "Hash"]
---

- [Understand the crypto trio: Encode, Encrypt, and Hash](https://medium.com/starbugs/what-are-encoding-encrypt-and-hashing-4b03d40e7b0c)

### Encoding

> It does not change the data and has no encryption effect. It simply represents the data in another form. A classic example is `Morse code`.
>
> - JavaScript has two useful functions: `encodeURI` and `decodeURI`, which encode special characters in URLs (spaces, punctuation, etc.) into URL-safe formats.
> - `Base64` encodes binary data into ASCII characters.
> - `Huffman Coding` is a lossless compression encoding algorithm. In short, it compresses by abbreviating frequently used symbols.

### Encryption

> Encryption and decryption require a key. In the simplest Caesar cipher, each letter is shifted by an offset, and that offset is the key for encryption/decryption.
>
> - AES (Advanced Encryption Standard) is a symmetric algorithm, meaning encryption and decryption use the same key. Unlike the Caesar cipher's 0-25 key range, AES has more than 10^38 possible keys.
> - RSA is an asymmetric algorithm that uses a public key and a private key. Data encrypted with the public key can only be decrypted with the private key.

### Hashing

> Hashing means running each field/character through a formula to produce a value or string. The formula is a hash function. The process may involve operations like addition, subtraction, multiplication, and division. Because you cannot reverse the output to get the original input, hashing is irreversible.
