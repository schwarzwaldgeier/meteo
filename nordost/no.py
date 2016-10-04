#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import json
import smtplib
from email.mime.text import MIMEText
import string
from datetime import datetime
if sys.version_info >= (3, 0):
    from urllib.request import urlopen
else:
    from urllib import urlopen
import calendar

debug = False
if len(sys.argv) > 1:
    if sys.argv[1] == "--debug" or sys.argv[1] == "-d":
        debug = True
        print ("Debug mode")
    else:
        debug = False
else:
    debug = False


max_windspeed = 5
wind_direction_boundaries = {'north': 17.5, 'east': 62.5}


def read_sensitive(path):
    sensitive = {}
    txt = open(path).read()
    txt = txt.strip()
    lines = txt.splitlines()
    for line in lines:
        if len(line) > 0 and line[
                0] != '#' and '=' in line:  # not a comment, not empty, has a '=', doesn't suck
            line = line.replace("export ", '')
            entry = line.split('=')
            sensitive[entry[0]] = entry[1]
    return sensitive


def is_windspeed_ok(forecast):
    wind_speed = forecast['wind']['speed']
    if wind_speed <= max_windspeed:
        return True
    else:
        return False


def is_wind_direction_ok(forecast):
    wind_direction = forecast['wind']['deg']
    north = wind_direction_boundaries['north']
    east = wind_direction_boundaries['east']
    if north <= wind_direction <= east:
        return True
    else:
        return False


def is_weekend(forecast):
    date = datetime.fromtimestamp(int(forecast['dt']))
    if date.weekday() >= 5:
        return True
    else:
        return False


def is_dry(forecast):
    if not forecast['rain']:  # would contain downpour in l/m2 otherwise
        return True
    else:
        return False


def is_sunny(forecast):
    if int(forecast['clouds']['all']) <= 75:  # =6/8 clouds max
        return True
    else:
        return False


def is_during_day(forecast):
    date = datetime.fromtimestamp(forecast['dt'])
    if 10 <= date.hour <= 17:
        return True
    else:
        return False


def is_good_time_for_briefing(forecast):
    if is_weekend(forecast) and is_during_day(forecast) and is_wind_direction_ok(
            forecast) and is_windspeed_ok and is_dry(forecast) and is_sunny(forecast):
        return True
    else:
        return False


def announce_briefing_day(forecast):
    listurl = sensitive['SENSITIVE_NORTHEAST_LISTURL']
    sender = sensitive['SENSITIVE_NORTHEAST_BRIEFERSMAIL']
    recipient = sensitive['SENSITIVE_NORTHEAST_BRIEFERSMAIL']
    mailinglist = sensitive['SENSITIVE_NORTHEAST_BRIEFERSMAIL']
    subject = "Nordosteinweiser für's Wochenende gesucht!"
    smtpserver = sensitive['SENSITIVE_NORTHEAST_SMTPSERVER']
    smtpuser = sensitive['SENSITIVE_NORTHEAST_BRIEFERSMAIL']
    smtppassword = sensitive['SENSITIVE_NORTHEAST_SMTPPASSWORD']
    smtpport = sensitive['SENSITIVE_NORTHEAST_SMTPPORT']
    formatted_forecasts = ""

    if debug:
        recipient = sensitive['SENSITIVE_NORTHEAST_DEBUGMAIL']
        sender = sensitive['SENSITIVE_NORTHEAST_DEBUGMAIL']
        smtpuser = sensitive['SENSITIVE_NORTHEAST_DEBUGMAIL']
        smtppassword = sensitive['SENSITIVE_NORTHEAST_DEBUGMAILPASSWORD']

    # yes i know there is something built in for this but it looked
    # complicated and I didn't care
    German_weekdays = [
        'Montag',
        'Dienstag',
        'Mittwoch',
        'Donnerstag',
        'Freitag',
        'Samstag',
        'Sonntag']
    for f in forecast:
        gooddate = date.fromtimestamp(f['dt'])
        windspeed = str(int(round(f['wind']['speed'] * 3.6)))
        winddirection = str(int(round(f['wind']['deg'])))
        # convert to 1/8s
        clouds = str(int(round(float(f['clouds']['all']) / 12.5)))
        description = f['weather']['description']
        formatted_forecasts = formatted_forecasts + German_weekdays[gooddate.weekday()] + ", " + str(gooddate.day) + '.' + str(gooddate.month) + '.' + str(gooddate.year) + ' ' + str(
            gooddate.hour) + ':' + str(gooddate.minute).rjust(2, '0') + ' Uhr:\n' + windspeed + ' km/h aus ' + winddirection + '° NO, ' + description + ", " +clouds + '/8 Bewölkung.'

    emailbody = open('/var/www/nordost/no-email.txt').read()
    emailbody = emailbody.replace('{forecasts}', formatted_forecasts)
    emailbody = emailbody.replace(
        '{participantsurl}', listurl)
    emailbody = emailbody.replace(
        '{mailinglist}', mailinglist)
    send_email(sender, recipient, subject, emailbody, smtpserver,
               smtpuser, smtppassword, smtpport)
    return True


def send_email(sender, to, subject, body, smtpserver,
               smtpuser, smtppassword, smtpport):
    msg = MIMEText(body)
    msg['Subject'] = subject
    msg['From'] = sender
    msg['To'] = to
    s = smtplib.SMTP(smtpserver)
    print (s.sendmail(sender, to, msg.as_string()))
    s.quit
    return True


print("Running script on %s" % datetime.now())
sensitive = read_sensitive("/var/www/.sensitive")
owm_api_key = sensitive['SENSITIVE_OPENWEATHERMAP_APIKEY']
owm_api_lon = "8.2806"
owm_api_lat = "48.7644"
owm_api_baseurl = "http://api.openweathermap.org/data/2.5/forecast?"
owm_api_requesturl = owm_api_baseurl + "lat=" + owm_api_lat + "&lon=" + \
    owm_api_lon + "&appid=" + owm_api_key + "&lang=de"

jsonurl = urlopen(owm_api_requesturl)
response = json.loads(jsonurl.read())
forecast_list = response['list']
good_times = []

for forecast in forecast_list:
    date = datetime.fromtimestamp(int(forecast['dt']))
    if is_good_time_for_briefing(forecast) or debug == True:
        print ("%s Looking good!" % date)
        good_times.append(forecast)

if len(good_times) > 0:
    print ("Sending email ...")
    announce_briefing_day(good_times)
else:
    print ("No good days, no email.")
print ("---")
