---
title: "Go 使用 selenium 截图"
date: 2022-12-02T13:40:19+08:00
menu:
  sidebar:
    name: "Go 使用 selenium 截图"
    identifier: go-benny-selenium
    weight: 10
tags: ["URL", "Go", "Selenium"]
categories: ["URL", "Go", "Selenium"]
hero: images/hero/go.svg
---

- [Go 使用 selenium 截图](https://dmesg.app/go-selenium.html)

```go
package main

import (
	"fmt"
	log "github.com/sirupsen/logrus"
	"github.com/tebeka/selenium"
	"io/ioutil"
)

const (
	chromeDriverPath = "/usr/local/bin/chromedriver"
	port = 9515
)

func main() {
	var opts []selenium.ServiceOption
	selenium.SetDebug(false)
	service, err := selenium.NewChromeDriverService(chromeDriverPath, port, opts...)
	if err != nil {
		panic(err) // panic is used only as an example and is not otherwise recommended.
	}
	defer service.Stop()

	caps := selenium.Capabilities{"browserName": "chrome"}
  // 整页截屏
  // 获取到网页的宽高，然后把浏览器的窗口设置成这么大，然后再截图就好了！需要注意的是只有 headless 模式可以任意设置窗口大小，否则最大高度不能超过你的显示器分辨率
	// chromeCaps := chrome.Capabilities{
	// 	Path: "",
	// 	Args: []string{
	// 		"--headless",
	// 	},
	// }
	// caps.AddChrome(chromeCaps)

	wd, err := selenium.NewRemote(caps, fmt.Sprintf("http://localhost:%d/wd/hub", port))
	if err != nil {
		panic(err)
	}
	defer wd.Quit()

  // 在 selenium 中使用ExecuteScript就可以执行 JavaScript 代码，需要注意返回值是 interface，所以要类型断言成 float，然后再转成 int
  // height, _ := wd.ExecuteScript("return document.body.parentNode.scrollHeight", nil)
  // var realHeight = int(height.(float64))
  // 然后我们需要设置窗口大小
  // wd.ResizeWindow("", 1920, realHeight)

	if err := wd.Get("https://github.com/tgbot-collection/archiver"); err != nil {
		panic(err)
	}

	screenshot, err := wd.Screenshot()
	if err != nil {
		log.Errorln(err)

	}
	ioutil.WriteFile("screenshot.png", screenshot, 0644)

}
```

##### 整页截屏

获取到网页的宽高，然后把浏览器的窗口设置成这么大，然后再截图就好了！需要注意的是只有 headless 模式可以任意设置窗口大小，否则最大高度不能超过你的显示器分辨率

##### 在容器中运行

- 直接运行 apk add chromium-chromedriver 浏览器和 webdriver 会一起安装好

- 要注意一件事情，如果你是 root 用户运行的，那么要加上`--no-sandbox` 参数

- Chrome 和 container 的兼容性问题，Chrome 需要比较大的`/dev/shm`，然而容器中的`/dev/shm` 往往都比较小，
  - 通过 run 时额外参数`--shm-size=256m`
  - 也可以直接把宿主机的共享进去`docker run --rm -v /dev/shm:/dev/shm -it alpine sh`
  - 也可以禁用 Chrome 的 shm 功能，加一个参数 `"--disable-dev-shm-usage",`

##### 中文乱码

alpine 里没带中文字体，所以中文会乱码。可以用 alpine 自带的一个，这样安装就好，也可以自己偷字体，然后放到`/usr/share/fonts/`就好了

`apk add wqy-zenhei --update-cache --repository https://nl.alpinelinux.org/alpine/edge/testing`
