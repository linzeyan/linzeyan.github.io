---
title: "The One Billion Row Challenge in Go: from 1m45s to 3.4s in nine solutions"
date: 2024-07-08T09:50:10+08:00
menu:
  sidebar:
    name: "The One Billion Row Challenge in Go: from 1m45s to 3.4s in nine solutions"
    identifier: go-the-one-billion-row-challenge-in-go
    weight: 10
tags: ["Links", "Go"]
categories: ["Links", "Go"]
hero: images/hero/go.svg
---

- [The One Billion Row Challenge in Go: from 1m45s to 3.4s in nine solutions](https://benhoyt.com/writings/go-1brc/)
- https://github.com/benhoyt/go-1brc

##### Baseline

```shell
$ time cat measurements.txt >/dev/null
0m1.052s

$ time wc measurements.txt
 1000000000  1179173106 13795293380 measurements.txt
0m55.710s

$ time gawk -b -f 1brc.awk measurements.txt >measurements.out
7m35.567s
```

```awk
BEGIN {
	FS = ";"
}

{
	if (counts[$1]++) {
		mins[$1] = $2 < mins[$1] ? $2 : mins[$1]
		maxs[$1] = $2 > maxs[$1] ? $2 : maxs[$1]
	} else {
		mins[$1] = maxs[$1] = $2  # new entry
	}
	sums[$1] += $2
}

END {
	printf "{"
	n = asorti(mins, sorted)
    for (i = 1; i <= n; i++) {
    	station = sorted[i]
		min = mins[station]
		max = maxs[station]
		mean = sums[station] / counts[station]
		printf "%s=%.1f/%.1f/%.1f", station, min, mean, max
		if (i < n) {
			printf ", "
		}
	}
	printf "}\n"
}
```

##### Solution 1: simple and idiomatic Go

```go
// r1: simple, idiomatic Go using bufio.Scanner and strconv.ParseFloat
//
// ~1.004s for 10M rows

package main

import (
	"bufio"
	"fmt"
	"io"
	"os"
	"sort"
	"strconv"
	"strings"
)

func r1(inputPath string, output io.Writer) error {
	type stats struct {
		min, max, sum float64
		count         int64
	}

	f, err := os.Open(inputPath)
	if err != nil {
		return err
	}
	defer f.Close()

	stationStats := make(map[string]stats)

	scanner := bufio.NewScanner(f)
	for scanner.Scan() {
		line := scanner.Text()
		station, tempStr, hasSemi := strings.Cut(line, ";")
		if !hasSemi {
			continue
		}

		temp, err := strconv.ParseFloat(tempStr, 64)
		if err != nil {
			return err
		}

		s, ok := stationStats[station]
		if !ok {
			s.min = temp
			s.max = temp
			s.sum = temp
			s.count = 1
		} else {
			s.min = min(s.min, temp)
			s.max = max(s.max, temp)
			s.sum += temp
			s.count++
		}
		stationStats[station] = s
	}

	stations := make([]string, 0, len(stationStats))
	for station := range stationStats {
		stations = append(stations, station)
	}
	sort.Strings(stations)

	fmt.Fprint(output, "{")
	for i, station := range stations {
		if i > 0 {
			fmt.Fprint(output, ", ")
		}
		s := stationStats[station]
		mean := s.sum / float64(s.count)
		fmt.Fprintf(output, "%s=%.1f/%.1f/%.1f", station, s.min, mean, s.max)
	}
	fmt.Fprint(output, "}\n")
	return nil
}
```

##### Solution 2: map with pointer values

```go
// r2: use stats pointer as map value to avoid double hashing
//
// ~921ms for 10M rows (1.09x as fast as r1)

package main

import (
	"bufio"
	"fmt"
	"io"
	"os"
	"sort"
	"strconv"
	"strings"
)

func r2(inputPath string, output io.Writer) error {
	type stats struct {
		min, max, sum float64
		count         int64
	}

	f, err := os.Open(inputPath)
	if err != nil {
		return err
	}
	defer f.Close()

	stationStats := make(map[string]*stats)

	scanner := bufio.NewScanner(f)
	for scanner.Scan() {
		line := scanner.Text()
		station, tempStr, hasSemi := strings.Cut(line, ";")
		if !hasSemi {
			continue
		}

		temp, err := strconv.ParseFloat(tempStr, 64)
		if err != nil {
			return err
		}

		s := stationStats[station]
		if s == nil {
			stationStats[station] = &stats{
				min:   temp,
				max:   temp,
				sum:   temp,
				count: 1,
			}
		} else {
			s.min = min(s.min, temp)
			s.max = max(s.max, temp)
			s.sum += temp
			s.count++
		}
	}

	stations := make([]string, 0, len(stationStats))
	for station := range stationStats {
		stations = append(stations, station)
	}
	sort.Strings(stations)

	fmt.Fprint(output, "{")
	for i, station := range stations {
		if i > 0 {
			fmt.Fprint(output, ", ")
		}
		s := stationStats[station]
		mean := s.sum / float64(s.count)
		fmt.Fprintf(output, "%s=%.1f/%.1f/%.1f", station, s.min, mean, s.max)
	}
	fmt.Fprint(output, "}\n")
	return nil
}
```

##### Solution 3: avoid strconv.ParseFloat

```go
// r3: parse temperatures manually instead of using strconv.ParseFloat
//
// ~517ms for 10M rows (1.94x as fast as r1)

package main

import (
	"bufio"
	"bytes"
	"fmt"
	"io"
	"os"
	"sort"
)

func r3(inputPath string, output io.Writer) error {
	type stats struct {
		min, max, sum float64
		count         int64
	}

	f, err := os.Open(inputPath)
	if err != nil {
		return err
	}
	defer f.Close()

	stationStats := make(map[string]*stats)

	scanner := bufio.NewScanner(f)
	for scanner.Scan() {
		line := scanner.Bytes()
		station, tempBytes, hasSemi := bytes.Cut(line, []byte(";"))
		if !hasSemi {
			continue
		}

		negative := false
		index := 0
		if tempBytes[index] == '-' {
			index++
			negative = true
		}
		temp := float64(tempBytes[index] - '0')
		index++
		if tempBytes[index] != '.' {
			temp = temp*10 + float64(tempBytes[index]-'0')
			index++
		}
		index++ // skip '.'
		temp += float64(tempBytes[index]-'0') / 10
		if negative {
			temp = -temp
		}

		s := stationStats[string(station)]
		if s == nil {
			stationStats[string(station)] = &stats{
				min:   temp,
				max:   temp,
				sum:   temp,
				count: 1,
			}
		} else {
			s.min = min(s.min, temp)
			s.max = max(s.max, temp)
			s.sum += temp
			s.count++
		}
	}

	stations := make([]string, 0, len(stationStats))
	for station := range stationStats {
		stations = append(stations, station)
	}
	sort.Strings(stations)

	fmt.Fprint(output, "{")
	for i, station := range stations {
		if i > 0 {
			fmt.Fprint(output, ", ")
		}
		s := stationStats[station]
		mean := s.sum / float64(s.count)
		fmt.Fprintf(output, "%s=%.1f/%.1f/%.1f", station, s.min, mean, s.max)
	}
	fmt.Fprint(output, "}\n")
	return nil
}
```

##### Solution 4: fixed point integers

```go
// r4: use fixed point int32s (*10) instead of float64s
//
// ~491ms for 10M rows (2.04x as fast as r1)

package main

import (
	"bufio"
	"bytes"
	"fmt"
	"io"
	"os"
	"sort"
)

func r4(inputPath string, output io.Writer) error {
	type stats struct {
		min, max, count int32
		sum             int64
	}

	f, err := os.Open(inputPath)
	if err != nil {
		return err
	}
	defer f.Close()

	stationStats := make(map[string]*stats)

	scanner := bufio.NewScanner(f)
	for scanner.Scan() {
		line := scanner.Bytes()
		station, tempBytes, hasSemi := bytes.Cut(line, []byte(";"))
		if !hasSemi {
			continue
		}

		negative := false
		index := 0
		if tempBytes[index] == '-' {
			index++
			negative = true
		}
		temp := int32(tempBytes[index] - '0')
		index++
		if tempBytes[index] != '.' {
			temp = temp*10 + int32(tempBytes[index]-'0')
			index++
		}
		index++ // skip '.'
		temp = temp*10 + int32(tempBytes[index]-'0')
		if negative {
			temp = -temp
		}

		s := stationStats[string(station)]
		if s == nil {
			stationStats[string(station)] = &stats{
				min:   temp,
				max:   temp,
				sum:   int64(temp),
				count: 1,
			}
		} else {
			s.min = min(s.min, temp)
			s.max = max(s.max, temp)
			s.sum += int64(temp)
			s.count++
		}
	}

	stations := make([]string, 0, len(stationStats))
	for station := range stationStats {
		stations = append(stations, station)
	}
	sort.Strings(stations)

	fmt.Fprint(output, "{")
	for i, station := range stations {
		if i > 0 {
			fmt.Fprint(output, ", ")
		}
		s := stationStats[station]
		mean := float64(s.sum) / float64(s.count) / 10
		fmt.Fprintf(output, "%s=%.1f/%.1f/%.1f", station, float64(s.min)/10, mean, float64(s.max)/10)
	}
	fmt.Fprint(output, "}\n")
	return nil
}
```

##### Solution 5: avoid bytes.Cut

```go
// r5: avoid bytes.Cut
//
// ~442ms for 10M rows (2.27x as fast as r1)

package main

import (
	"bufio"
	"fmt"
	"io"
	"os"
	"sort"
)

func r5(inputPath string, output io.Writer) error {
	type stats struct {
		min, max, count int32
		sum             int64
	}

	f, err := os.Open(inputPath)
	if err != nil {
		return err
	}
	defer f.Close()

	stationStats := make(map[string]*stats)

	scanner := bufio.NewScanner(f)
	for scanner.Scan() {
		line := scanner.Bytes()

		end := len(line)
		tenths := int32(line[end-1] - '0')
		ones := int32(line[end-3] - '0') // line[end-2] is '.'
		var temp int32
		var semicolon int
		if line[end-4] == ';' {
			temp = ones*10 + tenths
			semicolon = end - 4
		} else if line[end-4] == '-' {
			temp = -(ones*10 + tenths)
			semicolon = end - 5
		} else {
			tens := int32(line[end-4] - '0')
			if line[end-5] == ';' {
				temp = tens*100 + ones*10 + tenths
				semicolon = end - 5
			} else { // '-'
				temp = -(tens*100 + ones*10 + tenths)
				semicolon = end - 6
			}
		}

		station := line[:semicolon]
		s := stationStats[string(station)]
		if s == nil {
			stationStats[string(station)] = &stats{
				min:   temp,
				max:   temp,
				sum:   int64(temp),
				count: 1,
			}
		} else {
			s.min = min(s.min, temp)
			s.max = max(s.max, temp)
			s.sum += int64(temp)
			s.count++
		}
	}

	stations := make([]string, 0, len(stationStats))
	for station := range stationStats {
		stations = append(stations, station)
	}
	sort.Strings(stations)

	fmt.Fprint(output, "{")
	for i, station := range stations {
		if i > 0 {
			fmt.Fprint(output, ", ")
		}
		s := stationStats[station]
		mean := float64(s.sum) / float64(s.count) / 10
		fmt.Fprintf(output, "%s=%.1f/%.1f/%.1f", station, float64(s.min)/10, mean, float64(s.max)/10)
	}
	fmt.Fprint(output, "}\n")
	return nil
}
```

##### Solution 6: avoid bufio.Scanner

```go
// r6: don't use bufio.Scanner to avoid scanning some bytes twice
//
// ~399ms for 10M rows (2.52x as fast as r1)

package main

import (
	"bytes"
	"fmt"
	"io"
	"os"
	"sort"
)

func r6(inputPath string, output io.Writer) error {
	type stats struct {
		min, max, count int32
		sum             int64
	}

	f, err := os.Open(inputPath)
	if err != nil {
		return err
	}
	defer f.Close()

	stationStats := make(map[string]*stats)

	buf := make([]byte, 1024*1024)
	readStart := 0
	for {
		n, err := f.Read(buf[readStart:])
		if err != nil && err != io.EOF {
			return err
		}
		if readStart+n == 0 {
			break
		}
		chunk := buf[:readStart+n]

		newline := bytes.LastIndexByte(chunk, '\n')
		if newline < 0 {
			break
		}
		remaining := chunk[newline+1:]
		chunk = chunk[:newline+1]

		for {
			station, after, hasSemi := bytes.Cut(chunk, []byte(";"))
			if !hasSemi {
				break
			}

			index := 0
			negative := false
			if after[index] == '-' {
				negative = true
				index++
			}
			temp := int32(after[index] - '0')
			index++
			if after[index] != '.' {
				temp = temp*10 + int32(after[index]-'0')
				index++
			}
			index++ // skip '.'
			temp = temp*10 + int32(after[index]-'0')
			index += 2 // skip last digit and '\n'
			if negative {
				temp = -temp
			}
			chunk = after[index:]

			s := stationStats[string(station)]
			if s == nil {
				stationStats[string(station)] = &stats{
					min:   temp,
					max:   temp,
					sum:   int64(temp),
					count: 1,
				}
			} else {
				s.min = min(s.min, temp)
				s.max = max(s.max, temp)
				s.sum += int64(temp)
				s.count++
			}
		}

		readStart = copy(buf, remaining)
	}

	stations := make([]string, 0, len(stationStats))
	for station := range stationStats {
		stations = append(stations, station)
	}
	sort.Strings(stations)

	fmt.Fprint(output, "{")
	for i, station := range stations {
		if i > 0 {
			fmt.Fprint(output, ", ")
		}
		s := stationStats[station]
		mean := float64(s.sum) / float64(s.count) / 10
		fmt.Fprintf(output, "%s=%.1f/%.1f/%.1f", station, float64(s.min)/10, mean, float64(s.max)/10)
	}
	fmt.Fprint(output, "}\n")
	return nil
}
```

##### Solution 7: custom hash table

```go
// r7: use custom hash table and hash station name as we look for ';'
//
// ~234ms for 10M rows (4.29x as fast as r1)

package main

import (
	"bytes"
	"fmt"
	"io"
	"os"
	"sort"
)

func r7(inputPath string, output io.Writer) error {
	type stats struct {
		min, max, count int32
		sum             int64
	}

	f, err := os.Open(inputPath)
	if err != nil {
		return err
	}
	defer f.Close()

	type item struct {
		key  []byte
		stat *stats
	}
	const numBuckets = 1 << 17        // number of hash buckets (power of 2)
	items := make([]item, numBuckets) // hash buckets, linearly probed
	size := 0                         // number of active items in items slice

	buf := make([]byte, 1024*1024)
	readStart := 0
	for {
		n, err := f.Read(buf[readStart:])
		if err != nil && err != io.EOF {
			return err
		}
		if readStart+n == 0 {
			break
		}
		chunk := buf[:readStart+n]

		newline := bytes.LastIndexByte(chunk, '\n')
		if newline < 0 {
			break
		}
		remaining := chunk[newline+1:]
		chunk = chunk[:newline+1]

		for {
			const (
				// FNV-1 64-bit constants from hash/fnv.
				offset64 = 14695981039346656037
				prime64  = 1099511628211
			)

			var station, after []byte
			hash := uint64(offset64)
			i := 0
			for ; i < len(chunk); i++ {
				c := chunk[i]
				if c == ';' {
					station = chunk[:i]
					after = chunk[i+1:]
					break
				}
				hash ^= uint64(c) // FNV-1a is XOR then *
				hash *= prime64
			}
			if i == len(chunk) {
				break
			}

			index := 0
			negative := false
			if after[index] == '-' {
				negative = true
				index++
			}
			temp := int32(after[index] - '0')
			index++
			if after[index] != '.' {
				temp = temp*10 + int32(after[index]-'0')
				index++
			}
			index++ // skip '.'
			temp = temp*10 + int32(after[index]-'0')
			index += 2 // skip last digit and '\n'
			if negative {
				temp = -temp
			}
			chunk = after[index:]

			hashIndex := int(hash & uint64(numBuckets-1))
			for {
				if items[hashIndex].key == nil {
					// Found empty slot, add new item (copying key).
					key := make([]byte, len(station))
					copy(key, station)
					items[hashIndex] = item{
						key: key,
						stat: &stats{
							min:   temp,
							max:   temp,
							sum:   int64(temp),
							count: 1,
						},
					}
					size++
					if size > numBuckets/2 {
						panic("too many items in hash table")
					}
					break
				}
				if bytes.Equal(items[hashIndex].key, station) {
					// Found matching slot, add to existing stats.
					s := items[hashIndex].stat
					s.min = min(s.min, temp)
					s.max = max(s.max, temp)
					s.sum += int64(temp)
					s.count++
					break
				}
				// Slot already holds another key, try next slot (linear probe).
				hashIndex++
				if hashIndex >= numBuckets {
					hashIndex = 0
				}
			}
		}

		readStart = copy(buf, remaining)
	}

	stationItems := make([]item, 0, size)
	for _, item := range items {
		if item.key == nil {
			continue
		}
		stationItems = append(stationItems, item)
	}
	sort.Slice(stationItems, func(i, j int) bool {
		return string(stationItems[i].key) < string(stationItems[j].key)
	})

	fmt.Fprint(output, "{")
	for i, item := range stationItems {
		if i > 0 {
			fmt.Fprint(output, ", ")
		}
		s := item.stat
		mean := float64(s.sum) / float64(s.count) / 10
		fmt.Fprintf(output, "%s=%.1f/%.1f/%.1f", item.key, float64(s.min)/10, mean, float64(s.max)/10)
	}
	fmt.Fprint(output, "}\n")
	return nil
}
```

##### Solution 8: process chunks in parallel

```go
// r8: add some parallelism (but back to non-optimized r1 version)
//
// ~213ms for 10M rows (4.71x as fast as r1)

package main

import (
	"bufio"
	"bytes"
	"fmt"
	"io"
	"os"
	"sort"
	"strconv"
	"strings"
)

type r8Stats struct {
	min, max, sum float64
	count         int64
}

func r8(inputPath string, output io.Writer) error {
	parts, err := splitFile(inputPath, maxGoroutines)
	if err != nil {
		return err
	}

	resultsCh := make(chan map[string]r8Stats)
	for _, part := range parts {
		go r8ProcessPart(inputPath, part.offset, part.size, resultsCh)
	}

	totals := make(map[string]r8Stats)
	for i := 0; i < len(parts); i++ {
		result := <-resultsCh
		for station, s := range result {
			ts, ok := totals[station]
			if !ok {
				totals[station] = r8Stats{
					min:   s.min,
					max:   s.max,
					sum:   s.sum,
					count: s.count,
				}
				continue
			}
			ts.min = min(ts.min, s.min)
			ts.max = max(ts.max, s.max)
			ts.sum += s.sum
			ts.count += s.count
			totals[station] = ts
		}
	}

	stations := make([]string, 0, len(totals))
	for station := range totals {
		stations = append(stations, station)
	}
	sort.Strings(stations)

	fmt.Fprint(output, "{")
	for i, station := range stations {
		if i > 0 {
			fmt.Fprint(output, ", ")
		}
		s := totals[station]
		mean := s.sum / float64(s.count)
		fmt.Fprintf(output, "%s=%.1f/%.1f/%.1f", station, s.min, mean, s.max)
	}
	fmt.Fprint(output, "}\n")
	return nil
}

func r8ProcessPart(inputPath string, fileOffset, fileSize int64, resultsCh chan map[string]r8Stats) {
	file, err := os.Open(inputPath)
	if err != nil {
		panic(err)
	}
	defer file.Close()
	_, err = file.Seek(fileOffset, io.SeekStart)
	if err != nil {
		panic(err)
	}
	f := io.LimitedReader{R: file, N: fileSize}

	stationStats := make(map[string]r8Stats)

	scanner := bufio.NewScanner(&f)
	for scanner.Scan() {
		line := scanner.Text()
		station, tempStr, hasSemi := strings.Cut(line, ";")
		if !hasSemi {
			continue
		}

		temp, err := strconv.ParseFloat(tempStr, 64)
		if err != nil {
			panic(err)
		}

		s, ok := stationStats[station]
		if !ok {
			s.min = temp
			s.max = temp
			s.sum = temp
			s.count = 1
		} else {
			s.min = min(s.min, temp)
			s.max = max(s.max, temp)
			s.sum += temp
			s.count++
		}
		stationStats[station] = s
	}

	resultsCh <- stationStats
}

type part struct {
	offset, size int64
}

func splitFile(inputPath string, numParts int) ([]part, error) {
	const maxLineLength = 100

	f, err := os.Open(inputPath)
	if err != nil {
		return nil, err
	}
	st, err := f.Stat()
	if err != nil {
		return nil, err
	}
	size := st.Size()
	splitSize := size / int64(numParts)

	buf := make([]byte, maxLineLength)

	parts := make([]part, 0, numParts)
	offset := int64(0)
	for i := 0; i < numParts; i++ {
		if i == numParts-1 {
			if offset < size {
				parts = append(parts, part{offset, size - offset})
			}
			break
		}

		seekOffset := max(offset+splitSize-maxLineLength, 0)
		_, err := f.Seek(seekOffset, io.SeekStart)
		if err != nil {
			return nil, err
		}
		n, _ := io.ReadFull(f, buf)
		chunk := buf[:n]
		newline := bytes.LastIndexByte(chunk, '\n')
		if newline < 0 {
			return nil, fmt.Errorf("newline not found at offset %d", offset+splitSize-maxLineLength)
		}
		remaining := len(chunk) - newline - 1
		nextOffset := seekOffset + int64(len(chunk)) - int64(remaining)
		parts = append(parts, part{offset, nextOffset - offset})
		offset = nextOffset
	}
	return parts, nil
}
```

##### Solution 9: all optimisations plus parallelisation

```go
// r9: all the previous optimizations plus parallel execution
//
// 43ms for 10M rows (23.3x as fast as r1)

package main

import (
	"bytes"
	"fmt"
	"io"
	"os"
	"sort"
)

type r9Stats struct {
	min, max, count int32
	sum             int64
}

func r9(inputPath string, output io.Writer) error {
	parts, err := splitFile(inputPath, maxGoroutines)
	if err != nil {
		return err
	}

	resultsCh := make(chan map[string]*r9Stats)
	for _, part := range parts {
		go r9ProcessPart(inputPath, part.offset, part.size, resultsCh)
	}

	totals := make(map[string]*r9Stats)
	for i := 0; i < len(parts); i++ {
		result := <-resultsCh
		for station, s := range result {
			ts := totals[station]
			if ts == nil {
				totals[station] = s
				continue
			}
			ts.min = min(ts.min, s.min)
			ts.max = max(ts.max, s.max)
			ts.sum += s.sum
			ts.count += s.count
		}
	}

	stations := make([]string, 0, len(totals))
	for station := range totals {
		stations = append(stations, station)
	}
	sort.Strings(stations)

	fmt.Fprint(output, "{")
	for i, station := range stations {
		if i > 0 {
			fmt.Fprint(output, ", ")
		}
		s := totals[station]
		mean := float64(s.sum) / float64(s.count) / 10
		fmt.Fprintf(output, "%s=%.1f/%.1f/%.1f", station, float64(s.min)/10, mean, float64(s.max)/10)
	}
	fmt.Fprint(output, "}\n")
	return nil
}

func r9ProcessPart(inputPath string, fileOffset, fileSize int64, resultsCh chan map[string]*r9Stats) {
	file, err := os.Open(inputPath)
	if err != nil {
		panic(err)
	}
	defer file.Close()
	_, err = file.Seek(fileOffset, io.SeekStart)
	if err != nil {
		panic(err)
	}
	f := io.LimitedReader{R: file, N: fileSize}

	type item struct {
		key  []byte
		stat *r9Stats
	}
	const numBuckets = 1 << 17        // number of hash buckets (power of 2)
	items := make([]item, numBuckets) // hash buckets, linearly probed
	size := 0                         // number of active items in items slice

	buf := make([]byte, 1024*1024)
	readStart := 0
	for {
		n, err := f.Read(buf[readStart:])
		if err != nil && err != io.EOF {
			panic(err)
		}
		if readStart+n == 0 {
			break
		}
		chunk := buf[:readStart+n]

		newline := bytes.LastIndexByte(chunk, '\n')
		if newline < 0 {
			break
		}
		remaining := chunk[newline+1:]
		chunk = chunk[:newline+1]

		for {
			const (
				// FNV-1 64-bit constants from hash/fnv.
				offset64 = 14695981039346656037
				prime64  = 1099511628211
			)

			var station, after []byte
			hash := uint64(offset64)
			i := 0
			for ; i < len(chunk); i++ {
				c := chunk[i]
				if c == ';' {
					station = chunk[:i]
					after = chunk[i+1:]
					break
				}
				hash ^= uint64(c) // FNV-1a is XOR then *
				hash *= prime64
			}
			if i == len(chunk) {
				break
			}

			index := 0
			negative := false
			if after[index] == '-' {
				negative = true
				index++
			}
			temp := int32(after[index] - '0')
			index++
			if after[index] != '.' {
				temp = temp*10 + int32(after[index]-'0')
				index++
			}
			index++ // skip '.'
			temp = temp*10 + int32(after[index]-'0')
			index += 2 // skip last digit and '\n'
			if negative {
				temp = -temp
			}
			chunk = after[index:]

			hashIndex := int(hash & (numBuckets - 1))
			for {
				if items[hashIndex].key == nil {
					// Found empty slot, add new item (copying key).
					key := make([]byte, len(station))
					copy(key, station)
					items[hashIndex] = item{
						key: key,
						stat: &r9Stats{
							min:   temp,
							max:   temp,
							sum:   int64(temp),
							count: 1,
						},
					}
					size++
					if size > numBuckets/2 {
						panic("too many items in hash table")
					}
					break
				}
				if bytes.Equal(items[hashIndex].key, station) {
					// Found matching slot, add to existing stats.
					s := items[hashIndex].stat
					s.min = min(s.min, temp)
					s.max = max(s.max, temp)
					s.sum += int64(temp)
					s.count++
					break
				}
				// Slot already holds another key, try next slot (linear probe).
				hashIndex++
				if hashIndex >= numBuckets {
					hashIndex = 0
				}
			}
		}

		readStart = copy(buf, remaining)
	}

	result := make(map[string]*r9Stats, size)
	for _, item := range items {
		if item.key == nil {
			continue
		}
		result[string(item.key)] = item.stat
	}
	resultsCh <- result
}
```

##### Solution 10: all the previous optimizations plus faster semicolon finding and hashing

```go
// r10: all the previous optimizations plus faster semicolon finding and
// hashing
//
// Translated from Java by Menno Finlay-Smits Ideas with ideas taken from
// this fast Java solution:
//
// https://github.com/gunnarmorling/1brc/blob/main/src/main/java/dev/morling/onebrc/CalculateAverage_mtopolnik.java
//
// On my (Ben's) laptop I get these initial results:
//
// $ ./go-1brc -revision=1 ../1brc/data/measurements.txt >out-r1
// Processed 13156.2MB in 1m39.507011009s
// $ ./go-1brc -revision=9 ../1brc/data/measurements.txt >out-r9
// Processed 13156.2MB in 2.893693843s  # 34.4x as fast as the r1 above
// $ ./go-1brc -revision=10 ../1brc/data/measurements.txt >out-r10
// Processed 13156.2MB in 2.497241029s  # 39.8x as fast as the r1 above

package main

import (
	"bytes"
	"encoding/binary"
	"fmt"
	"io"
	"math/bits"
	"os"
	"sort"
)

const BroadcastSemicolon = 0x3B3B3B3B3B3B3B3B
const Broadcast0x01 = 0x0101010101010101
const Broadcast0x80 = 0x8080808080808080

type r10Stats struct {
	min, max, count int32
	sum             int64
}

func r10(inputPath string, output io.Writer) error {
	parts, err := splitFile(inputPath, maxGoroutines)
	if err != nil {
		return err
	}

	resultsCh := make(chan map[string]*r10Stats)
	for _, part := range parts {
		go r10ProcessPart(inputPath, part.offset, part.size, resultsCh)
	}

	totals := make(map[string]*r10Stats)
	for i := 0; i < len(parts); i++ {
		result := <-resultsCh
		for station, s := range result {
			ts := totals[station]
			if ts == nil {
				totals[station] = s
				continue
			}
			ts.min = min(ts.min, s.min)
			ts.max = max(ts.max, s.max)
			ts.sum += s.sum
			ts.count += s.count
		}
	}

	stations := make([]string, 0, len(totals))
	for station := range totals {
		stations = append(stations, station)
	}
	sort.Strings(stations)

	fmt.Fprint(output, "{")
	for i, station := range stations {
		if i > 0 {
			fmt.Fprint(output, ", ")
		}
		s := totals[station]
		mean := float64(s.sum) / float64(s.count) / 10
		fmt.Fprintf(output, "%s=%.1f/%.1f/%.1f", station, float64(s.min)/10, mean, float64(s.max)/10)
	}
	fmt.Fprint(output, "}\n")

	return nil
}

func r10ProcessPart(inputPath string, fileOffset, fileSize int64, resultsCh chan map[string]*r10Stats) {
	file, err := os.Open(inputPath)
	if err != nil {
		panic(err)
	}
	defer file.Close()
	_, err = file.Seek(fileOffset, io.SeekStart)
	if err != nil {
		panic(err)
	}
	f := io.LimitedReader{R: file, N: fileSize}

	type item struct {
		key  []byte
		stat *r10Stats
	}
	const numBuckets = 1 << 17        // number of hash buckets (power of 2)
	items := make([]item, numBuckets) // hash buckets, linearly probed
	size := 0                         // number of active items in items slice

	buf := make([]byte, 1024*1024)
	readStart := 0
	for {
		n, err := f.Read(buf[readStart:])
		if err != nil && err != io.EOF {
			panic(err)
		}
		if readStart+n == 0 {
			break
		}
		chunk := buf[:readStart+n]

		newline := bytes.LastIndexByte(chunk, '\n')
		if newline < 0 {
			break
		}
		remaining := chunk[newline+1:]
		chunk = chunk[:newline+1]

	chunkLoop:
		for {
			var hash uint64
			var station, after []byte

			if len(chunk) < 8 {
				break chunkLoop
			}

			nameWord0 := binary.NativeEndian.Uint64(chunk)
			matchBits := semicolonMatchBits(nameWord0)
			if matchBits != 0 {
				// semicolon is in the first 8 bytes
				nameLen := calcNameLen(matchBits)
				nameWord0 = maskWord(nameWord0, matchBits)
				station = chunk[:nameLen]
				after = chunk[nameLen+1:]
				hash = calcHash(nameWord0)
			} else {
				// station name is longer so keep looking for the semicolon in
				// uint64 chunks
				nameLen := 8
				hash = calcHash(nameWord0)
				for {
					if nameLen > len(chunk)-8 {
						break chunkLoop
					}
					lastNameWord := binary.NativeEndian.Uint64(chunk[nameLen:])
					matchBits = semicolonMatchBits(lastNameWord)
					if matchBits != 0 {
						nameLen += calcNameLen(matchBits)
						station = chunk[:nameLen]
						after = chunk[nameLen+1:]
						break
					}
					nameLen += 8
				}
			}
			index := 0
			negative := false
			if after[index] == '-' {
				negative = true
				index++
			}
			temp := int32(after[index] - '0')
			index++
			if after[index] != '.' {
				temp = temp*10 + int32(after[index]-'0')
				index++
			}
			index++ // skip '.'
			temp = temp*10 + int32(after[index]-'0')
			index += 2 // skip last digit and '\n'
			if negative {
				temp = -temp
			}
			chunk = after[index:]

			hashIndex := int(hash & (numBuckets - 1))
			for {
				if items[hashIndex].key == nil {
					// Found empty slot, add new item (copying key).
					key := make([]byte, len(station))
					copy(key, station)
					items[hashIndex] = item{
						key: key,
						stat: &r10Stats{
							min:   temp,
							max:   temp,
							sum:   int64(temp),
							count: 1,
						},
					}
					size++
					if size > numBuckets/2 {
						panic("too many items in hash table")
					}
					break
				}
				if bytes.Equal(items[hashIndex].key, station) {
					// Found matching slot, add to existing stats.
					s := items[hashIndex].stat
					s.min = min(s.min, temp)
					s.max = max(s.max, temp)
					s.sum += int64(temp)
					s.count++
					break
				}
				// Slot already holds another key, try next slot (linear probe).
				hashIndex++
				if hashIndex >= numBuckets {
					hashIndex = 0
				}
			}
		}

		readStart = copy(buf, remaining)
	}

	result := make(map[string]*r10Stats, size)
	for _, item := range items {
		if item.key == nil {
			continue
		}
		result[string(item.key)] = item.stat
	}
	resultsCh <- result
}

func calcNameLen(b uint64) int {
	return (bits.TrailingZeros64(b) >> 3)
}

func calcHash(word uint64) uint64 {
	return bits.RotateLeft64(word*0x51_7c_c1_b7_27_22_0a_95, 17)
}

func semicolonMatchBits(word uint64) uint64 {
	diff := word ^ BroadcastSemicolon
	return (diff - Broadcast0x01) & (^diff & Broadcast0x80)
}

func maskWord(word, matchBits uint64) uint64 {
	mask := matchBits ^ (matchBits - 1)
	return word & mask
}
```

---

- [The One Billion Row Challenge](https://github.com/gunnarmorling/1brc)
- https://github.com/gunnarmorling/1brc/tree/main/src/main/go/AlexanderYastrebov

##### Alexander Yastrebov

```go
package main

import (
	"bytes"
	"fmt"
	"log"
	"math"
	"os"
	"runtime"
	"sort"
	"sync"
	"syscall"
)

type measurement struct {
	min, max, sum, count int64
}

func main() {
	if len(os.Args) != 2 {
		log.Fatalf("Missing measurements filename")
	}

	measurements := processFile(os.Args[1])

	ids := make([]string, 0, len(measurements))
	for id := range measurements {
		ids = append(ids, id)
	}
	sort.Strings(ids)

	fmt.Print("{")
	for i, id := range ids {
		if i > 0 {
			fmt.Print(", ")
		}
		m := measurements[id]
		fmt.Printf("%s=%.1f/%.1f/%.1f", id, round(float64(m.min)/10.0), round(float64(m.sum)/10.0/float64(m.count)), round(float64(m.max)/10.0))
	}
	fmt.Println("}")
}

func processFile(filename string) map[string]*measurement {
	f, err := os.Open(filename)
	if err != nil {
		log.Fatalf("Open: %v", err)
	}
	defer f.Close()

	fi, err := f.Stat()
	if err != nil {
		log.Fatalf("Stat: %v", err)
	}

	size := fi.Size()
	if size <= 0 || size != int64(int(size)) {
		log.Fatalf("Invalid file size: %d", size)
	}

	data, err := syscall.Mmap(int(f.Fd()), 0, int(size), syscall.PROT_READ, syscall.MAP_SHARED)
	if err != nil {
		log.Fatalf("Mmap: %v", err)
	}

	defer func() {
		if err := syscall.Munmap(data); err != nil {
			log.Fatalf("Munmap: %v", err)
		}
	}()

	return process(data)
}

func process(data []byte) map[string]*measurement {
	nChunks := runtime.NumCPU()

	chunkSize := len(data) / nChunks
	if chunkSize == 0 {
		chunkSize = len(data)
	}

	chunks := make([]int, 0, nChunks)
	offset := 0
	for offset < len(data) {
		offset += chunkSize
		if offset >= len(data) {
			chunks = append(chunks, len(data))
			break
		}

		nlPos := bytes.IndexByte(data[offset:], '\n')
		if nlPos == -1 {
			chunks = append(chunks, len(data))
			break
		} else {
			offset += nlPos + 1
			chunks = append(chunks, offset)
		}
	}

	var wg sync.WaitGroup
	wg.Add(len(chunks))

	results := make([]map[string]*measurement, len(chunks))
	start := 0
	for i, chunk := range chunks {
		go func(data []byte, i int) {
			results[i] = processChunk(data)
			wg.Done()
		}(data[start:chunk], i)
		start = chunk
	}
	wg.Wait()

	measurements := make(map[string]*measurement)
	for _, r := range results {
		for id, rm := range r {
			m := measurements[id]
			if m == nil {
				measurements[id] = rm
			} else {
				m.min = min(m.min, rm.min)
				m.max = max(m.max, rm.max)
				m.sum += rm.sum
				m.count += rm.count
			}
		}
	}
	return measurements
}

func processChunk(data []byte) map[string]*measurement {
	// Use fixed size linear probe lookup table
	const (
		// use power of 2 for fast modulo calculation,
		// should be larger than max number of keys which is 10_000
		entriesSize = 1 << 14

		// use FNV-1a hash
		fnv1aOffset64 = 14695981039346656037
		fnv1aPrime64  = 1099511628211
	)

	type entry struct {
		m     measurement
		hash  uint64
		vlen  int
		value [128]byte // use power of 2 > 100 for alignment
	}
	entries := make([]entry, entriesSize)
	entriesCount := 0

	// keep short and inlinable
	getMeasurement := func(hash uint64, value []byte) *measurement {
		i := hash & uint64(entriesSize-1)
		entry := &entries[i]

		// bytes.Equal could be commented to speedup assuming no hash collisions
		for entry.vlen > 0 && !(entry.hash == hash && bytes.Equal(entry.value[:entry.vlen], value)) {
			i = (i + 1) & uint64(entriesSize-1)
			entry = &entries[i]
		}

		if entry.vlen == 0 {
			entry.hash = hash
			entry.vlen = copy(entry.value[:], value)
			entriesCount++
		}
		return &entry.m
	}

	// assume valid input
	for len(data) > 0 {

		idHash := uint64(fnv1aOffset64)
		semiPos := 0
		for i, b := range data {
			if b == ';' {
				semiPos = i
				break
			}

			// calculate FNV-1a hash
			idHash ^= uint64(b)
			idHash *= fnv1aPrime64
		}

		idData := data[:semiPos]

		data = data[semiPos+1:]

		var temp int64
		// parseNumber
		{
			negative := data[0] == '-'
			if negative {
				data = data[1:]
			}

			_ = data[3]
			if data[1] == '.' {
				// 1.2\n
				temp = int64(data[0])*10 + int64(data[2]) - '0'*(10+1)
				data = data[4:]
				// 12.3\n
			} else {
				_ = data[4]
				temp = int64(data[0])*100 + int64(data[1])*10 + int64(data[3]) - '0'*(100+10+1)
				data = data[5:]
			}

			if negative {
				temp = -temp
			}
		}

		m := getMeasurement(idHash, idData)
		if m.count == 0 {
			m.min = temp
			m.max = temp
			m.sum = temp
			m.count = 1
		} else {
			m.min = min(m.min, temp)
			m.max = max(m.max, temp)
			m.sum += temp
			m.count++
		}
	}

	result := make(map[string]*measurement, entriesCount)
	for i := range entries {
		entry := &entries[i]
		if entry.m.count > 0 {
			result[string(entry.value[:entry.vlen])] = &entry.m
		}
	}
	return result
}

func round(x float64) float64 {
	return roundJava(x*10.0) / 10.0
}

// roundJava returns the closest integer to the argument, with ties
// rounding to positive infinity, see java's Math.round
func roundJava(x float64) float64 {
	t := math.Trunc(x)
	if x < 0.0 && t-x == 0.5 {
		//return t
	} else if math.Abs(x-t) >= 0.5 {
		t += math.Copysign(1, x)
	}

	if t == 0 { // check -0
		return 0.0
	}
	return t
}

// parseNumber reads decimal number that matches "^-?[0-9]{1,2}[.][0-9]" pattern,
// e.g.: -12.3, -3.4, 5.6, 78.9 and return the value*10, i.e. -123, -34, 56, 789.
func parseNumber(data []byte) int64 {
	negative := data[0] == '-'
	if negative {
		data = data[1:]
	}

	var result int64
	switch len(data) {
	// 1.2
	case 3:
		result = int64(data[0])*10 + int64(data[2]) - '0'*(10+1)
	// 12.3
	case 4:
		result = int64(data[0])*100 + int64(data[1])*10 + int64(data[3]) - '0'*(100+10+1)
	}

	if negative {
		return -result
	}
	return result
}
```

---

- https://github.com/aytechnet/1brc

##### François Pons

```go
package main

import (
	"bytes"
	"flag"
	"fmt"
	"log"
	"os"
	"runtime"
	"runtime/pprof"
	"slices"
	"sync"
	"syscall"
	"sync/atomic"

	"github.com/aytechnet/decimal"
)

type (
	measurement struct {
		hash    atomic.Uint64
		minT    atomic.Int64
		maxT    atomic.Int64
		sumT    atomic.Int64
		countT  atomic.Int64
		nameLen int
		nameBuf [208]byte
	}

	measurements struct {
		total       atomic.Int64
		numParsers  int
		results     [capacity]measurement
	}

	job struct {
		maxOffset atomic.Int64
		bufLen    int
		buf       [bufSize]byte
	}
)

const (
	delta = 439
	capacity = 1 << 16 // must be a power of 2 for modulo calculation

	// buffer size
	bufSize = 512 * 1024 // 1Mb

	// use FNV-1a hash
	fnv1aOffset64 = 14695981039346656037
	fnv1aPrime64  = 1099511628211
)

func main() {
	var mode, filename, cpuprofile string
	var res measurements

	flag.StringVar(&mode, "mode", "default", "Which mode to use among 'mmap', 'seq' and 'default'")
	flag.StringVar(&filename, "file", "", "Measurements file to use")
	flag.StringVar(&cpuprofile, "cpuprofile", "", "Write cpuprofile to file")
	flag.IntVar(&res.numParsers, "parsers", runtime.NumCPU(), "Number of thread to use for parsing")

	flag.Parse()

	if filename == "" {
		flag.Usage()
		os.Exit(1)
	}

	if cpuprofile != "" {
		if f, err := os.Create(cpuprofile); err != nil {
			log.Fatal(err)
		} else {
			pprof.StartCPUProfile(f)
			defer pprof.StopCPUProfile()
		}
	}

	f, err := os.Open(filename)
	if err != nil {
		log.Fatalf("Open: %v", err)
	}
	defer f.Close()

	switch mode {
	case "mmap":
		res.processMmap(f)
	case "seq":
		res.processSeq(f)
	default:
		res.process(f)
	}
}

func (res *measurements) processMmap(f *os.File) {
	jobs := make([]job, res.numParsers)

	fi, err := f.Stat()
	if err != nil {
		log.Fatalf("Stat: %v", err)
	}

	size := fi.Size()
	chunkSize := size/int64(len(jobs))
	if chunkSize <= 100 {
		log.Fatalf("Invalid file size: %d", size)
	}

	data, err := syscall.Mmap(int(f.Fd()), 0, int(size), syscall.PROT_READ, syscall.MAP_SHARED)
	if err != nil {
		log.Fatalf("Mmap: %v", err)
	}

	defer func() {
		if err := syscall.Munmap(data); err != nil {
			log.Fatalf("Munmap: %v", err)
		}
	}()

	offset := chunkSize
	for i := range jobs {
		j := &jobs[i]

		if i == len(jobs)-1 {
			j.maxOffset.Store(size)
		} else {
			j.maxOffset.Store(-offset)
		}
		offset += chunkSize
	}

	var wg sync.WaitGroup

	wg.Add(len(jobs))

	offset = 0
	for i := range jobs {
		go func(i int, offset int64){
			defer wg.Done()

			j := &jobs[i]

			maxOffset := j.maxOffset.Load()
			if maxOffset < 0 {
				maxOffset = -maxOffset

				if nlPos := bytes.IndexByte(data[maxOffset:], '\n'); nlPos >= 0 {
					maxOffset += int64(nlPos+1)
				}
			}

			if offset > 0 {
				if nlPos := bytes.IndexByte(data[offset:maxOffset], '\n'); nlPos >= 0 {
					offset += int64(nlPos+1)
				}
			}

			res.processChunk(data[offset:maxOffset])
		}(i, offset)

		offset += chunkSize
	}

	wg.Wait()

	res.printResults()
}

func (res *measurements) processSeq(f *os.File) {
	jobs := make([]job, res.numParsers)
	free_jobs := make(chan *job, len(jobs))
	ready_jobs := make(chan *job, len(jobs))

	var wg sync.WaitGroup

	wg.Add(len(jobs))

	for i := range jobs {
		j := &jobs[i]

		free_jobs <- j
		go func(){
			for j := range ready_jobs {
				res.processChunk(j.buf[:j.bufLen])
				free_jobs <- j
			}
			wg.Done()
		}()
	}

	var prev_j *job

	pos := 0
	nlPos := 0
	for j := range free_jobs {
		if count, _ := f.Read(j.buf[pos:]); count > 0 {
			// finalize previous line from previous job
			if pos > 0 /* && prev_j != nil */ {
				copy(j.buf[:pos], prev_j.buf[bufSize-pos:])
			}

			// prepare next buffer
			if nlPos = bytes.LastIndexByte(j.buf[:pos+count], '\n'); nlPos < 0 {
				log.Fatalf("buffer too small for a complete line");
			} else {
				pos = pos + count - nlPos - 1
				prev_j = j
				j.bufLen = nlPos + 1
			}

			// spawn a new job on this buffer
			ready_jobs <- j
		} else {
			break
		}
	}

	close(ready_jobs)

	wg.Wait()

	close(free_jobs)

	res.printResults()
}

func (res *measurements) process(f *os.File) {
	jobs := make([]job, res.numParsers)

	fi, err := f.Stat()
	if err != nil {
		log.Fatalf("Stat: %v", err)
	}

	size := fi.Size()
	chunkSize := size/int64(len(jobs))
	if chunkSize <= 100 {
		log.Fatalf("Invalid file size: %d", size)
	}

	offset := chunkSize
	for i := range jobs {
		j := &jobs[i]

		if i == len(jobs)-1 {
			j.maxOffset.Store(size)
		} else {
			j.maxOffset.Store(-offset)
		}
		offset += chunkSize
	}

	var wg sync.WaitGroup

	wg.Add(len(jobs))

	offset = 0
	for i := range jobs {
		go func(i int, offset int64){
			defer wg.Done()

			j := &jobs[i]

			nlSkipFirst := offset > 0

			for {
				maxLen := bufSize
				maxOffset := j.maxOffset.Load()
				if maxOffset < 0 {
					maxOffset = -maxOffset
				}
				if offset + int64(maxLen) > maxOffset {
					maxLen = int(maxOffset - offset)
				}

				if count, _ := f.ReadAt(j.buf[:maxLen], offset); count > 0 {
					pos := 0
					if nlSkipFirst {
						if nlPos := bytes.IndexByte(j.buf[:maxLen], '\n'); nlPos >= 0 {
							pos = nlPos + 1
							jobs[i-1].maxOffset.Store(offset + int64(pos))
							nlSkipFirst = false
						} else {
							log.Fatalf("Unable to seek to next line at job n°%d", i)
						}
					}

					if nlPos := bytes.LastIndexByte(j.buf[pos:maxLen], '\n'); nlPos >= 0 {
						j.bufLen = pos + nlPos + 1
						offset += int64(j.bufLen)

						res.processChunk(j.buf[pos:j.bufLen])
					} else {
						log.Fatalf("Buffer too small at job n°%d", i)
					}
				} else {
					return
				}

				maxOffset = j.maxOffset.Load()
				for maxOffset < 0 {
					maxOffset = j.maxOffset.Load()
				}
				if offset >= maxOffset {
					return
				}
			}
		}(i, offset)

		offset += chunkSize
	}

	wg.Wait()

	res.printResults()
}

func (res *measurements) printResults() {
	log.Printf("Read %d entries", res.total.Load())

	ids := make([]int, 0, capacity)

	for i := range res.results {
		m := &res.results[i]

		if m.nameLen > 0 {
			ids = append(ids, i)
		}
	}

	slices.SortFunc(ids, func(a,b int) int {
		return bytes.Compare(res.results[a].nameBuf[0:res.results[a].nameLen], res.results[b].nameBuf[0:res.results[b].nameLen])
	})

	count := 0
	fmt.Print("{")
	for _, i := range ids {
		m := &res.results[i]

		var buf [128]byte // name is 100 chars max, each 3 decimals is 5 bytes max on output
		b := buf[0:0]

		if count > 0 {
			b = append(b, ',', ' ')
		}

		b = append(b, m.nameBuf[0:m.nameLen]...)
		b = append(b, '=')
		b = decimal.New(m.minT.Load(), -1).BytesToFixed(b, 1)
		b = append(b, '/')
		b = decimal.New(m.sumT.Load(), -1).Div(decimal.NewFromInt(m.countT.Load()-1)).BytesToFixed(b, 1)
		b = append(b, '/')
		b = decimal.New(m.maxT.Load(), -1).BytesToFixed(b, 1)
		count++

		fmt.Print(string(b))
		// fmt.Printf("%s=%s/%s/%s", m.nameBuf[0:m.nameLen], decimal.New(m.minT.Load(), -1).StringFixed(1), decimal.New(m.sumT.Load(), -1).Div(decimal.NewFromInt(m.countT.Load()-1)).StringFixed(1), decimal.New(m.maxT.Load(), -1).StringFixed(1))
		count++
	}
	fmt.Println("}")
}

func (res *measurements) processChunk(data []byte) {
	var total int64

	// assume valid input
	for len(data) > 0 {
		i := 0

		// compute FNV-1a hash
		idHash := uint64(fnv1aOffset64)
		for j, b := range data {
			if b == ';' {
				i = j
				break
			}

			// calculate FNV-1a hash
			idHash ^= uint64(b)
			idHash *= fnv1aPrime64
		}
		if idHash == 0 {
			idHash = uint64(len(data))
		}

		idData := data[:i]

		i++ // now i points to temperature

		var temp int64
		// parseNumber
		{
			negative := data[i] == '-'
			if negative {
				i++
			}

			temp = int64(data[i]-'0')
			i++

			if data[i] != '.' {
				temp = temp*10 + int64(data[i]-'0')
				i++
			}
			i++ // data[i] is '.'
			temp = temp*10 + int64(data[i]-'0')
			if negative {
				temp = -temp
			}

			data = data[i+2:]
		}

		// get measurement
		{
			i := idHash & uint64(capacity-1)
			entry := &res.results[i]

			for {
				if entry.hash.CompareAndSwap(0, idHash) {
					// make sure no race occurs as entry may be updated meanwhile as hash has been updated
					if entry.countT.Add(1) == 1 {
						entry.nameLen = len(idData)
						copy(entry.nameBuf[:], idData)
						entry.minT.Store(temp)
						entry.maxT.Store(temp)
						entry.sumT.Store(temp)
						entry.countT.Add(1) // unlock for update below
					} else {
						// wait for countT to be at least 2 for entry init to be complete
						for entry.countT.Load() < 2 {}

						// update existing entry
						minT := entry.minT.Load()
						for minT > temp {
							if entry.minT.CompareAndSwap(minT, temp) {
								break
							} else {
								minT = entry.minT.Load()
							}
						}
						maxT := entry.maxT.Load()
						for maxT < temp {
							if entry.maxT.CompareAndSwap(maxT, temp) {
								break
							} else {
								maxT = entry.maxT.Load()
							}
						}
						entry.sumT.Add(temp)
						entry.countT.Add(1)
					}
					break
				} else if entry.hash.Load() == idHash {
					// the entry is found and may be being updated by another thread
					// wait for countT to be at least 2 for entry init to be complete
					for entry.countT.Load() < 2 {}

					// now that name has been updated, check it is matching
					if len(idData) == entry.nameLen /* bytes.Compare(idData, entry.nameBuf[0:entry.nameLen]) == 0 */ {
						// update existing entry
						minT := entry.minT.Load()
						for minT > temp {
							if entry.minT.CompareAndSwap(minT, temp) {
								break
							} else {
								minT = entry.minT.Load()
							}
						}
						maxT := entry.maxT.Load()
						for maxT < temp {
							if entry.maxT.CompareAndSwap(maxT, temp) {
								break
							} else {
								maxT = entry.maxT.Load()
							}
						}
						entry.sumT.Add(temp)
						entry.countT.Add(1)

						break
					} else {
						// name does not match idData so jump to next entry
						i = (i + delta) & uint64(capacity-1)
						entry = &res.results[i]
					}
				} else {
					i = (i + delta) & uint64(capacity-1)
					entry = &res.results[i]
				}
			}
		}

		total++
	}

	res.total.Add(total)
}

func (entry *measurement) update(temp int64) {
	minT := entry.minT.Load()
	for minT > temp {
		if entry.minT.CompareAndSwap(minT, temp) {
			break
		} else {
			minT = entry.minT.Load()
		}
	}
	maxT := entry.maxT.Load()
	for maxT < temp {
		if entry.maxT.CompareAndSwap(maxT, temp) {
			break
		} else {
			maxT = entry.maxT.Load()
		}
	}
	entry.sumT.Add(temp)
	entry.countT.Add(1)
}

```
