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
    proxy = proxies_collection.find_one({"_id":ObjectId(pid)})
    if 'works_ids' in proxy.keys():
        for widobj in proxy['works_ids']:
            G[str(widobj)][cid]['weight'] -= offset
    if 'approvals_ids' in proxy.keys():
        for aidobj in proxy['approvals_ids']:
            G[str(aidobj)][cid]['weight'] -= offset
    if 'disapprovals_ids' in proxy.keys():
        for didobj in proxy['disapprovals_ids']:
            G[str(didobj)][cid]['weight'] += offset

def like(pid, cid):
    adjust_preference(pid, cid, delta)
def unlike(pid, cid):
    adjust_preference(pid, cid, -delta)

def dislike(pid, cid):
    unlike(pid, cid)

def undislike(pid, cid):
    like(pid, cid)

def create_comment(pid, cid):
    G.add_node(cid)
    for node in G.nodes():
        G.add_edge(cid, node, weight=0)
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
    elif y == 'create_comment':
        create_comment(pid, cid)
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
        print G.edges()
        print G.nodes()
