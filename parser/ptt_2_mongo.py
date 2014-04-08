from PttParser import *
import pymongo
from pymongo import MongoClient

# setup mongodb client
dbClient = MongoClient()
db = dbClient['FuMou']
articleList = db['Article-List']

# parse article
parser = PttBoardParser()
parser.board('FuMouDiscuss',1,100,verbose=True)

# Insert article into db
articleList.insert(parser.articleRec)
