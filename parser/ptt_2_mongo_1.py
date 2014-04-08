from PttParser import *
import pymongo
from pymongo import MongoClient

# setup mongodb client
dbClient = MongoClient()
db = dbClient['FuMou']
articleList = db['Article-List']

parser = PttArticleParser()
for art in articleList.find():
    parser.reset()
    url = "http://www.ptt.cc%s" % art['url']
    parser.parse_article(url)
    art.update( parser.meta )
