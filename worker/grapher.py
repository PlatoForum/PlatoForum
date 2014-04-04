import redis
import pymongo
from pymongo import MongoClient
import os
import json

def like(job):
    pass

def unlike(job):
    pass

def dislike(job):
    print 'This is an dislike' + job['action']

def undislike(job):
    pass

def create_comment(job):
    pass

def process_job(job):
    y = job['action']
    if y == 'like':
        like(job)
    elif y == 'unlike':
        unlike(job)
    elif y == 'dislike':
        dislike(job)
    elif y == 'undislike':
        undislike(job)
    elif y == 'create_comment':
        create_comment(job)
    else:
        # should throw an exception here
        pass

rc = redis.Redis()

# connect to MongoDB
mongolab = False 
# True if connecting to MongoLab, 
# False if connecting to local MongoDB server
if mongolab:
    mongo_connection = MongoClient("ds1111.mongolab.com", 55666)
    db = mongo_connetion["platoforum_db"]
    db.authenticate(os.environ['MONGOLAB_USER'], os.environ['MONGOLAB_PWD'])
else:
    mongo_connection = MongoClient()
    db = mongo_connection["plato_forum_development"]

proxies_collection = db['proxies']
comments_collection = db['comments']

ps = rc.pubsub()
ps.subscribe(['jobqueue', 'jobs'])

for item in ps.listen():
    if item['type'] == 'message':
        job = json.loads(item['data'])
        process_job(job)

