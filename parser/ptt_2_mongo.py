from PttParser import *
import pymongo
from pymongo import MongoClient
import argparse

argparser = argparse.ArgumentParser(description='Read article list from a given board on PTT',epilog='Dada GG da')
argparser.add_argument('board',nargs='?',default="FuMouDiscuss",help='name of board to be parsed')
argparser.add_argument('--start',type=int,default=1,help='index of the first page to be parsed')
argparser.add_argument('--end',type=int,default=2,help='index of the last page to be parsed')
argparser.add_argument('--heroku',default=False,action='store_true',help='specify whether the script is run on heroku')
argparser.add_argument('--database',type=str,default='Ptt',dest='db',help='database name on MongoDB')
argparser.add_argument('--collection',type=str,default='FuMou',dest='col',help='collection name on MongoDB')
argparser.add_argument('--verbose',default=False,action='store_true',help='print up url during parsing')
argparser.add_argument('--reset',default=False,action='store_true',help='reset collection before parsing')
args = argparser.parse_args()


# setup mongodb client
if args.heroku:
    import os, urlparse
    mongoURI = os.environ['MONGOLAB_URI']
    dbClient = MongoClient(os.environ['MONGOLAB_URI'])
    parseobj = urlparse.urlparse(mongoURI)
    db= dbClient[ parseobj.path[1:] ]
else:
    dbClient = MongoClient()
    db = dbClient[args.db]
articleColl = db[args.col]
if args.reset:
    articleColl.remove()
# parse article
parser = PttBoardParser()
parser.board(args.board,args.start,args.end,verbose=args.verbose)

# Insert article into db
articleColl.insert(parser.articleRec)
