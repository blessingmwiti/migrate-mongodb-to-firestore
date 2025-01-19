#!/bin/bash

# Author : Prasenjit Saha
# Script follows here:

while true; do
  # Ask for name of db
  echo "Enter the name of the database you want to migrate"
  read DB_NAME

  # Confirm name of db
  echo "You have entered $DB_NAME as the name of the database. Do you want to continue? (y/n)"
  read -r -p "[y/n]: " CONFIRM

  # Default to 'y' if no input is given
  CONFIRM=${CONFIRM:-y}

  if [ "$CONFIRM" = "y" ]; then
    break
  fi
done

# Ask for db port, or use the default port 27017
echo "Enter the port of the database you want to migrate (default: 27017)"
read -r -p "[27017]: " PORT

# Change the MongoDB URI if needed
MONGODB_URI=mongodb://localhost:$PORT/$DB_NAME
SERVICE_FILE=gcpserviceaccount.json


# Get list of collections want to migrate from mongodb to firestore
echo "Enter the collections you want to migrate from MongoDB to Firestore (separated by space)"
read -a COLLECTIONS

mkdir firestore-import-data

# Loop through each collection
for COLLECTION in "${COLLECTIONS[@]}"
do
  # Export data into json format
  mongoexport --uri=$MONGODB_URI --collection=$COLLECTION --out=./mongo/$COLLECTION.json --jsonArray

  # Convert JSON into Firestore compatible JSON format
  node ./convert.js $COLLECTION

  # Import data into Firestore
  firestore-import -a ./config/${SERVICE_FILE} -b ./firestore-import-data/${COLLECTION}.json --nodePath $COLLECTION -y
done

