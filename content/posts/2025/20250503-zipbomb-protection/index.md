---
title: "I use Zip Bombs to Protect my Server"
date: 2025-05-03T11:24:00+08:00
menu:
  sidebar:
    name: "I use Zip Bombs to Protect my Server"
    identifier: zipbomb-protection
    weight: 10
tags: ["URL", "HTTP", "Security"]
categories: ["URL", "HTTP", "Security"]
---

- [I use Zip Bombs to Protect my Server](https://idiallo.com/blog/zipbomb-protection)

- What happens is, they receive the file, read the header that instructs them that it is a compressed file. So they try to decompress the 1MB file to find whatever content they are looking for. But the file expands, and expands, and expands, until they run out of memory and their server crashes. The 1MB file decompresses into a 1GB. This is more than enough to break most bots. However, for those pesky scripts that won't stop, I serve them the 10MB file. This one decompresses into 10GB and instantly kills the script.

- `dd if=/dev/zero bs=1G count=10 | gzip -c > 10GB.gz`

  - `dd`: The dd command is used to copy or convert data.
  - `if`: Input file, specifies /dev/zero a special file that produces an infinite stream of zero bytes.
  - `bs`: block size, sets the block size to 1 gigabyte (1G), meaning dd will read and write data in chunks of 1 GB at a time.
  - `count=10`: This tells dd to process 10 blocks, each 1 GB in size. So, this will generate 10 GB of zeroed data.

- middleware

```
if (ipIsBlackListed() || isMalicious()) {
    header("Content-Encoding: gzip");
    header("Content-Length: ". filesize(ZIP_BOMB_FILE_10G)); // 10 MB
    readfile(ZIP_BOMB_FILE_10G);
    exit;
}
```
