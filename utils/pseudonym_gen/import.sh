#!/bin/bash

DBNAME="plato_forum_development"
COLLECTIONS=( "names" "towns" "adjectives" )
for COLLECTION in ${COLLECTIONS[@]}
do
  echo import ${COLLECTION}.csv into ${DBNAME}
  mongoimport --db ${DBNAME} --collection ${COLLECTION} --file ${COLLECTION}.csv --headerline --type csv
done
