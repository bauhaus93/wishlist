use std;
use std::collections::btree_map::{Entry, BTreeMap};
use mongodb::{bson::{doc, oid::ObjectId, document::Document} , options::{FindOptions, FindOneOptions}, Client, Cursor, Collection};
use std::sync::Arc;
use tokio::stream::StreamExt;

use super::{Result, Error};
use crate::query::PaginationQuery;
use crate::model::{Source, Wishlist, Product};

pub async fn handle_get_last_wishlist(client: Arc<Client>) -> Result<Wishlist> {
    let mut last_wishlist = get_last_wishlist(&client).await?;
    load_wishlist(&client, &mut last_wishlist).await?;
    Ok(last_wishlist)
}

pub async fn handle_get_newest_products(client: Arc<Client>) -> Result<Vec<Product>> {
    let options = FindOptions::builder()
            .sort(doc! {"_id": -1})
            .projection(doc! {"_id": false, "item_id": false})
            .limit(10)
            .build();
    load_products(&client, None, Some(options)).await
}

pub async fn handle_get_archived_products(pagination: PaginationQuery, client: Arc<Client>) -> Result<Vec<Product>> {
    let last_wishlist = get_last_wishlist(&client).await?;
    let product_ids = last_wishlist
        .get_product_ids()
        .ok_or(Error::FieldNotLoaded("wishlist", "product_ids"))?;
    let filter = doc! {
    "_id": {"$not": {"$in": product_ids} } };

    let options = FindOptions::builder()
        .sort(doc! { "_id": -1})
        .projection(doc! {"_id": false, "item_id": false})
        .skip(pagination.get_offset() as i64)
        .limit(pagination.get_per_page() as i64)
        .build();
    load_products(&client, Some(filter), Some(options)).await
}

pub async fn handle_get_archive_product_count(client: Arc<Client>) -> Result<u64> {
    let last_wishlist = get_last_wishlist(&client).await?;
    let product_ids = last_wishlist
        .get_product_ids()
        .ok_or(Error::FieldNotLoaded("wishlist", "product_ids"))?;
    let filter = doc! {
    "_id": {"$not": {"$in": product_ids} } };

    count_documents(&client.database("wishlist").collection("product"), Some(filter)).await
}

async fn count_documents(collection: &Collection, filter: Option<Document>) -> Result<u64> {
    collection.count_documents(filter, None).await
        .map(|n| n as u64)
        .map_err(Error::from)
}

async fn extract_cursor_results<T: From<Document> + std::fmt::Debug>(mut cursor: Cursor) -> Vec<T> {
    let mut results = Vec::new();
    while let Some(entry) = cursor.next().await {
        if let Ok(result) = entry {
            results.push(T::from(result));
        } else {
            warn!("Couldn't extract bson result as Product");
        }
    }
    results
}

async fn get_wishlist(client: &Client, filter: Option<Document>, options: Option<FindOneOptions>) -> Result<Wishlist> {
    let coll = client.database("wishlist").collection("wishlist");
    coll.find_one(filter, options).await
        .map_err(Error::from)
        .and_then(|r| r.ok_or(Error::EmptyResult))
        .map(|r| Wishlist::from(&r))
}

async fn get_last_wishlist(client: &Client) -> Result<Wishlist> {
    let options = FindOneOptions::builder()
        .sort(doc! {"timestamp": -1})
        .projection(doc! {"_id": false})
        .build();
    get_wishlist(client, None, Some(options)).await
}

async fn load_wishlist(client: &Client, wishlist: &mut Wishlist) -> Result<()> {
    let mut products = match wishlist.get_product_ids() {
        Some(ids) => get_products_by_id(&client, ids).await?,
        None => {
            return Err(Error::FieldNotLoaded("wishlist", "product_ids"));
        }
    };
    load_source_for_products(&client, &mut products).await?;
    wishlist.set_products(products);
    Ok(())
}

async fn load_products(client: &Client, filter: Option<Document>, options: Option<FindOptions>) -> Result<Vec<Product>> {
    let coll = client.database("wishlist").collection("product");
    let cursor = coll.find(filter, options).await?;
    let mut products = extract_cursor_results(cursor).await;
    load_source_for_products(&client, &mut products).await?;
    Ok(products)
}

async fn load_source_for_products(client: &Client, products: &mut [Product]) -> Result<()> {
    let mut sources = BTreeMap::new();
        for product in products.iter_mut() {
            let source_id = product
                .get_source_id()
                .map(|sid| sid.clone())
                .ok_or(Error::FieldNotLoaded("product", "source_id"))?;
            match sources.entry(source_id.clone()) {
                Entry::Vacant(e) => {
                    let source = e.insert(get_source_by_id(client, &source_id).await?);
                    product.set_source(source.clone());
                }
                Entry::Occupied(e) => {
                    let source = e.get().clone();
                    product.set_source(source);
                }
            }
        }

    Ok(())
}

async fn get_source_by_id(client: &Client, id: &ObjectId) -> Result<Source> {
        let coll = client.database("wishlist").collection("source");

        coll.find_one(Some(doc! {"_id": id}), None).await
            .map_err(Error::from)
            .and_then(|r| r.ok_or(Error::EmptyResult).map(|r| Source::from(&r)))
}

async fn get_products_by_id(client: &Client, product_ids: &[ObjectId]) -> Result<Vec<Product>> {
    let coll = client.database("wishlist").collection("product");
        let filter = doc! {
            "_id": { "$in": product_ids}
        };
        let options = FindOptions::builder()
            .sort(doc! {"timestamp": -1})
            .projection(doc! {"_id": false, "item_id": false})
            .build();

    let cursor = coll.find(Some(filter), Some(options)).await?;
    Ok(extract_cursor_results(cursor).await)
}
