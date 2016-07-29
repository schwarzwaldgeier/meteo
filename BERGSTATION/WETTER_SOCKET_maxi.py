#!/usr/bin/env python
# -*- coding: utf-8 -*-
import base64
import re
import SocketServer
import sys
import urllib2

HOST, PORT = "192.168.1.13", 7977
WIND_SCALING_FACTOR=1.35
WIND_OFFSET=16

class ParseAndPush(SocketServer.BaseRequestHandler):
    @staticmethod
    def clean(string):
        return re.sub("[^0-9\.\,:-]", "", string)

    def handle(self):
        # self.request is the TCP socket connected to the client
        self.data = self.request.recv(1024).strip().split(',')
        # Example output:
        # 18:27:00, 28.07.16, TE18.44, DR1017.07, FE50.61, WS47.29, WD37.96, WC11.10, WV298.45, 
        # 18:28:00, 28.07.16, TE18.13, DR1017.25, FE51.96, WS47.29, WD36.40, WC11.15, WV302.69, 
        # 18:29:00, 28.07.16, TE17.85, DR1017.12, FE53.93, WS44.10, WD38.11, WC10.45, WV280.93, 
        #
        # and splitted:
        #['18:24:00', ' 28.07.16', ' TE19.79', ' DR1016.73', ' FE40.24', ' WS27.31', ' WD24.74', ' WC14.79', ' WV266.82', ' \x1f']
        xtime, xdate, xte, xpr, xhu, xwmo, xwso, xwc, xwdo = map(self.clean, self.data[:9])

        xws = int(float(xwso) / WIND_SCALING_FACTOR)
        xwm = int(float(xwmo) / WIND_SCALING_FACTOR)
        xwd = int(float(xwdo) - WIND_OFFSET) % 360

        print "Time of reading: %s %s" % (xtime, xdate)
        print "  Temperatur:    %s" % xte
        print "  Luftdruck:     %s" % xpr
        print "  Feuchte:       %s" % xhu
        print "  Windspeed org: %s" % xwso
        print "  Windspeed cal: %s" % xws
        print "  Windmax org:   %s" % xwmo
        print "  Windmax cal:   %s" % xwm
        print "  WRichtung org: %s" % xwdo
        print "  WRichtung cal: %s" % xwd
        print "  Windchill:     %s" % xwc

        if xwso == 0:  # With 0 wind, set wind and direction to 0
            xws = 0
            xwd = 0
            print "  >> NULLWIND <<"

        # TODO: add logging

        qstring = "wd=%s&ws=%s&te=%s&pr=%s&ms=%s&hu=%s&wc=%s" % (
                   xwd, xws, xte, xpr, xwm, xhu, xwc)
        qstring_time = qstring + "&xtsd=%s&xtst=%s" % (xdate, xtime)

        urls = [("Bergrechner", "http://localhost:81/wetterstation/insert3.php?" + qstring_time, None),
                ("GSV Homepage", "http://www.schwarzwaldgeier.de/_extphp/wetterstation/insert/insert2.php?" + qstring_time, ('wetter', 'merkur11')),
                ("Lenkungsgruppe", "http://www.lenkungsgruppe.de/v3/wetterstation/insert2.php?" + qstring, ('para', 'geier')),
                ]

        print "Pushing data to URLs:"
        sys.stdout.flush()
        for name, url, auth in urls:
            #print "Making request:", url
            try:
                request = urllib2.Request(url)
                if auth:
                    base64string = base64.encodestring('%s:%s' % (auth[0], auth[1])).replace('\n', '')
                    request.add_header("Authorization", "Basic %s" % base64string)   
                print  " [", name, "]:", urllib2.urlopen(request).read().strip()
            
            except urllib2.HTTPError, e:
                print 'HTTPError = ' + str(e.code)
            except urllib2.URLError, e:
                print 'URLError = ' + str(e.reason)
            except httplib.HTTPException, e:
                print 'HTTPException'
            except Exception:
                import traceback
                print 'generic exception: ' + traceback.format_exc()

            sys.stdout.flush()
        print ""

SocketServer.TCPServer.allow_reuse_address = True
server = SocketServer.TCPServer((HOST, PORT), ParseAndPush)
print "* Starting socket service"
server.serve_forever()

