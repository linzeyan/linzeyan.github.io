---
title: "2020年，最新NGINX的ngx_http_geoip2模块以精准禁止特定国家或者地区IP访问"
date: 2020-10-27T15:44:48+08:00
menu:
  sidebar:
    name: "2020年，最新NGINX的ngx_http_geoip2模块以精准禁止特定国家或者地区IP访问"
    identifier: nginx-module-http_geoip2-deny-ip-access
    weight: 10
tags: ["URL", "Nginx", "GeoIP"]
categories: ["URL", "Nginx", "GeoIP"]
hero: images/hero/nginx.jpeg
---

- [2020 年，最新 NGINX 的 ngx_http_geoip2 模块以精准禁止特定国家或者地区 IP 访问](https://www.cnblogs.com/faberbeta/p/nginx_geoip2.html)
- [centos7 下 安装 GeoIP2，在 nginx 中根据 ip 地址对应的国家转发请求](https://www.cnblogs.com/baxiqiuxing/p/12376879.html)

##### 安装 geoip2 lib

```bash
cd /usr/local/src
rm -f libmaxminddb-1.4.2.tar.gz
wget https://github.com/maxmind/libmaxminddb/releases/download/1.4.2/libmaxminddb-1.4.2.tar.gz
tar -xzf libmaxminddb-1.4.2.tar.gz
cd libmaxminddb-1.4.2
yum install gcc gcc-c++ make -y
./configure
make
make check
sudo make install

echo '/usr/local/lib' > /etc/ld.so.conf.d/geoip.conf
sudo ldconfig
```

##### 下载 ngx_http_geoip2_module 模块

```bash
cd /usr/local/src
wget https://github.com/leev/ngx_http_geoip2_module/archive/3.3.tar.gz
tar -xzf 3.3.tar.gz
mv ngx_http_geoip2_module-3.3 ngx_http_geoip2_module

# nginx集成
cd /usr/local/src
wget http://nginx.org/download/nginx-1.16.1.tar.gz
tar -zxf nginx-1.16.1.tar.gz
cd nginx-1.16.1
useradd -M -s /sbin/nologin www


yum install gcc gcc-c++ make pcre-devel zlib-devel openssl-devel -y
./configure --user=www --group=www --prefix=/usr/local/nginx \
--with-ld-opt="-Wl,-rpath -Wl,/usr/local/lib" \
--with-http_sub_module \
--with-http_realip_module \
--with-http_gzip_static_module \
--with-http_ssl_module \
--with-http_v2_module \
--add-module=/usr/local/src/ngx_http_geoip2_module

make
make install
```

##### geoip2 IP 地址库下载

2020 年最新 GeoLite2-City.mmdb 无法直接下载，必须注册 maxmind 账号

1. 需要在 maxmind 后台注册账号，并且生成 Account/User ID 和 License key
2. 安装 geoipupdate, 下载地址https://github.com/maxmind/geoipupdate/releases
3. 配置 geoipupdate 的 GeoIP.conf , 填写 maxmind 账号的 User ID 和 License key 和 EditionIDs

博主使用的是 centos 7
安装如下

```bash
cd /usr/local/src/
wget https://github.com/maxmind/geoipupdate/releases/download/v4.2.0/geoipupdate_4.2.0_linux_amd64.rpm
rpm -ivh geoipupdate_4.2.0_linux_amd64.rpm
rpm -ql geoipupdate vi /etc/GeoIP.conf
#填写AccountID XXXX #填写LicenseKey XXXX #EditionIDs可以不修改，系统默认有填 GeoLite2-Country GeoLite2-City
#笔者EditionIDs只保留GeoLite2-City
#保存退出
#运行geoipupdate
/usr/bin/geoipupdate
cd /usr/share/GeoIP/
# 会看到GeoLite2-City.mmdb 把GeoLite2-City.mmdb文件cp到需要使用的目录
sudo mkdir -p /usr/local/nginx/geoip/
cp -rf /usr/share/GeoIP/GeoLite2-City.mmdb /usr/local/nginx/geoip/maxmind-city.mmdb

```

注意 GeoLite2 City 和 GeoLite2 Country 两个 IP 库，请下载 City 的 mmdb 数据文件，较于其他两者信息更丰富

```nginx
http {
  ...
 geoip2 /usr/local/nginx/geoip/maxmind-city.mmdb {
       $geoip2_data_country_code default=US source=$remote_addr country iso_code;
       $geoip2_data_country_name country names en;
       $geoip2_data_city_name default=London city names en;
       $geoip2_data_province_name subdivisions 0 names en;
       $geoip2_data_province_isocode subdivisions 0 iso_code;
  }
  ....
  fastcgi_param COUNTRY_CODE $geoip2_data_country_code;
  fastcgi_param COUNTRY_NAME $geoip2_data_country_name;
  fastcgi_param CITY_NAME    $geoip2_data_city_name;
  ....
    map geoip2_data_country_code $allowed_country {
        default yes;
        US no;
        JP no;
        SG no;
     }
}
stream {
    ...
    geoip2 /usr/local/nginx/geoip/maxmind-city.mmdb {
      $geoip2_data_country_code default=US source=$remote_addr country iso_code;
      $geoip2_data_country_name country names en;
      $geoip2_data_city_name default=London city names en;
      $geoip2_data_province_name subdivisions 0 names en;
      $geoip2_data_province_isocode subdivisions 0 iso_code;
    }
    ...
}
```

```nginx
server {
     if ($allowed_country = no) {     return 403; }
}
```

`/usr/local/bin/mmdblookup --file /usr/local/nginx/geoip/maxmind-city.mmdb --ip 8.8.8.8`
