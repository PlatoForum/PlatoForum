#!/bin/bash

DBNAME="heroku_app23515786"
COLLECTIONS=( "names" "towns" "adjectives" )
MONGOLAB_PATH="ds039349-a0.mongolab.com:39349"
for COLLECTION in ${COLLECTIONS[@]}
do
  echo import ${COLLECTION}.csv into ${DBNAME}
  mongoimport -h ${MONGOLAB_PATH} -d ${DBNAME} -c ${COLLECTION} -u boczeratul -p bocgg30cm --file ${COLLECTION}.csv --type csv --headerline
done
