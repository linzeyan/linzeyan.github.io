---
title: "Go articles"
date: 2024-08-20T08:55:00+08:00
menu:
  sidebar:
    name: Go articles
    identifier: golang-articles-202408200855
    weight: 10
tags: ["golang", "URL", "GIN", "byte", "string"]
categories: ["golang", "URL", "GIN", "byte", "string"]
---

# Go articles

## [学会 gin 参数校验之 validator 库，看这一篇就足够了](https://juejin.cn/post/6863765115456454664)

### 字符串约束

excludesall：不包含参数中任意的 UNICODE 字符，例如 excludesall=ab

excludesrune：不包含参数表示的 rune 字符，excludesrune=asong

startswith：以参数子串为前缀，例如 startswith=hi

endswith：以参数子串为后缀，例如 endswith=bye。

contains=：包含参数子串，例如 contains=email

containsany：包含参数中任意的 UNICODE 字符，例如 containsany=ab

containsrune：包含参数表示的 rune 字符，例如`containsrune=asong

excludes：不包含参数子串，例如 excludes=email

### 范围约束

范围约束的字段类型分为三种：

对于数值，我们则可以约束其值
对于切片、数组和 map，我们则可以约束其长度
对于字符串，我们则可以约束其长度

#### 常用 tag 介绍：

ne：不等于参数值，例如 ne=5
gt：大于参数值，例如 gt=5
gte：大于等于参数值，例如 gte=50
lt：小于参数值，例如 lt=50
lte：小于等于参数值，例如 lte=50
oneof：只能是列举出的值其中一个，这些值必须是数值或字符串，以空格分隔，如果字符串中有空格，将字符串用单引号包围，例如 oneof=male female。
eq：等于参数值，注意与 len 不同。对于字符串，eq 约束字符串本身的值，而 len 约束字符串长度。例如 eq=10
len：等于参数值，例如 len=10
max：小于等于参数值，例如 max=10
min：大于等于参数值，例如 min=10

### Fields 约束

eqfield：定义字段间的相等约束，用于约束同一结构体中的字段。例如：eqfield=Password
eqcsfield：约束统一结构体中字段等于另一个字段（相对），确认密码时可以使用，例如：eqfiel=ConfirmPassword
nefield：用来约束两个字段是否相同，确认两种颜色是否一致时可以使用，例如：nefield=Color1
necsfield：约束两个字段是否相同（相对）

### 常用约束

unique：指定唯一性约束，不同类型处理不同：

对于 map，unique 约束没有重复的值
对于数组和切片，unique 没有重复的值
对于元素类型为结构体的碎片，unique 约束结构体对象的某个字段不重复，使用 unique=field 指定字段名

email：使用 email 来限制字段必须是邮件形式，直接写 eamil 即可，无需加任何指定。

omitempty：字段未设置，则忽略

-：跳过该字段，不检验

|：使用多个约束，只需要满足其中一个，例如 rgb|rgba

required：字段必须设置，不能为默认值

```go
type Info struct {
	CreateTime time.Time `form:"create_time" binding:"required,timing" time_format:"2006-01-02"`
	UpdateTime time.Time `form:"update_time" binding:"required,timing" time_format:"2006-01-02"`
}
```

## [没有什么不可能：修改 Go 结构体的私有字段](https://colobu.com/2024/08/08/access-the-unexported-fields/)

### 在我们的 main 函数中，你不能访问 Person 的 age 字段：

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

那么真的就无法访问了吗？也不一定，我们可以通过反射的方式访问私有字段：

```go
p := model.NewPerson("Alice", 30)
age := reflect.ValueOf(p).FieldByName("age")
fmt.Printf("原始值: %d, CanSet: %v\n", age.Int(), age.CanSet()) // 30, false
```

运行这个程序，可以看到我们获得了这个私有字段 age 的值：

```shell
原始值: 30, CanSet: false
```

### 这里我们以标准库的 sync.Mutex 结构体为例，sync.Mutex 包含两个字段，这两个字段都是私有的：

```go
type Mutex struct {
    state int32
    sema  uint32
}
```

正常情况下你只能通过 Mutex.Lock 和 Mutex.Unlock 来间接的修改这两个字段。

现在我们演示通过 hack 的方式修改 Mutex 的 state 字段的值：

```go
func setPrivateField() {
	var mu sync.Mutex
	mu.Lock()
	field := reflect.ValueOf(&mu).Elem().FieldByName("state")
	state := field.Interface().(*int32)
	fmt.Println(*state) // ❶
	flagField := reflect.ValueOf(&field).Elem().FieldByName("flag")
	flagPtr := (*uintptr)(unsafe.Pointer(flagField.UnsafeAddr()))
	// 修改 flag 字段的值
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

❶ 处我们已经介绍过了，访问私有字段的值，这里会打印出 1
❶ 处我们清除了 flag 字段的 flagRO 标志位，这样就不会报 reflect: reflect.Value.SetInt using value obtained using unexported field 错误了
❸ 处不会导致二次加锁带来的死锁，因为 state 字段的值已经被修改为 0 了，所以不会阻塞。最后打印结果还是 1

这样我们就可以实现了修改私有字段的值了。

### 使用 unexported 字段的 Value 设置公开字段

看 reflect.Value.Set 的源码，我们可以看到它会检查参数的值是否 unexported，如果是，就会报错，下面就是一个例子：

```go
func setUnexportedField2() {
	alice := model.NewPerson("Alice", 30)
	bob := model.NewTeacher("Bob", 40)
	bobAgent := reflect.ValueOf(&bob).Elem().FieldByName("Age")
	aliceAge := reflect.ValueOf(&alice).Elem().FieldByName("age")
	bobAgent.Set(aliceAge) // ❹
}
```

注意 ❹ 处，我们尝试把 alice 的私有字段 age 的值赋值给 bob 的公开字段 Age，这里会报错：

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

原因 alice 的 age 值被识别为私有字段，它是不能用来赋值给公开字段的。

有了上一节的经验，我们同样可以绕过这个检查，实现这个赋值：

```go
func setUnexportedField2() {
	alice := model.NewPerson("Alice", 30)
	bob := model.NewTeacher("Bob", 40)
	bobAgent := reflect.ValueOf(&bob).Elem().FieldByName("Age")
	aliceAge := reflect.ValueOf(&alice).Elem().FieldByName("age")
	// 修改 flag 字段的值
	flagField := reflect.ValueOf(&aliceAge).Elem().FieldByName("flag")
	flagPtr := (*uintptr)(unsafe.Pointer(flagField.UnsafeAddr()))
	*flagPtr &= ^uintptr(flagRO) // ❺
	bobAgent.Set(reflect.ValueOf(50))
	bobAgent.Set(aliceAge) // ❻
}
```

❺ 处我们修改了 aliceAge 的 flag 字段，去掉了 flagRO 标志位，这样就不会报错了，❻ 处我们成功的把 alice 的私有字段 age 的值赋值给 bob 的公开字段 Age。

这样我们就可以实现了使用私有字段的值给其他 Value 值进行赋值了。

### 给 unaddressable 的值设置值

回到最初的问题，我们尝试给一个 unaddressable 的值设置值，会报错。

结合上面的 hack 手段，我们也可以绕过限制，给 unaddressable 的值设置值：

```go
func setUnaddressableValue() {
	var x = 47
	v := reflect.ValueOf(x)
	fmt.Printf("原始值: %d, CanSet: %v\n", v.Int(), v.CanSet()) // 47, false
	// v.Set(reflect.ValueOf(50))
	flagField := reflect.ValueOf(&v).Elem().FieldByName("flag")
	flagPtr := (*uintptr)(unsafe.Pointer(flagField.UnsafeAddr()))
	// 修改 flag 字段的值
	*flagPtr |= uintptr(flagAddr)          // 设置可寻址标志位
	fmt.Printf("CanSet: %v\n", v.CanSet()) // true
	v.SetInt(50)
	fmt.Printf("修改后的值：%d\n", v.Int()) // 50
}
```

## [四种字符串和 bytes 互相转换方式的性能比较](https://colobu.com/2024/08/13/string-bytes-benchmark/)

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

### 四、kubernetes 的实现

```go
func toK8sBytes(s string) []byte {
	return *(*[]byte)(unsafe.Pointer(&s))
}
func toK8sString(b []byte) string {
	return *(*string)(unsafe.Pointer(&b))
}
```

#### 在 Mac mini M2 上运行，go1.22.6 darwin/arm64，结果如下：

```shell
goos: darwin
goarch: arm64
pkg: github.com/smallnest/study/str2bytes
BenchmarkStringToBytes/强制转换-8              	78813638	        14.73 ns/op	      16 B/op	       1 allocs/op
BenchmarkStringToBytes/传统转换-8              	599346962	         2.010 ns/op	       0 B/op	       0 allocs/op
BenchmarkStringToBytes/新型转换-8              	624976126	         1.929 ns/op	       0 B/op	       0 allocs/op
BenchmarkStringToBytes/k8s转换-8             	887370499	         1.211 ns/op	       0 B/op	       0 allocs/op

BenchmarkBytesToString/强制转换-8              	92011309	        12.68 ns/op	      16 B/op	       1 allocs/op
BenchmarkBytesToString/传统转换-8              	815922964	         1.471 ns/op	       0 B/op	       0 allocs/op
BenchmarkBytesToString/新型转换-8              	624965414	         1.922 ns/op	       0 B/op	       0 allocs/op
BenchmarkBytesToString/k8s转换-8             	1000000000	         1.194 ns/op	       0 B/op	       0 allocs/op

```

string 转 bytes 性能最好的是 k8s 方案，新型转换和传统转换性能差不多，新型方案略好，强制转换性能最差。

而对于 bytes 转 string，k8s 方案性能最好，传统转换次之，新型转换性能再次之，强制转换性能非常不好。

#### 在 Linux amd64 上运行，go1.22.0 linux/amd64，结果如下：

```shell
goos: linux
goarch: amd64
pkg: test
cpu: Intel(R) Xeon(R) Platinum
BenchmarkStringToBytes/强制转换-2                 	30606319	        42.02 ns/op	      16 B/op	       1 allocs/op
BenchmarkStringToBytes/传统转换-2                 	315913948	         3.779 ns/op	       0 B/op	       0 allocs/op
BenchmarkStringToBytes/新型转换-2                 	411972518	         2.753 ns/op	       0 B/op	       0 allocs/op
BenchmarkStringToBytes/k8s转换-2                	449640819	         2.770 ns/op	       0 B/op	       0 allocs/op
BenchmarkBytesToString/强制转换-2                 	38716465	        29.18 ns/op	      16 B/op	       1 allocs/op
BenchmarkBytesToString/传统转换-2                 	458832459	         2.593 ns/op	       0 B/op	       0 allocs/op
BenchmarkBytesToString/新型转换-2                 	439537762	         2.762 ns/op	       0 B/op	       0 allocs/op
BenchmarkBytesToString/k8s转换-2                	478885546	         2.375 ns/op	       0 B/op	       0 allocs/op

```

整体上看，k8s 方案、传统转换、新型转换性能都挺好，强制转换性能最差。k8s 在 bytes 转 string 上性能最好。
