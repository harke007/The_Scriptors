from twython import Twython
import json
import datetime
import math
import time
import csv
import folium
import os

## function to write data to a .csv file
def write_tweet(t):
    try:
        target = open('tweets.csv', 'a')
        target.write(t.encode('latin-1'))
        target.write('\n')
        target.close()
    except UnicodeEncodeError:
         print "This tweet has some weird characters insight??"

## set working directory
path = r'./data'
if not os.path.exists(path):
    os.makedirs(path)
os.chdir('./data')


## codes to access twitter API. Use your own codes;)
APP_KEY = "hodoga5RfRpLeWvLUvJr6ieYn"
APP_SECRET = "cHDGkq0H90KpmrpFZKNNtQYCUycwKk3GleUze2P1zTRo3sVqzA"
OAUTH_TOKEN = "824551557739978754-z4N14QZ3S5C4zYbDGORYYB0CQUMxJLm"
OAUTH_TOKEN_SECRET = "3o8vUKK74VQFfLzrd8SP0Fk7PmowjUET1cHexRz0pqi95"

## Establish connection to Twitter API
twitter = Twython(APP_KEY, APP_SECRET, OAUTH_TOKEN, OAUTH_TOKEN_SECRET)

## initiating Twython object
SearchString = '"schaatsen";"natuurijs"'
NoTweets = 100

## Twitter is queried
search_results = twitter.search(q=SearchString, count=NoTweets, result_type='recent', geocode = '52.23,5.31,180km')

## A control variable to see if it retrieves any tweets
tweetnum = 0

## look for tweets with coordinates and save them to a csv file.
for tweet in search_results["statuses"]:
    tweetnum += 1
    print "Tweet check", str(tweetnum)
    if tweet['coordinates'] != None:
        username =  tweet['user']['screen_name']
        tweettext = tweet['text']
        coords_list = tweet['coordinates']['coordinates']
        string = str(coords_list[1])+","+str(coords_list[0])+","+username+","+tweettext
        write_tweet(string)
        print coords_list

## initialise the coordinate list to save the coordinates from the .csv file
        latlon = []
        with open('tweets.csv', 'rb+') as f:
            reader = csv.reader(f, delimiter=',')
            for row in reader:
                latlon+=[(row[0], row[1],row[3])]
                                
## initialise the map start point and zoom        
        mapit = folium.Map( location=[52.667989, 5.311447], zoom_start=6 )

## add every coordinate in the list to the map
        
        for coord in latlon:
            folium.Marker( location=[ coord[0], coord[1] ],popup= coord[2]).add_to( mapit )

## save the map !!Edit the filename to the subject!!
        mapit.save( 'schaatsen.html')
        f.close()





