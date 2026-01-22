---
title: "Go 文章"
date: 2024-08-20T08:55:00+08:00
menu:
  sidebar:
    name: Go 文章
    identifier: golang-articles-202408200855
    weight: 10
tags: ["Go", "Links", "GIN", "byte", "string"]
categories: ["Go", "Links", "GIN", "byte", "string"]
---

- [學會 gin 參數校驗之 validator 函式庫，看這一篇就夠了](https://juejin.cn/post/6863765115456454664)

### 字串約束

excludesall：不包含參數中任意的 UNICODE 字元，例如 excludesall=ab

excludesrune：不包含參數表示的 rune 字元，excludesrune=asong

startswith：以參數子字串為前綴，例如 startswith=hi

endswith：以參數子字串為後綴，例如 endswith=bye。

contains=：包含參數子字串，例如 contains=email

containsany：包含參數中任意的 UNICODE 字元，例如 containsany=ab

containsrune：包含參數表示的 rune 字元，例如 `containsrune=asong`

excludes：不包含參數子字串，例如 excludes=email

### 範圍約束

範圍約束的欄位型別分為三種：

對於數值，我們可以約束其值
對於切片、陣列和 map，我們可以約束其長度
對於字串，我們可以約束其長度

#### 常用 tag 介紹：

ne：不等於參數值，例如 ne=5
gt：大於參數值，例如 gt=5
gte：大於等於參數值，例如 gte=50
lt：小於參數值，例如 lt=50
lte：小於等於參數值，例如 lte=50
oneof：只能是列舉出的值其中之一，這些值必須是數值或字串，以空格分隔；如果字串中有空格，請用單引號包起來，例如 oneof=male female。
eq：等於參數值，注意與 len 不同。對於字串，eq 約束字串本身的值，而 len 約束字串長度。例如 eq=10
len：等於參數值，例如 len=10
max：小於等於參數值，例如 max=10
min：大於等於參數值，例如 min=10

### 欄位約束

eqfield：定義欄位間相等約束，用於約束同一結構體中的欄位。例如：eqfield=Password
eqcsfield：約束同一結構體中欄位等於另一個欄位（相對），確認密碼時可以使用，例如：eqcsfield=ConfirmPassword
nefield：用來約束兩個欄位是否不同，確認兩種顏色是否一致時可以使用，例如：nefield=Color1
necsfield：約束兩個欄位是否不同（相對）

### 常用約束

unique：指定唯一性約束，不同型別處理不同：

對於 map，unique 約束沒有重複的值
對於陣列和切片，unique 沒有重複的值
對於元素型別為結構體的切片，unique 約束結構體物件的某個欄位不重複，使用 unique=field 指定欄位名

email：使用 email 來限制欄位必須是郵件形式，直接寫 email 即可，無需加任何指定。

omitempty：欄位未設定，則忽略

-：跳過該欄位，不檢驗

|：使用多個約束，只需要滿足其中一個，例如 rgb|rgba

required：欄位必須設定，不能為預設值

```go
type Info struct {
	CreateTime time.Time `form:"create_time" binding:"required,timing" time_format:"2006-01-02"`
	UpdateTime time.Time `form:"update_time" binding:"required,timing" time_format:"2006-01-02"`
}
```

## [沒有什麼不可能：修改 Go 結構體的私有欄位](https://colobu.com/2024/08/08/access-the-unexported-fields/)

### 在我們的 main 函式中，你不能存取 Person 的 age 欄位：

```go
package main;
import (
    "fmt"
    "reflect"
    "unsafe"
    "github.com/smallnest/private/model"
)
func main() {
    p := model.NewPerson("Alice", 30)
    fmt.Printf("Person: %+v\n", p)
    // fmt.Println(p.age) // error: p.age undefined (cannot refer to unexported field or method age)
    t := model.NewTeacher("smallnest", 18)
    fmt.Printf("Teacher: %+v\n", t) // Teacher: {Name:Alice Age:30}
}
```

那麼真的就無法存取了嗎？也不一定，我們可以透過反射的方式存取私有欄位：

```go
p := model.NewPerson("Alice", 30)
age := reflect.ValueOf(p).FieldByName("age")
fmt.Printf("原始值: %d, CanSet: %v\n", age.Int(), age.CanSet()) // 30, false
```

執行這個程式，可以看到我們獲得了私有欄位 age 的值：

```shell
原始值: 30, CanSet: false
```

### 這裡我們以標準函式庫的 sync.Mutex 結構體為例，sync.Mutex 包含兩個欄位，這兩個欄位都是私有的：

```go
type Mutex struct {
    state int32
    sema  uint32
}
```

正常情況下你只能透過 Mutex.Lock 和 Mutex.Unlock 來間接修改這兩個欄位。

現在我們示範透過 hack 的方式修改 Mutex 的 state 欄位值：

```go
func setPrivateField() {
	var mu sync.Mutex
	mu.Lock()
	field := reflect.ValueOf(&mu).Elem().FieldByName("state")
	state := field.Interface().(*int32)
	fmt.Println(*state) // ❶
	flagField := reflect.ValueOf(&field).Elem().FieldByName("flag")
	flagPtr := (*uintptr)(unsafe.Pointer(flagField.UnsafeAddr()))
	// 修改 flag 欄位的值
	*flagPtr &= ^uintptr(flagRO) // ❷
	field.Set(reflect.ValueOf(int32(0)))
	mu.Lock() // ❸
	fmt.Println(*state)
}
type flag uintptr
const (
	flagKindWidth        = 5 // there are 27 kinds
	flagKindMask    flag = 1<<flagKindWidth - 1
	flagStickyRO    flag = 1 << 5
	flagEmbedRO     flag = 1 << 6
	flagIndir       flag = 1 << 7
	flagAddr        flag = 1 << 8
	flagMethod      flag = 1 << 9
	flagMethodShift      = 10
	flagRO          flag = flagStickyRO | flagEmbedRO
)
```

❶ 處我們已經介紹過了，存取私有欄位的值，這裡會印出 1
❷ 處我們清除了 flag 欄位的 flagRO 標誌位，這樣就不會報 reflect: reflect.Value.SetInt using value obtained using unexported field 錯誤了
❸ 處不會導致二次加鎖帶來的死鎖，因為 state 欄位的值已經被修改為 0 了，所以不會阻塞。最後印出的結果還是 1

這樣我們就可以實作修改私有欄位的值了。

### 使用 unexported 欄位的 Value 設定公開欄位

看 reflect.Value.Set 的原始碼，我們可以看到它會檢查參數的值是否為 unexported，如果是就會報錯，下面是一個例子：

```go
func setUnexportedField2() {
	alice := model.NewPerson("Alice", 30)
	bob := model.NewTeacher("Bob", 40)
	bobAgent := reflect.ValueOf(&bob).Elem().FieldByName("Age")
	aliceAge := reflect.ValueOf(&alice).Elem().FieldByName("age")
	bobAgent.Set(aliceAge) // ❹
}
```

注意 ❹ 處，我們嘗試把 alice 的私有欄位 age 的值賦值給 bob 的公開欄位 Age，這裡會報錯：

```shell
panic: reflect: reflect.Value.Set using value obtained using unexported field
goroutine 1 [running]:
reflect.flag.mustBeExportedSlow(0x1400012a000?)
	/usr/local/go/src/reflect/value.go:250 +0x70
reflect.flag.mustBeExported(...)
	/usr/local/go/src/reflect/value.go:241
reflect.Value.Set({0x102773a60?, 0x1400012a028?, 0x60?}, {0x102773a60?, 0x1400012a010?, 0x1027002b8?})
	/usr/local/go/src/reflect/value.go:2320 +0x88
main.setUnexportedField2()
	/Users/smallnest/workspace/study/private/main.go:50 +0x168
main.main()
	/Users/smallnest/workspace/study/private/main.go:18 +0x1c
exit status 2
```

原因是 alice 的 age 值被識別為私有欄位，不能用來賦值給公開欄位。

有了上一節的經驗，我們同樣可以繞過這個檢查，實現這個賦值：

```go
func setUnexportedField2() {
	alice := model.NewPerson("Alice", 30)
	bob := model.NewTeacher("Bob", 40)
	bobAgent := reflect.ValueOf(&bob).Elem().FieldByName("Age")
	aliceAge := reflect.ValueOf(&alice).Elem().FieldByName("age")
	// 修改 flag 欄位的值
	flagField := reflect.ValueOf(&aliceAge).Elem().FieldByName("flag")
	flagPtr := (*uintptr)(unsafe.Pointer(flagField.UnsafeAddr()))
	*flagPtr &= ^uintptr(flagRO) // ❺
	bobAgent.Set(reflect.ValueOf(50))
	bobAgent.Set(aliceAge) // ❻
}
```

❺ 處我們修改了 aliceAge 的 flag 欄位，去掉了 flagRO 標誌位，這樣就不會報錯了，❻ 處我們成功把 alice 的私有欄位 age 值賦給 bob 的公開欄位 Age。

這樣我們就可以使用私有欄位的值給其他 Value 賦值。

### 給 unaddressable 的值設定值

回到最初的問題，若嘗試給一個 unaddressable 的值設定值，會報錯。

結合上面的 hack 手段，我們也可以繞過限制，給 unaddressable 的值設定值：

```go
func setUnaddressableValue() {
	var x = 47
	v := reflect.ValueOf(x)
	fmt.Printf("原始值: %d, CanSet: %v\n", v.Int(), v.CanSet()) // 47, false
	// v.Set(reflect.ValueOf(50))
	flagField := reflect.ValueOf(&v).Elem().FieldByName("flag")
	flagPtr := (*uintptr)(unsafe.Pointer(flagField.UnsafeAddr()))
	// 修改 flag 欄位的值
	*flagPtr |= uintptr(flagAddr)          // 設定可尋址標誌位
	fmt.Printf("CanSet: %v\n", v.CanSet()) // true
	v.SetInt(50)
	fmt.Printf("修改後的值：%d\n", v.Int()) // 50
}
```

## [四種字串與 bytes 互相轉換方式的效能比較](https://colobu.com/2024/08/13/string-bytes-benchmark/)

### 三、新型 unsafe 方式

```go
func toBytes(s string) []byte {
	if len(s) == 0 {
		return nil
	}
	return unsafe.Slice(unsafe.StringData(s), len(s))
}
func toString(b []byte) string {
	if len(b) == 0 {
		return ""
	}
	return unsafe.String(unsafe.SliceData(b), len(b))
}
```

### 四、kubernetes 的實作

```go
func toK8sBytes(s string) []byte {
	return *(*[]byte)(unsafe.Pointer(&s))
}
func toK8sString(b []byte) string {
	return *(*string)(unsafe.Pointer(&b))
}
```

#### 在 Mac mini M2 上執行，go1.22.6 darwin/arm64，結果如下：

```shell
goos: darwin
goarch: arm64
pkg: github.com/smallnest/study/str2bytes
BenchmarkStringToBytes/強制轉換-8               78813638        14.73 ns/op      16 B/op       1 allocs/op
BenchmarkStringToBytes/傳統轉換-8               599346962        2.010 ns/op       0 B/op       0 allocs/op
BenchmarkStringToBytes/新型轉換-8               624976126        1.929 ns/op       0 B/op       0 allocs/op
BenchmarkStringToBytes/k8s轉換-8              887370499        1.211 ns/op       0 B/op       0 allocs/op

BenchmarkBytesToString/強制轉換-8               92011309        12.68 ns/op      16 B/op       1 allocs/op
BenchmarkBytesToString/傳統轉換-8               815922964        1.471 ns/op       0 B/op       0 allocs/op
BenchmarkBytesToString/新型轉換-8               624965414        1.922 ns/op       0 B/op       0 allocs/op
BenchmarkBytesToString/k8s轉換-8              1000000000        1.194 ns/op       0 B/op       0 allocs/op

```

string 轉 bytes 效能最好的是 k8s 方案，新型轉換和傳統轉換效能差不多，新型方案略好，強制轉換效能最差。

而 bytes 轉 string，k8s 方案效能最好，傳統轉換次之，新型轉換再次之，強制轉換效能非常差。

#### 在 Linux amd64 上執行，go1.22.0 linux/amd64，結果如下：

```shell
goos: linux
goarch: amd64
pkg: test
cpu: Intel(R) Xeon(R) Platinum
BenchmarkStringToBytes/強制轉換-2                  30606319        42.02 ns/op      16 B/op       1 allocs/op
BenchmarkStringToBytes/傳統轉換-2                  315913948        3.779 ns/op       0 B/op       0 allocs/op
BenchmarkStringToBytes/新型轉換-2                  411972518        2.753 ns/op       0 B/op       0 allocs/op
BenchmarkStringToBytes/k8s轉換-2                 449640819        2.770 ns/op       0 B/op       0 allocs/op
BenchmarkBytesToString/強制轉換-2                  38716465        29.18 ns/op      16 B/op       1 allocs/op
BenchmarkBytesToString/傳統轉換-2                  458832459        2.593 ns/op       0 B/op       0 allocs/op
BenchmarkBytesToString/新型轉換-2                  439537762        2.762 ns/op       0 B/op       0 allocs/op
BenchmarkBytesToString/k8s轉換-2                 478885546        2.375 ns/op       0 B/op       0 allocs/op

```

整體來看，k8s 方案、傳統轉換、新型轉換效能都不錯，強制轉換效能最差。bytes 轉 string 上，k8s 最快。
