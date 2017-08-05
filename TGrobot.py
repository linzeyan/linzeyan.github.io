'''
"chat_id=":361923174,"
https://api.telegram.org/bot348831772:AAF0c9UrIHPideiHPvtPjVtdOPknGiZFVe4/getMe
{"ok":true,"result":{"id":348831772,"first_name":"ACG_Hostmonitor","username":"icare_BOT"}}
https://api.telegram.org/bot348831772:AAF0c9UrIHPideiHPvtPjVtdOPknGiZFVe4/getUpdates
https://api.telegram.org/bot348831772:AAF0c9UrIHPideiHPvtPjVtdOPknGiZFVe4/setWebhook?url=https://linzeyan.github.io


pip3 install psutil
pip3 install python-telegram-bot
.py
import telegram
bot = telegram.Bot(token='348831772:AAF0c9UrIHPideiHPvtPjVtdOPknGiZFVe4')
class telegram.Bot(token, base_url=None, base_file_url=None, request=None)
class telegram.Message(message_id, from_user, date, chat, forward_from=None, forward_from_chat=None, forward_from_message_id=None, forward_date=None, reply_to_message=None, edit_date=None, text=None, entities=None, audio=None, document=None, game=None, photo=None, sticker=None, video=None, voice=None, video_note=None, new_chat_members=None, caption=None, contact=None, location=None, venue=None, new_chat_member=None, left_chat_member=None, new_chat_title=None, new_chat_photo=None, delete_chat_photo=False, group_chat_created=False, supergroup_chat_created=False, channel_chat_created=False, migrate_to_chat_id=None, migrate_from_chat_id=None, pinned_message=None, invoice=None, successful_payment=None, bot=None, **kwargs)

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import telegram
from time import sleep  
bot = telegram.Bot(token='348831772:AAF0c9UrIHPideiHPvtPjVtdOPknGiZFVe4')
TEXT = 'WOW'
while True:
	bot.sendMessage(chat_id='361923174', text=TEXT)
	sleep(10)
'''
# coding: utf-8
"""By Weil Jimmer"""
import os,urllib.request,shutil,sys,re,datetime,json,psutil
from time import sleep
from sys import platform as _platform

def __init__(self):
	print("")

GRAY = "\033[1;30m"
RED = "\033[1;31m"
LIME = "\033[1;32m"
YELLOW = "\033[1;33m"
BLUE = "\033[1;34m"
MAGENTA = "\033[1;35m"
CYAN = "\033[1;36m"
WHITE = "\033[1;37m"
BGRAY = "\033[1;47m"
BRED = "\033[1;41m"
BLIME = "\033[1;42m"
BYELLOW = "\033[1;43m"
BBLUE = "\033[1;44m"
BMAGENTA = "\033[1;45m"
BCYAN = "\033[1;46m"
BDARK_RED = "\033[1;48m"
UNDERLINE = "\033[4m"
END = "\033[0m"

if _platform.find("linux")<0:
	GRAY = ""
	RED = ""
	LIME = ""
	YELLOW = ""
	BLUE = ""
	MAGENTA = ""
	CYAN = ""
	WHITE = ""
	BGRAY = ""
	BRED = ""
	BLIME = ""
	BYELLOW = ""
	BBLUE = ""
	BMAGENTA = ""
	BCYAN = ""
	UNDERLINE = ""
	END = ""
	os.system("color c")

print (RED)
print ("*" * 40)
print ("*  Name:\tServer Status Telegram Bot")
print ("*  Team:" + LIME + "\tWhite Birch Forum Team" + RED)
print ("*  Developer:\tWeil Jimmer")
print ("*  Website:\thttps://weils.net/")
print ("*  Date:\t2016.07.04")
print ("*" * 40)
print (END)

chat_id = "361923174"
api_key = "348831772:AAF0c9UrIHPideiHPvtPjVtdOPknGiZFVe4"
root_dir = "/tmp/"
msg_id = ""
sleep_second = 5

def int_s(k):
	try:
		return int(k)
	except:
		return -1

def reporthook2(blocknum, blocksize, totalsize):
	do_nothing=True

def url_encode(url_):
	if url_.startswith("http://"):
		return 'http://' + urllib.parse.quote(url_[7:])
	elif url_.startswith("https://"):
		return 'https://' + urllib.parse.quote(url_[8:])
	elif url_.startswith("ftp://"):
		return 'ftp://' + urllib.parse.quote(url_[6:])
	elif ((not url_.startswith("ftp://")) and (not url_.startswith("http"))):
		return 'http://' + urllib.parse.quote(url_)
	return url_

def upload_URL(url,encode,data_X,method_X):
	file_name="temp_file_pyserverstatus"
	opener = urllib.request.FancyURLopener({})
	opener.version = 'Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36'
	opener.addheader("Referer", url)
	opener.addheader("X-Forwarded-For", "0.0.0.0")
	opener.addheader("Client-IP", "0.0.0.0")
	if method_X=="POST":
		local_file,response_header=opener.retrieve(url_encode(url), root_dir + file_name, reporthook2, urllib.parse.urlencode(data_X))
	else:
		local_file,response_header=opener.retrieve(url, root_dir + file_name, reporthook2)
	return open(local_file,encoding=encode).read()

def api_make_req_json(data_X):
	api_url = "https://api.telegram.org/bot" + api_key + "/"
	response=(upload_URL(api_url,"utf-8",data_X,"POST"))
	return json.loads(response)

def sendMessage(text,chatid):
	return api_make_req_json({"method":"sendMessage","chat_id":chatid,"text":text})

def editMessageText(text,chatid,messageid):
	return api_make_req_json({"method":"editMessageText","chat_id":chatid,"message_id":messageid,"text":text})

while True:
	time_now_str = "當前時間：\n" + str(datetime.datetime.now())
	cpu_useage_str = "CPU使用率：" + str(psutil.cpu_percent(interval=1)) + " %"
	memory_useage = psutil.virtual_memory()
	memory_useage_str = "記憶體使用率：" + str(memory_useage.percent) + " %\n已用：" + str(round(memory_useage.total*0.01*memory_useage.percent/1024/1024/1024,3)) + " GB" + "\n總共：" + str(round(memory_useage.total/1024/1024/1024,3)) + " GB"
	str_value = time_now_str + "\n" + cpu_useage_str + "\n" + memory_useage_str
	if msg_id=="":
		dom=sendMessage(str_value,chat_id)
		msg_id=dom['result']['message_id']
	else:
		editMessageText(str_value,chat_id,msg_id)
	sleep(sleep_second)
	
