---
title: "Take Screenshots with Selenium in Go"
date: 2022-12-02T13:40:19+08:00
menu:
  sidebar:
    name: "Take Screenshots with Selenium in Go"
    identifier: go-benny-selenium
    weight: 10
tags: ["Links", "Go", "Selenium"]
categories: ["Links", "Go", "Selenium"]
hero: images/hero/go.svg
---

- [Take Screenshots with Selenium in Go](https://dmesg.app/go-selenium.html)

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
  // Full-page screenshot
  // Get page width/height, resize the browser window, then take a screenshot.
  // Note: only headless mode allows arbitrary window sizes; otherwise the max height cannot exceed your screen resolution.
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

  // ExecuteScript can run JavaScript. The return value is interface{}, so assert to float then convert to int.
  // height, _ := wd.ExecuteScript("return document.body.parentNode.scrollHeight", nil)
  // var realHeight = int(height.(float64))
  // Then set the window size.
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

##### Full-page screenshot

Get the page width/height, resize the browser window accordingly, and then take the screenshot. Note that only headless mode allows arbitrary window sizes; otherwise the maximum height cannot exceed your display resolution.

##### Run in a container

- Run `apk add chromium-chromedriver` to install the browser and webdriver together

- If running as root, add the `--no-sandbox` flag

- Chrome and container compatibility: Chrome needs a large `/dev/shm`, but `/dev/shm` in containers is usually small
  - Add `--shm-size=256m` in `docker run`
  - Or share the host: `docker run --rm -v /dev/shm:/dev/shm -it alpine sh`
  - Or disable Chrome shm with `--disable-dev-shm-usage`

##### 中文乱码

alpine 里没带中文字体，所以中文会乱码。可以用 alpine 自带的一个，这样安装就好，也可以自己偷字体，然后放到`/usr/share/fonts/`就好了

`apk add wqy-zenhei --update-cache --repository https://nl.alpinelinux.org/alpine/edge/testing`
