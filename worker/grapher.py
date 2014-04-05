import redis
import pymongo
from pymongo import MongoClient
import os
import json
from bson.objectid import ObjectId
import networkx as nx

G = nx.Graph()
delta = 1

def adjust_preference(pid, cid, offset):
    global G
    global delta
    print 'before adjustment'
    graph_status()
    proxy = proxies_collection.find_one({"_id":ObjectId(pid)})
    works = comments_collection.find({"owner_id":ObjectId(pid)})
    for widobj in works:
        print widobj['_id']
        print str(widobj['_id'])
        G[str(widobj['_id'])][cid]['weight'] -= offset
    if 'approval_ids' in proxy.keys():
        for aidobj in proxy['approval_ids']:
            print 'approval'
            G[str(aidobj)][cid]['weight'] -= offset
    if 'disapproval_ids' in proxy.keys():
        for didobj in proxy['disapproval_ids']:
            print 'disapproval'
            G[str(didobj)][cid]['weight'] += offset
    print 'after adjustment'
    graph_status()

def like(pid, cid):
    print 'like'
    global delta
    adjust_preference(pid, cid, delta)
def unlike(pid, cid):
    print 'unlike'
    global delta
    adjust_preference(pid, cid, -delta)

def dislike(pid, cid):
    print 'dislike'
    unlike(pid, cid)

def undislike(pid, cid):
    print 'undislike'
    like(pid, cid)

def create(pid, cid):
    print 'create'
    global G
    G.add_node(cid)
    for node in G.nodes():
        G.add_edge(cid, node)
        G[cid][node]['weight'] = 0
    like(pid, cid)

def process_job(job):
    pid = job['who']['$oid']
    cid = job['post']['$oid']
    y = job['action']
    if y == 'like':
        like(pid, cid)
    elif y == 'unlike':
        unlike(pid, cid)
    elif y == 'dislike':
        dislike(pid, cid)
    elif y == 'undislike':
        undislike(pid, cid)
    elif y == 'create':
        create(pid, cid)
    else:
        # should throw an exception here
        pass

def graph_status():
    print [(n,G[n]) for n in G.nodes()]

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
        print [(n,G[n]) for n in G.nodes()]
