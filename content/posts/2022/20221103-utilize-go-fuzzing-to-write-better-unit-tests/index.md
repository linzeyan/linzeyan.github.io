---
title: "Use Go Fuzzing to Write More Complete Unit Tests"
date: 2022-11-03T16:57:29+08:00
menu:
  sidebar:
    name: "Use Go Fuzzing to Write More Complete Unit Tests"
    identifier: go-utilize-go-fuzzing-to-write-better-unit-tests
    weight: 10
tags: ["Links", "Go", "Testing"]
categories: ["Links", "Go", "Testing"]
hero: images/hero/go.svg
---

- [Use Go Fuzzing to Write More Complete Unit Tests](https://medium.com/starbugs/utilize-go-fuzzing-to-write-better-unit-tests-80bd37cd4e38)

```go
func Pow(base uint, exponent uint) uint {
	if exponent == 0 {
		return 1
	}

	return base * Pow(base, exponent-1)
}

```

```go
func FuzzPow(f *testing.F) {
  f.Fuzz(func(t *testing.T, x, y uint) {
	  assert := assert.New(t)

	  assert.Equal(Pow(x, 0), uint(1))
	  assert.Equal(Pow(x, 1), x)
	  assert.Equal(Pow(x, 2), x*x)

	  if x > 0 && y > 0 {
	  	assert.Equal(Pow(x, y)/x, Pow(x, y-1))
	  }
  })
}
```

`go test -fuzz=Fuzz -fuzztime 20s`

- When a fuzz test fails, Go records the input in testcase/
- You will find that when x=6 and y=30, the assert fails, i.e., pow(6, 30)/6 is not equal to pow(6, 29). That seems odd, but after testing you will see it is because pow(6, 30) overflows.
- The max.MaxUint in Go is about `18 * 10^¹⁸`, while `6^²⁹` is about `7 * 10^¹⁸`. If you multiply `6^²⁹` by 6, it overflows and yields `8 * 10^¹⁸`. It is like running two laps and ending up near the starting point.

```go
var ErrOverflow = fmt.Errorf("overflow")

func Pow(base uint, exponent uint) (uint, error) {
	if exponent == 0 {
		return 1
	}

	prevResult, err := Pow(base, exponent-1)
	if math.MaxUint/base < prevResult {
		return 0, ErrOverflow
	}

	return base * prevResult, nil
}
```

```go
func FuzzPow(f *testing.F) {
  f.Fuzz(func(t *testing.T, x, y uint) {
    assert := assert.New(t)
  	if result, err := Pow(x, 1); err != ErrOverflow {
  		assert.Equal(result, x)
  	}

  	if result, err := Pow(x, y); x > 0 && y > 0 && err != ErrOverflow {
  		resultDivX, _ := Pow(x, y-1)
  		assert.Equal(result/x, resultDivX)
  	}
  })
}
```
