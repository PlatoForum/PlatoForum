#!/bin/bash

DBNAME="plato_forum_development"
COLLECTIONS=( "names" "towns" "adjectives" )
for COLLECTION in ${COLLECTIONS[@]}
do
  echo import ${COLLECTION}.csv into ${DBNAME}
  mongoimport -h ds037087.mongolab.com:37087 -d heroku_app23515786 -c ${COLLECTION} -u boczeratul -p bocgg30cm --file ${COLLECTION}.csv --type csv --headerline
done
