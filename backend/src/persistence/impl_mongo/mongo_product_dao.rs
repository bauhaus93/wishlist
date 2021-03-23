use mongodb::{
    bson::{doc, oid::ObjectId},
    options::FindOptions,
    sync::Client,
};
use std::sync::Arc;

use super::get_mongo_client;
use crate::model::{Product, Wishlist};
use crate::persistence::{Error, ProductDao, Result};

#[derive(Clone)]
pub struct MongoProductDao {
    client: Arc<Client>,
}

impl MongoProductDao {
    pub fn new() -> Result<Self> {
        info!("Creating new mongodb product dao");
        Ok(Self {
            client: get_mongo_client().ok_or(Error::ClientUninitialized)?,
        })
    }
}

impl ProductDao for MongoProductDao {
    fn get_products_by_id(&self, product_ids: &[ObjectId]) -> Result<Vec<Product>> {
        let coll = self.client.database("wishlist").collection("product");
        let query = doc! {
            "_id": { "$in": product_ids}
        };
        let options = FindOptions::builder()
            .sort(doc! {"timestamp": -1})
            .projection(doc! {"_id": false, "item_id": false})
            .build();
        coll.find(Some(query), Some(options))
            .map_err(Error::from)
            .map(|cursor| {
                cursor
                    .into_iter()
                    .take_while(|r| r.is_ok())
                    .map(|e| Product::from(&e.unwrap()))
                    .collect()
            })
    }

    fn get_newest_products(&self) -> Result<Vec<Product>> {
        let coll = self.client.database("wishlist").collection("product");
        let options = FindOptions::builder()
            .sort(doc! {"_id": -1})
            .projection(doc! {"_id": false, "item_id": false})
            .limit(10)
            .build();
        coll.find(None, Some(options))
            .map_err(Error::from)
            .map(|cursor| {
                cursor
                    .into_iter()
                    .take_while(|r| r.is_ok())
                    .map(|e| Product::from(&e.unwrap()))
                    .collect()
            })
    }

    fn get_products_not_in_wishlist(
        &self,
        wishlist: &Wishlist,
        page: usize,
        per_page: usize,
    ) -> Result<Vec<Product>> {
        let coll = self.client.database("wishlist").collection("product");

        let product_ids = wishlist
            .get_product_ids()
            .ok_or(Error::FieldNotLoaded("wishlist", "product_ids"))?;
        let filter = doc! {
        "_id": {"$not": {"$in": product_ids} } };

        let options = FindOptions::builder()
            .sort(doc! { "_id": -1})
            .projection(doc! {"_id": false, "item_id": false})
            .skip(((page - 1) * per_page) as i64)
            .limit(per_page as i64)
            .build();
        coll.find(Some(filter), Some(options))
            .map_err(Error::from)
            .map(|cursor| {
                cursor
                    .into_iter()
                    .take_while(|r| r.is_ok())
                    .map(|e| Product::from(&e.unwrap()))
                    .collect()
            })
    }
}
