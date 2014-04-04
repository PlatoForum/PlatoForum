import redis 
rc = redis.Redis()

ps = rc.pubsub()
ps.subscribe(['jobqueue', 'jobs'])

for item in ps.listen():
    if item['type'] == 'message':
        print item['channel']
        print item['data']
