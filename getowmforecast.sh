#!/bin/bash
/bin/bash ./.sensitive
url = "http://api.openweathermap.org/data/2.5/forecast?lat=48.7644&lon=8.2806&appid="
url = $url + SENSITIVE_OPENWEATHERMAP_APIKEY
echo "test"
curl url > /var/www/owmforecast.json
