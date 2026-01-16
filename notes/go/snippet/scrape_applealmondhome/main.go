package main

import (
	"fmt"
	"log"
	"net/http"
	"strings"
	"time"

	"github.com/PuerkitoBio/goquery"
)

func main() {
	url := "https://applealmondhome.com/page/2"
	layout := "2006-01-02T15:04:05Z07:00"
	rawData := make([]string, 0)

	resp, err := http.Get(url)

	if err != nil {
		log.Fatal(err)
	}

	defer resp.Body.Close()

	if resp.StatusCode != 200 {
		log.Fatalf("failed to fetch data: %d %s", resp.StatusCode, resp.Status)
	}

	doc, err := goquery.NewDocumentFromReader(resp.Body)

	if err != nil {
		log.Fatal(err)
	}

	f1 := func(_ int, s *goquery.Selection) bool {
		link, _ := s.Attr("href")
		return strings.HasPrefix(link, "https://applealmondhome.com/posts")
	}

	doc.Find("h2 a").FilterFunction(f1).Each(func(_ int, tag *goquery.Selection) {
		link, _ := tag.Attr("href")
		rawData = append(rawData, fmt.Sprintf("[%s](%s)", tag.Text(), link))
	})
	// fmt.Println(rawData)

	f2 := func(_ int, s *goquery.Selection) bool {
		date, _ := s.Attr("datetime")
		_, err := time.Parse(layout, date)
		return err == nil
	}
	doc.Find("div span a time").FilterFunction(f2).Each(func(x int, s *goquery.Selection) {
		v, _ := s.Attr("datetime")
		d, _ := time.Parse(layout, v)
		if d.Day() == time.Now().Local().Day() {
			fmt.Println(rawData[x])
		}
	})
}
