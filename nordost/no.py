#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import json
import smtplib
from email.mime.text import MIMEText
import string
from datetime import datetime
if sys.version_info >= (3,0):
    from urllib.request import urlopen
else:
    from urllib import urlopen


max_windspeed = 5
wind_direction_boundaries = {'north': 17.5, 'east': 62.5}
#wind_direction_boundaries = {'north': 0, 'east': 360} #TEST ONLY!



	

		
def read_sensitive(path):
   # #print (path)
    sensitive = {}
    txt = open(path).read()
    ##print(txt)
    txt = txt.strip()
    lines = txt.splitlines()
    for line in lines:
        if len(line) > 0 and line[0] != '#' and '=' in line: #not a comment, not empty, has a '=', doesn't suck
            line = line.replace("export ", '')
            entry = line.split('=')
            ##print (entry)
            sensitive[entry[0]] = entry[1]
        
    return sensitive
        
        
    
    
    
    
    
    
    
		
def is_windspeed_ok(forecast):
	wind_speed = forecast['wind']['speed']
	if wind_speed <= max_windspeed:
		return True
	else:
		#print ("Wind too strong: %s km/h" % wind_speed * 3.6)
		return False
		
def is_wind_direction_ok(forecast):
	wind_direction = forecast['wind']['deg']
	north = wind_direction_boundaries['north']
	east = wind_direction_boundaries['east']
	if north <= wind_direction <= east:
		return True
	else:
		#print ("Bad wind direction: %s°" % wind_direction)
		return False
	
def is_weekend(forecast):
	date = datetime.fromtimestamp(int(forecast['dt']))
	if date.weekday() >= 5:
		return True
	else:
		#print ("Not a weekend: %s" % date.strftime("%A"))
		return False;
		
def is_dry(forecast):
	if not forecast['rain']: # would contain downpour in l/m2 otherwise
		return True
	else:
		#print ("Rain: %smm" % forecast['rain']['3h'])
		return False
	
def is_sunny(forecast):
	if int(forecast['clouds']['all']) <= 75: #=6/8 clouds max
		return True
	else:
		#print ("Too cloudy: %s%%" % int(forecast['clouds']['all']))
		return False
	
	
def is_during_day(forecast):
	date = datetime.fromtimestamp(forecast['dt'])
	if 10 <= date.hour <= 17:
		return True
	else:
		#print ("Too late or early: %s:00" % date.hour)
		return False
	
def is_good_time_for_briefing(forecast):
	if is_weekend(forecast) and is_during_day(forecast) and is_wind_direction_ok(forecast) and is_windspeed_ok and is_dry(forecast) and is_sunny(forecast):
		return True
	else:
		return False
	


def announce_briefing_day(forecast):

	formatted_forecasts = ""
	German_weekdays = ['Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag', 'Sonntag']
	for forecast in forecast:
		godddate = date.fromtimestamp(forecast['dt'])
		windspeed = str(int(round(forecast['wind']['speed'] * 3.6)))
		winddirection = str(int(round(forecast['wind']['deg'])))
		clouds = str(int(round(float(forecast['clouds']['all']) / 12.5))) #convert to 1/8s
		formatted_forecasts = formatted_forecasts + German_weekdays[date.weekday()] + ", " + str(godddate.day) + '.' + str(godddate.month) + '.' + str(godddate.year) + ' ' + str(godddate.hour) + ':' + str(godddate.minute) + ' Uhr: ' + windspeed + ' km/h aus ' + winddirection + '° NO, ' + clouds + '/8 Bewölkung, kein Regen.\n'
			
	emailbody = open('/var/www/no-email.txt').read()
	emailbody = emailbody.replace('{forecasts}', formatted_forecasts)
	emailbody = emailbody.replace('{participantsurl}', sensitive['SENSITIVE_NORTHEAST_LISTURL'])
	emailbody = emailbody.replace('{mailinglist}', sensitive['SENSITIVE_NORTHEAST_BRIEFERSMAIL'])
	
	
	send_email(sensitive['SENSITIVE_NORTHEAST_BRIEFERSMAIL'], sensitive['SENSITIVE_NORTHEAST_BRIEFERSMAIL'], "Nordosteinweiser für's Wochenende gesucht!", emailbody, sensitive['SENSITIVE_NORTHEAST_SMTPSERVER'], \
           sensitive['SENSITIVE_NORTHEAST_BRIEFERSMAIL'], sensitive['SENSITIVE_NORTHEAST_SMTPPASSWORD'], sensitive['SENSITIVE_NORTHEAST_SMTPPORT'])

	
	
	
	return True

def send_email(sender, to, subject, body, smtpserver, smtpuser, smtppassword, smtpport):
        msg = MIMEText(body)
        msg['Subject'] = subject
        msg['From'] = sender
        msg['To'] = to
        s = smtplib.SMTP(smtpserver)
        s.sendmail(sender, to, msg.as_string())
		
        s.quit    
        return True
		
		
sensitive = read_sensitive("/var/www/.sensitive")
	
owm_api_key = sensitive['SENSITIVE_OPENWEATHERMAP_APIKEY']
owm_api_lon = "8.2806"
owm_api_lat = "48.7644"
owm_api_baseurl = "http://api.openweathermap.org/data/2.5/forecast?"
owm_api_requesturl = owm_api_baseurl + "lat=" + owm_api_lat + "&lon=" + \
                     owm_api_lon + "&appid=" + owm_api_key
#print (owm_api_requesturl)



jsonurl = urlopen(owm_api_requesturl)
response = json.loads(jsonurl.read())
forecast_list = response['list']
# p#print(forecast)
good_times = []
for forecast in forecast_list:
	date = datetime.fromtimestamp(int(forecast['dt']))
	
	if is_good_time_for_briefing(forecast):
		print ("%s Looking good!" % date)
		good_times.append(forecast)
	
		
		
if len(good_times) > 0:
	print ("Sending email ...")
	announce_briefing_day(good_times)
	
else:
	print ("No days, no email.")


