---
title: "Go Articles"
date: 2024-08-20T08:55:00+08:00
menu:
  sidebar:
    name: Go Articles
    identifier: golang-articles-202408200855
    weight: 10
tags: ["Go", "Links", "GIN", "byte", "string"]
categories: ["Go", "Links", "GIN", "byte", "string"]
---

- [Learn gin Parameter Validation with the validator Library - This One Article Is Enough](https://juejin.cn/post/6863765115456454664)

### String Constraints

excludesall: does not contain any of the UNICODE characters in the parameter, e.g. excludesall=ab

excludesrune: does not contain the rune specified by the parameter, e.g. excludesrune=asong

startswith: starts with the parameter substring, e.g. startswith=hi

endswith: ends with the parameter substring, e.g. endswith=bye

contains: contains the parameter substring, e.g. contains=email

containsany: contains any of the UNICODE characters in the parameter, e.g. containsany=ab

containsrune: contains the rune specified by the parameter, e.g. containsrune=asong

excludes: does not contain the parameter substring, e.g. excludes=email

### Range Constraints

Field types with range constraints fall into three categories:

For numeric values, you can constrain the value.
For slices, arrays, and maps, you can constrain the length.
For strings, you can constrain the length.

#### Common tag descriptions:

ne: not equal to the parameter value, e.g. ne=5
gt: greater than the parameter value, e.g. gt=5
gte: greater than or equal to the parameter value, e.g. gte=50
lt: less than the parameter value, e.g. lt=50
lte: less than or equal to the parameter value, e.g. lte=50
oneof: must be one of the listed values, which must be numbers or strings separated by spaces; if a string contains spaces, wrap it in single quotes, e.g. oneof=male female
eq: equals the parameter value. Note that this differs from len. For strings, eq constrains the string value itself, while len constrains the string length. Example: eq=10
len: equals the parameter value, e.g. len=10
max: less than or equal to the parameter value, e.g. max=10
min: greater than or equal to the parameter value, e.g. min=10

### Field Constraints

eqfield: enforce equality between fields, for constraints on fields within the same struct. Example: eqfield=Password
eqcsfield: enforce that a field equals another field in the same struct (relative). Useful for confirmation fields, e.g. eqcsfield=ConfirmPassword
nefield: enforce that two fields are not equal, e.g. checking two colors are different, e.g. nefield=Color1
necsfield: enforce that two fields are not equal (relative)

### Common Constraints

unique: enforce uniqueness; behavior differs by type:

For maps, unique enforces no duplicate values.
For arrays and slices, unique enforces no duplicate values.
For elements of struct type, unique enforces that a field of the struct is unique; use unique=field to specify the field name.

email: use email to require a valid email format; just write email, no parameters needed.

omitempty: if the field is not set, ignore it.

-: skip the field and do not validate it.

|: use multiple constraints; only one needs to be satisfied, e.g. rgb|rgba

required: the field must be set and cannot be the default value.

```go
type Info struct {
	CreateTime time.Time `form:"create_time" binding:"required,timing" time_format:"2006-01-02"`
	UpdateTime time.Time `form:"update_time" binding:"required,timing" time_format:"2006-01-02"`
}
```

## [Nothing Is Impossible: Modifying Private Fields in a Go Struct](https://colobu.com/2024/08/08/access-the-unexported-fields/)

### In our main function, you cannot access the age field of Person:

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

So does that mean it's impossible? Not necessarily. You can access private fields via reflection:

```go
p := model.NewPerson("Alice", 30)
age := reflect.ValueOf(p).FieldByName("age")
fmt.Printf("Original value: %d, CanSet: %v\n", age.Int(), age.CanSet()) // 30, false
```

Running this program shows the value of the private field age:

```shell
Original value: 30, CanSet: false
```

### Take the standard library's sync.Mutex as an example. It has two private fields:

```go
type Mutex struct {
    state int32
    sema  uint32
}
```

Normally, you can only modify these fields indirectly via Mutex.Lock and Mutex.Unlock.

Now let's demonstrate a hacky way to modify Mutex.state:

```go
func setPrivateField() {
	var mu sync.Mutex
	mu.Lock()
	field := reflect.ValueOf(&mu).Elem().FieldByName("state")
	state := field.Interface().(*int32)
	fmt.Println(*state) // ❶
	flagField := reflect.ValueOf(&field).Elem().FieldByName("flag")
	flagPtr := (*uintptr)(unsafe.Pointer(flagField.UnsafeAddr()))
	// Modify the flag field value
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

At ❶, we've already shown how to read a private field; it prints 1 here.
At ❷, we clear the flagRO bit of the flag field, so it won't hit the error "reflect: reflect.Value.SetInt using value obtained using unexported field".
At ❸, it won't deadlock from double-locking because the state field has been changed to 0. The final output is still 1.

This lets us modify the value of a private field.

### Using a Value from an unexported field to set a public field

Looking at reflect.Value.Set, it checks whether the input value is unexported; if it is, it throws an error. Here's an example:

```go
func setUnexportedField2() {
	alice := model.NewPerson("Alice", 30)
	bob := model.NewTeacher("Bob", 40)
	bobAgent := reflect.ValueOf(&bob).Elem().FieldByName("Age")
	aliceAge := reflect.ValueOf(&alice).Elem().FieldByName("age")
	bobAgent.Set(aliceAge) // ❹
}
```

At ❹, we try to assign alice's private field age to bob's public field Age, which raises an error:

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

The reason is that alice's age value is treated as an unexported field, so it cannot be used to set a public field.

Based on the previous trick, we can bypass the check and perform the assignment:

```go
func setUnexportedField2() {
	alice := model.NewPerson("Alice", 30)
	bob := model.NewTeacher("Bob", 40)
	bobAgent := reflect.ValueOf(&bob).Elem().FieldByName("Age")
	aliceAge := reflect.ValueOf(&alice).Elem().FieldByName("age")
	// Modify the flag field value
	flagField := reflect.ValueOf(&aliceAge).Elem().FieldByName("flag")
	flagPtr := (*uintptr)(unsafe.Pointer(flagField.UnsafeAddr()))
	*flagPtr &= ^uintptr(flagRO) // ❺
	bobAgent.Set(reflect.ValueOf(50))
	bobAgent.Set(aliceAge) // ❻
}
```

At ❺, we modify the flag field on aliceAge and clear the flagRO bit, so it won't error. At ❻, we successfully assign alice's private age value to bob's public Age.

This lets you assign values from unexported fields into other Value instances.

### Setting a value on an unaddressable Value

Back to the original issue: if you try to set a value on an unaddressable Value, it will error.

Using the same hack, we can bypass the limitation and set a value on an unaddressable Value:

```go
func setUnaddressableValue() {
	var x = 47
	v := reflect.ValueOf(x)
	fmt.Printf("Original value: %d, CanSet: %v\n", v.Int(), v.CanSet()) // 47, false
	// v.Set(reflect.ValueOf(50))
	flagField := reflect.ValueOf(&v).Elem().FieldByName("flag")
	flagPtr := (*uintptr)(unsafe.Pointer(flagField.UnsafeAddr()))
	// Modify the flag field value
	*flagPtr |= uintptr(flagAddr)          // Set the addressable flag
	fmt.Printf("CanSet: %v\n", v.CanSet()) // true
	v.SetInt(50)
	fmt.Printf("Updated value: %d\n", v.Int()) // 50
}
```

## [Performance Comparison of Four String/Bytes Conversion Methods](https://colobu.com/2024/08/13/string-bytes-benchmark/)

### 3. New unsafe approach

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

### 4. Kubernetes implementation

```go
func toK8sBytes(s string) []byte {
	return *(*[]byte)(unsafe.Pointer(&s))
}
func toK8sString(b []byte) string {
	return *(*string)(unsafe.Pointer(&b))
}
```

#### Run on Mac mini M2 with go1.22.6 darwin/arm64:

```shell
goos: darwin
goarch: arm64
pkg: github.com/smallnest/study/str2bytes
BenchmarkStringToBytes/forced-conversion-8      78813638        14.73 ns/op      16 B/op       1 allocs/op
BenchmarkStringToBytes/traditional-conversion-8 599346962         2.010 ns/op       0 B/op       0 allocs/op
BenchmarkStringToBytes/new-conversion-8         624976126         1.929 ns/op       0 B/op       0 allocs/op
BenchmarkStringToBytes/k8s-conversion-8         887370499         1.211 ns/op       0 B/op       0 allocs/op

BenchmarkBytesToString/forced-conversion-8      92011309        12.68 ns/op      16 B/op       1 allocs/op
BenchmarkBytesToString/traditional-conversion-8 815922964         1.471 ns/op       0 B/op       0 allocs/op
BenchmarkBytesToString/new-conversion-8         624965414         1.922 ns/op       0 B/op       0 allocs/op
BenchmarkBytesToString/k8s-conversion-8         1000000000         1.194 ns/op       0 B/op       0 allocs/op

```

For string to bytes, the k8s approach is fastest. The new approach is roughly the same as the traditional conversion, slightly better; the forced conversion is the worst.

For bytes to string, the k8s approach is fastest, traditional conversion is next, the new approach is slower, and the forced conversion is very poor.

#### Run on Linux amd64 with go1.22.0 linux/amd64:

```shell
goos: linux
goarch: amd64
pkg: test
cpu: Intel(R) Xeon(R) Platinum
BenchmarkStringToBytes/forced-conversion-2         30606319        42.02 ns/op      16 B/op       1 allocs/op
BenchmarkStringToBytes/traditional-conversion-2    315913948         3.779 ns/op       0 B/op       0 allocs/op
BenchmarkStringToBytes/new-conversion-2            411972518         2.753 ns/op       0 B/op       0 allocs/op
BenchmarkStringToBytes/k8s-conversion-2            449640819         2.770 ns/op       0 B/op       0 allocs/op
BenchmarkBytesToString/forced-conversion-2         38716465        29.18 ns/op      16 B/op       1 allocs/op
BenchmarkBytesToString/traditional-conversion-2    458832459         2.593 ns/op       0 B/op       0 allocs/op
BenchmarkBytesToString/new-conversion-2            439537762         2.762 ns/op       0 B/op       0 allocs/op
BenchmarkBytesToString/k8s-conversion-2            478885546         2.375 ns/op       0 B/op       0 allocs/op

```

Overall, the k8s approach, traditional conversion, and new conversion all perform well, while forced conversion performs worst. For bytes to string, k8s is the fastest.
