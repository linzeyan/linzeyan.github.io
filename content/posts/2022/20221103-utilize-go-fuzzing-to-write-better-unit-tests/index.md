---
title: "善用 Go Fuzzing，幫助你寫出更完整的單元測試"
date: 2022-11-03T16:57:29+08:00
menu:
  sidebar:
    name: "善用 Go Fuzzing，幫助你寫出更完整的單元測試"
    identifier: go-utilize-go-fuzzing-to-write-better-unit-tests
    weight: 10
tags: ["URL", "Go", "Testing"]
categories: ["URL", "Go", "Testing"]
hero: images/hero/go.svg
---

- [善用 Go Fuzzing，幫助你寫出更完整的單元測試](https://medium.com/starbugs/utilize-go-fuzzing-to-write-better-unit-tests-80bd37cd4e38)

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

- 在做 Fuzzing Test 的時候如果跑一跑 FAIL 了，Go 會幫忙把那組 input 記在 testcase/ 裡面
- 看了之後會發現在 x=6、y=30 時 assert 會失敗，也就是說 pow(6, 30)/6 不會等於 pow(6, 29)。但這也太奇怪了吧？仔細實驗之後才發現是因為在計算 pow(6, 30) 的時候會發生 overflow。
- 因為 Go 定義的 max.MaxUint 大約是 18 \* 10¹⁸，但 6²⁹ 大概是 7 \* 10¹⁸。如果把 6²⁹ 再乘上 6，就會發生 overflow 得到 8 \* 10¹⁸，很像繞了操場兩圈結果在跟原本差不多的位置。

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
