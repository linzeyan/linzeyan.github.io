package main

import (
	"context"
	"encoding/csv"
	"fmt"
	"io"
	"log"
	"os"
	"path/filepath"
	"strconv"
	"time"

	"github.com/gocarina/gocsv"
	"github.com/linzeyan/utils"
	"github.com/schollz/progressbar/v3"
	"googlemaps.github.io/maps"
)

const (
	api      = "XXXXXXXXXXXXXXXXXXXXXXX"
	file     = "cpt_app_lng_lat.csv"
	language = "zh-TW"
	radius   = 300
)

/* Configure Output structure. */
type Output struct {
	Lng              float64
	Lat              float64
	Radius           uint
	Results          []maps.PlacesSearchResult
	HTMLAttributions []string
}

/* Configure CSV structure. */
type CSVFile struct {
	Order string `csv:"ext_orderNo"`
	Event string `csv:"event_time"`
	Lng   string `csv:"lng"`
	Lat   string `csv:"lat"`
}

func main() {
	source := readCSV(file)
	do(api, source)
}

func toFloat64(s string) float64 {
	result, err := strconv.ParseFloat(s, 64)
	if err != nil {
		log.Println("toFloat64", err)
	}
	return result
}

func readCSV(file string) []CSVFile {
	/* Unmarshal CSV. */
	var slice []CSVFile
	gocsv.SetCSVReader(func(in io.Reader) gocsv.CSVReader {
		r := csv.NewReader(in)
		r.Comma = ','
		return r
	})
	f, err := os.Open(file)
	if err != nil {
		log.Fatal(err)
	}
	defer f.Close()
	if err = gocsv.UnmarshalFile(f, &slice); err != nil {
		log.Fatal(err)
	}
	return slice
}

func saveResult(data []*Output) {
	/* Marshal JSON data. */
	out, err := utils.JSONMarshal(data)
	if err != nil {
		log.Fatal(err)
	}
	/* Write JSON data to the file. */
	savePath := fmt.Sprintf("cpt_geo_%s.json", time.Now().Local().Format("20060102"))
	err = os.WriteFile(savePath, out, 0644)
	if err != nil {
		log.Fatal(err)
	}
}

// func saveOut(data []*Output, order string) {
func saveOut(data *Output, order string) {
	/* Save every result as a file. */
	const tempDir = "download_all"
	err := os.MkdirAll(tempDir, os.ModePerm)
	if err != nil {
		log.Println(err, data)
		return
	}
	out, err := utils.JSONMarshal(data)
	if err != nil {
		log.Println(err, data)
		return
	}
	savePath := filepath.Join(tempDir, fmt.Sprintf("%s_%f_%f_%d.json", order, data.Lng, data.Lat, radius))
	err = os.WriteFile(savePath, out, 0644)
	if err != nil {
		log.Println(err, data)
	}
}

func do(api string, data []CSVFile) {
	/* Create file to save error data. */
	errFile, err := os.OpenFile("errFile.csv", os.O_APPEND|os.O_WRONLY|os.O_CREATE, os.ModePerm)
	if err != nil {
		log.Fatal(err)
	}
	defer errFile.Close()
	/* Create progress bar. */
	bar := progressbar.Default(int64((len(data))), "Fetch data")
	/* Use Google Maps API. */
	client, err := maps.NewClient(maps.WithAPIKey(api), maps.WithRateLimit(0))
	if err != nil {
		log.Fatal(err)
	}
	ctx := context.Background()
	var result []*Output
	for i := range data {
		time.Sleep(2 * time.Second)
		// result = append(result, Output{Lng: data[i].Lng, Lat: data[i].Lat})
		out, err := nearbysearch(toFloat64(data[i].Lng), toFloat64(data[i].Lat), client, ctx)
		_ = bar.Add(1)
		if err != nil {
			log.Println("err:", err)
			_, werr := errFile.WriteString(fmt.Sprintf("%d,%s,%s,%s,%s\n", i, data[i].Order, data[i].Event, data[i].Lng, data[i].Lat))
			if werr != nil {
				log.Println("werr:", werr, data[i].Order, data[i].Lng, data[i].Lat)
			}
			continue
		}
		result = append(result, out)
		/* could replace out with result. */
		saveOut(out, data[i].Order)
	}
	saveResult(result)
}

func nearbysearch(lng, lat float64, g *maps.Client, ctx context.Context) (*Output, error) {
	/* Create request. */
	r := &maps.NearbySearchRequest{
		Language: language,
		Location: &maps.LatLng{
			Lng: lng,
			Lat: lat,
		},
		Radius:    radius,
		PageToken: "",
	}
	/* Do request. */
	result, err := g.NearbySearch(ctx, r)
	if err != nil {
		return nil, err
	}
	/* Temporarily save data. */
	out := &Output{
		Lng:              lng,
		Lat:              lat,
		Radius:           radius,
		Results:          result.Results,
		HTMLAttributions: result.HTMLAttributions,
	}
	/* Get next page data. */
	temp := result.NextPageToken
	for temp != "" {
		time.Sleep(2 * time.Second)
		rr := &maps.NearbySearchRequest{
			Language: language,
			Location: &maps.LatLng{
				Lng: lng,
				Lat: lat,
			},
			Radius:    radius,
			PageToken: temp,
		}
		newResult, err := g.NearbySearch(ctx, rr)
		if err != nil {
			return nil, err
		}
		out.Results = append(out.Results, newResult.Results...)
		out.HTMLAttributions = append(out.HTMLAttributions, newResult.HTMLAttributions...)
		if rr.PageToken == newResult.NextPageToken || newResult.NextPageToken == "" {
			time.Sleep(2 * time.Second)
			break
		}
		temp = newResult.NextPageToken
	}
	return out, nil
}
