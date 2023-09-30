#!/usr/bin/python

##################################################################################
# Name:         ut.py (update time)
# Version:      0.4
# Purpose:      Extract UTC-time from http://www.worldtimeserver.com/
# Author:       Mehdi Salem Naraghi. (inspired by ucttime.py by M. Luebben.)
# Modified by:
# Created:      18.12.2005 (dd.mm.yyyy)
# Copyright:    Copyright (C) 2005-2006 M. Mehdi Salem Naraghi <momesana@yahoo.de>
# License:      Distributed under the terms of the GNU General Public License v2
###################################################################################

import urllib2, re, sys, time, string, os

# ======================= FUNCTIONS ========================

def getLocalTime():
	utc = time.gmtime()
	localTime = (hour, minute, day, month, year) = (str(utc[3]), str(utc[4]), str(utc[2]), str(utc[1]), str(utc[0]))
	return list(localTime)

#-------------------------------------------------------
def getServerTime():
	try:
		url = urllib2.urlopen( \
		"http://www.worldtimeserver.com/current_time_in_UTC.aspx")
		html = url.read()
	
	except:
		print "error: downloading date/time website " \
		"from www.worldtimeserver.com"
		sys.exit(1)
	
	mtbl = {"January"   :  '01', "February" :  '02',
		"March"     :  '03', "April"    :  '04',
		"May"       :  '05', "June"     :  '06',
		"July"      :  '07', "August"   :  '08',
		"September" :  '09', "October"  :  '10',
		"November"  :  '11', "December" :  '12'}
	
	patTime = r"""
		UTC/GMT\s+is\s+
		(?P<hour>\d+)		# hour
		:
		(?P<minute>\d+)		# minute
		\s+on\s+\S+,\s+
		(?P<month>[A-z]+)	# month
		\s+
		(?P<day>\d+)		# day
		,\s+
		(?P<year>\d+)		# year
		"""
	
	serverTime = [hour, minute, day, month, year] = \
		list(re.compile(patTime, re.VERBOSE).search(html).group('hour', 'minute', 'day', 'month', 'year'))
	
	serverTime[3] = mtbl[serverTime[3]]
	return serverTime

#-------------------------------------------------------
def needsUpdate(lt, st):
	#compare Date and hour
	if not ((int(lt[0]) == int(st[0])) and \
		(int(lt[2]) == int(st[2])) and \
		(int(lt[3]) == int(st[3])) and \
		(int(lt[4]) == int(st[4]))):
		return True
	#compare minute
	if (int(lt[1]) - int(st[1]) > 1) or (int(st[1]) - int(lt[1]) > 1):
		return True
	else:
		return False

#-------------------------------------------------------
def time2str(st):
	return st[3]+st[2]+st[0]+st[1]+st[4]

# ======================== MAIN =========================

serverTime = getServerTime()
getServerTime()

if needsUpdate(getLocalTime(), serverTime):
	print "performing update"
	os.system('date -u ' + time2str(serverTime))
else:
	print "skipping update"