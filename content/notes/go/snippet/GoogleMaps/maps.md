# Google Maps

- [Google Maps](#google-maps)
  - [API](#api)
    - [Directions](#directions)
    - [DistanceMatrix](#distancematrix)
    - [Elevation](#elevation)
    - [Geocoding](#geocoding)
    - [Geolocation](#geolocation)
    - [Place](#place)
    - [Roads](#roads)
  - [Type](#type)

## API

### [Directions](https://developers.google.com/maps/documentation/directions/get-directions?hl=zh-tw)
> 取得開車、單車、大眾運輸和步行之間的路線。

- Input
  1. 起點。
  2. 終點。
- Output
  1. 請求方向請求時提供的起點、途經點或目的地的地理編碼點。
  2. 從起點到目的地之間的單條路線。

### [DistanceMatrix](https://developers.google.com/maps/documentation/distance-matrix/distance-matrix?hl=zh-tw)
> 取得出發地和目的地矩陣的移動距離和所需時間。

- Input
  1. 起點。
  2. 終點。
- Output
  1. 路線所需時間。
  2. 考慮交通情況下路線所需時間。
  3. 路線總距離。

### [Elevation](https://developers.google.com/maps/documentation/elevation/requests-elevation?hl=zh-tw)
> 特定地點的海拔高度資料，或沿著路徑取樣的海拔高度資料。

- Input
  - 經緯度座標。
- Output
  1. 經緯度座標。
  2. 海拔高度，單位為米。
  3. 插值該海拔高度的數據點之間的最大距離，單位為米。(如果數據點之間的距離超過了這個最大距離，則插值的海拔高度值可能會不夠準確。)

Output Example:

```json
[
    {
        "location": {
            "lat": 24.72969,
            "lng": 120.87882
        },
        "elevation": 21.09626007080078,
        "resolution": 9.543951988220215
    }
]
```

### [Geocoding](https://developers.google.com/maps/documentation/geocoding/requests-reverse-geocoding?hl=zh-tw)
> 地址或地點 ID 跟經緯度座標互相轉換。

- Input
  - 經緯度座標或是地址或是地點 ID。
- Output
  - 地址、地點 ID、經緯度座標等。

Output Example:

```json
[
    {
        "address_components": [
            {
                "long_name": "12",
                "short_name": "12",
                "types": [
                    "street_number"
                ]
            },
            {
                "long_name": "Nangang Street",
                "short_name": "Nangang St",
                "types": [
                    "route"
                ]
            },
            {
                "long_name": "崎頂里",
                "short_name": "崎頂里",
                "types": [
                    "administrative_area_level_4",
                    "political"
                ]
            },
            {
                "long_name": "Zhunan Township",
                "short_name": "Zhunan Township",
                "types": [
                    "administrative_area_level_3",
                    "political"
                ]
            },
            {
                "long_name": "Miaoli County",
                "short_name": "Miaoli County",
                "types": [
                    "administrative_area_level_2",
                    "political"
                ]
            },
            {
                "long_name": "Taiwan",
                "short_name": "TW",
                "types": [
                    "country",
                    "political"
                ]
            },
            {
                "long_name": "350",
                "short_name": "350",
                "types": [
                    "postal_code"
                ]
            }
        ],
        "formatted_address": "No. 12, Nangang St, Zhunan Township, Miaoli County, Taiwan 350",
        "geometry": {
            "location": {
                "lat": 24.7300368,
                "lng": 120.8787035
            },
            "location_type": "ROOFTOP",
            "bounds": {
                "northeast": {
                    "lat": 24.7300832,
                    "lng": 120.8787412
                },
                "southwest": {
                    "lat": 24.7299924,
                    "lng": 120.8786447
                }
            },
            "viewport": {
                "northeast": {
                    "lat": 24.7313867802915,
                    "lng": 120.8800419302915
                },
                "southwest": {
                    "lat": 24.7286888197085,
                    "lng": 120.8773439697085
                }
            },
            "types": null
        },
        "types": [
            "premise"
        ],
        "place_id": "ChIJeSlIfru0aTQR0LK8Cz0vfDA",
        "partial_match": false,
        "plus_code": {
            "global_code": "",
            "compound_code": ""
        }
    }
]
```

### [Geolocation](https://developers.google.com/maps/documentation/geolocation/requests-geolocation?hl=zh-tw)
> 利用行動通信基地台和 Wi-Fi 節點中的地理空間資料取得沒有原生地理位置或 GPS 的裝置所在位置。

- Output
  1. 經緯度座標。
  2. 位置精度，單位為米。

### [Place](https://developers.google.com/maps/documentation/places/web-service/details?hl=zh-tw#maps_http_places_details_fields-txt)
> 指定地點資訊。

- Input
  - 地點 ID。
- Output
  1. 地點完整資訊，例如完整地址、電話號碼、使用者評分和評論。
  2. 搜尋指定區域內的地點。

Output Example 1.:

```json
{
    "address_components": [
        {
            "long_name": "12",
            "short_name": "12",
            "types": [
                "street_number"
            ]
        },
        {
            "long_name": "Nangang Street",
            "short_name": "Nangang St",
            "types": [
                "route"
            ]
        },
        {
            "long_name": "崎頂里",
            "short_name": "崎頂里",
            "types": [
                "administrative_area_level_4",
                "political"
            ]
        },
        {
            "long_name": "Zhunan Township",
            "short_name": "Zhunan Township",
            "types": [
                "administrative_area_level_3",
                "political"
            ]
        },
        {
            "long_name": "Miaoli County",
            "short_name": "Miaoli County",
            "types": [
                "administrative_area_level_2",
                "political"
            ]
        },
        {
            "long_name": "Taiwan",
            "short_name": "TW",
            "types": [
                "country",
                "political"
            ]
        },
        {
            "long_name": "350",
            "short_name": "350",
            "types": [
                "postal_code"
            ]
        }
    ],
    "formatted_address": "No. 12, Nangang St, Zhunan Township, Miaoli County, Taiwan 350",
    "adr_address": "<span class=\"street-address\">No. 12, Nangang St, 崎頂里</span> <span class=\"locality\">Zhunan Township</span>, <span class=\"region\">Miaoli County</span>, <span class=\"country-name\">Taiwan</span> <span class=\"postal-code\">350</span>",
    "geometry": {
        "location": {
            "lat": 24.7300368,
            "lng": 120.8787035
        },
        "location_type": "",
        "bounds": {
            "northeast": {
                "lat": 0,
                "lng": 0
            },
            "southwest": {
                "lat": 0,
                "lng": 0
            }
        },
        "viewport": {
            "northeast": {
                "lat": 24.7315753802915,
                "lng": 120.8798591802915
            },
            "southwest": {
                "lat": 24.7288774197085,
                "lng": 120.8771612197085
            }
        },
        "types": null
    },
    "icon": "https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/geocode-71.png",
    "name": "No. 12, Nangang St",
    "place_id": "ChIJeSlIfru0aTQR0LK8Cz0vfDA",
    "types": [
        "premise"
    ],
    "url": "https://maps.google.com/?q=No.+12,+Nangang+St,+Zhunan+Township,+Miaoli+County,+Taiwan+350&ftid=0x3469b4bb7e482979:0x307c2f3d0bbcb2d0",
    "utc_offset": 480
}
```

Output Example 2.:

```json
{
    "Results": [
        {
            "geometry": {
                "location": {
                    "lat": 24.7299162,
                    "lng": 120.8791683
                },
                "location_type": "",
                "bounds": {
                    "northeast": {
                        "lat": 0,
                        "lng": 0
                    },
                    "southwest": {
                        "lat": 0,
                        "lng": 0
                    }
                },
                "viewport": {
                    "northeast": {
                        "lat": 24.73125213029151,
                        "lng": 120.8805296302915
                    },
                    "southwest": {
                        "lat": 24.7285541697085,
                        "lng": 120.8778316697085
                    }
                },
                "types": null
            },
            "name": "Qidingsuidao Cultural Park",
            "icon": "https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/park-71.png",
            "place_id": "ChIJAQAAAKS0aTQRo3-cls0gW50",
            "rating": 4.2,
            "user_ratings_total": 2428,
            "types": [
                "park",
                "tourist_attraction",
                "point_of_interest",
                "establishment"
            ],
            "opening_hours": {
                "open_now": true
            },
            "photos": [
                {
                    "photo_reference": "AZose0ltEuDlxg_u3aj-WnjqQO9fRDVdLFgOfHgbXlcRVukEKllJeUlSGas0tGpn5wNn-fMjrjUbHTkL6ugf0L0iyKL88o-FNxQ56VSIZXYMM9tlmfXa3fxKgde8iPdJlOjG9oOkOkd4Hp8PCFLFXAwiei2-21pPcA4SQhcqxZpqB3MNY945",
                    "height": 3024,
                    "width": 4032,
                    "html_attributions": [
                        "<a href=\"https://maps.google.com/maps/contrib/102309426600806004577\">Bernie Huang</a>"
                    ]
                }
            ],
            "vicinity": "No. 12, Nangang Street, Zhunan Township",
            "business_status": "OPERATIONAL"
        },
        {
            "geometry": {
                "location": {
                    "lat": 24.7299311,
                    "lng": 120.8793117
                },
                "location_type": "",
                "bounds": {
                    "northeast": {
                        "lat": 0,
                        "lng": 0
                    },
                    "southwest": {
                        "lat": 0,
                        "lng": 0
                    }
                },
                "viewport": {
                    "northeast": {
                        "lat": 24.7313134302915,
                        "lng": 120.8806290302915
                    },
                    "southwest": {
                        "lat": 24.7286154697085,
                        "lng": 120.8779310697085
                    }
                },
                "types": null
            },
            "name": "福德正神",
            "icon": "https://maps.gstatic.com/mapfiles/place_api/icons/v1/png_71/generic_business-71.png",
            "place_id": "ChIJocYqeLu0aTQRpXd4ruNj2RM",
            "rating": 4.3,
            "user_ratings_total": 6,
            "types": [
                "place_of_worship",
                "point_of_interest",
                "establishment"
            ],
            "opening_hours": {
                "open_now": true
            },
            "photos": [
                {
                    "photo_reference": "AZose0mCy35YB6AmyGxuc6QAPilrBrXvFtg2ZeWZLAg18GIshX-1rRWxFIQaidGjCmdK0QiEYredwR11CQpGpkgT6sm-Lm4YjZ4MIGybaGzZuCiIi4wRpAjQPmF3vPrp5-lmXqBz1k1M-jYCBDdofbXkhYWVoGBxqGNmTf41JGQEK0-_77-E",
                    "height": 3024,
                    "width": 4032,
                    "html_attributions": [
                        "<a href=\"https://maps.google.com/maps/contrib/107359315510038755694\">蔡大緯</a>"
                    ]
                }
            ],
            "vicinity": "竹南鎮",
            "business_status": "OPERATIONAL"
        }
    ],
    "HTMLAttributions": [],
    "NextPageToken": ""
}
```

### [Roads](https://developers.google.com/maps/documentation/roads/snap?hl=zh-tw)
> 將經緯度座標連結至道路或道路。找出一組座標的最近道路。取得路段的速限。

- Input
  - 經緯度座標。
- Output
  1. 將經緯度座標連結至道路或道路。
  2. 找出一組座標的最近道路。
  3. 取得路段的速限。

Output Example 1.:

```json
{
    "snappedPoints": null
}
```

Output Example 2.:

```json
{
    "snappedPoints": [
        {
            "originalIndex": 0,
            "placeId": "ChIJG1eQmLy0aTQRgH8BAiMpHEE",
            "location": {
                "latitude": 24.72967919216646,
                "longitude": 120.87884244031336
            }
        },
        {
            "originalIndex": 0,
            "placeId": "ChIJG1eQmLy0aTQRgX8BAiMpHEE",
            "location": {
                "latitude": 24.72967919216646,
                "longitude": 120.87884244031336
            }
        }
    ]
}
```

Output Example 3.:

```json
{
    "speedLimits": null,
    "snappedPoints": null
}
```

## Type

```
accounting
airport
amusement_park
aquarium
art_gallery
atm
bakery
bank
bar
beauty_salon
bicycle_store
book_store
bowling_alley
bus_station
cafe
campground
car_dealer
car_rental
car_repair
car_wash
casino
cemetery
church
city_hall
clothing_store
convenience_store
courthouse
dentist
department_store
doctor
electrician
electronics_store
embassy
fire_station
florist
funeral_home
furniture_store
gas_station
gym
hair_care
hardware_store
hindu_temple
home_goods_store
hospital
insurance_agency
jewelry_store
laundry
lawyer
library
liquor_store
local_government_office
locksmith
lodging
meal_delivery
meal_takeaway
mosque
movie_rental
movie_theater
moving_company
museum
night_club
painter
park
parking
pet_store
pharmacy
physiotherapist
plumber
police
post_office
real_estate_agency
restaurant
roofing_contractor
rv_park
school
shoe_store
shopping_mall
spa
stadium
storage
store
subway_station
supermarket
synagogue
taxi_stand
train_station
travel_agency
university
veterinary_care
zoo
```