#!/bin/sh

DB_URL=$(cat .env | awk -F '=' '$1 ~ /DATABASE_URL/ { print $2 }' | grep -o -e "mongodb.*/wishlist")
TIMESTAMP=$(date +%Y_%m_%d)

mkdir -p backup && \
	mongoexport --uri="$DB_URL"  --collection=product  --out=backup/product.json && \
	mongoexport --uri="$DB_URL"  --collection=wishlist  --out=backup/wishlist.json && \
	mongoexport --uri="$DB_URL"  --collection=source  --out=backup/source.json && \
	mongoexport --uri="$DB_URL"  --collection=category  --out=backup/category.json && \
	cd backup && \
	tar cvzf "wishlist_backup_$TIMESTAMP.tar.gz" *.json && \
	rm *.json

