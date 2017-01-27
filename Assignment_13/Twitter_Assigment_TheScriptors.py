from twython import Twython
import json
import csv
import folium
import os

#--------------Initialising values---------------
## Credentials to access twitter API. Use your own codes;)
APP_KEY = "PBkYxcKtS1uMvcXkK87k85k7s"
APP_SECRET = "U4Tmy3BmWaOjn4zbhVusIdZdVjrCnG3mqnMXaak4clnBJQ7SsK"
OAUTH_TOKEN = "2876884383-42VttleS4CDRFEtkqykCPdfeiqKd5NM1y2oI9Mn"
OAUTH_TOKEN_SECRET = "bQyLsXxrjyA7RgEqDseRtkVfUtF6s2gDQxFtHPDlm2NDT"

## Establish connection to Twitter API
twitter = Twython(APP_KEY, APP_SECRET, OAUTH_TOKEN, OAUTH_TOKEN_SECRET)

#--------------Describe functions---------------#
## function to write data to a .csv file
def write_tweet(t):
    target = open('tweets.csv', 'a')
    target.write(t.encode('ascii','ignore').replace('\n',' '))
    target.write('\n')
    target.close()

## function to get up to 100 tweets,
  #given the id of the newest tweet you want (0 for very-newest tweet)
  #saves every geolocated tweet to the csv
def SingleTwitterQuery(lastid):
    ended = False #turns true at end of Twitter history (7 days)
    NoOfTweets = 100
    if lastid == 0: # For first query, give lastid = 0 because twitter's max_id of the last tweet is unknown;
        print "uses intitialisation query"
        search_results = twitter.search(q=SearchString, count=NoOfTweets, result_type='recent', geocode = '52.23,5.31,180km')
    else: # After first query, lastid is known and is given as a maxid 
        search_results = twitter.search(q=SearchString, count=NoOfTweets, result_type='recent', geocode = '52.23,5.31,180km',
                                        max_id = lastid-1)
    try:
        ## look for tweets with coordinates and save them to the csv file.
        for tweet in search_results["statuses"]:
            if tweet['coordinates'] != None:
                print "Tweet with coordinates found"
                username =  tweet['user']['screen_name']
                tweettext = tweet['text']
                coords_raw = tweet['coordinates']['coordinates']
                string = str(coords_raw[1])+","+str(coords_raw[0])+","+username+","+tweettext.replace(',',';')
                write_tweet(string) #saves the tweet to csv
        sinceid = tweet['id'] #takes the id of the last tweet of chronological list
        print "sinceid", sinceid
    except NameError:
        print "end of twitter history (7 days)"
        sinceid = 9999
        ended = True
    return sinceid, ended


#--------------Executing functions---------------#

## Set working directory
path = r'./data'
if not os.path.exists(path):
    os.makedirs(path)
os.chdir('./data')

## Get all possible tweets (SingleTwitterQuery saves them to a csv)
SearchString = '"schaatsen";"natuurijs"'
lastid = 0
ended = False #turns true at end of Twitter history (7 days)
while not ended:
    sinceid, ended = SingleTwitterQuery(lastid)
    lastid = sinceid

## Take the coordinates out of the csv and make a coordinate list
latlon = []
with open('tweets.csv', 'rb+') as f:
    reader = csv.reader(f, delimiter=',')
    try:
        for row in reader:
            latlon+=[(row[0], row[1],row[3])]
    except: "Bad line in csv found"
    f.close

## Add every coordinate in the list to the map, if empty
if latlon != []:
    ## initialise the map start point and zoom        
    mapit = folium.Map(location=[52.667989, 5.311447], zoom_start=6 )
    for coord in latlon:
        folium.Marker(location=[coord[0], coord[1]], popup=coord[2]).add_to(mapit)
    ## save the map
    mapit.save('schaatsen.html')
    print "html-file created in data folder, go ahead and take a look!"
else:
    print "No tweets with geolocation"
