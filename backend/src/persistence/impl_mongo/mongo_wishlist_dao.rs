use mongodb::{bson::doc, options::FindOneOptions, sync::Client};
use std::convert::TryFrom;

use super::get_mongo_client;
use crate::model::Wishlist;
use crate::persistence::{Error, Result, WishlistDao};

#[derive(Clone)]
pub struct MongoWishlistDao {
    client: Client,
}

impl MongoWishlistDao {
    pub fn new() -> Result<MongoWishlistDao> {
        info!("Creating new mongodb wishlist dao");
        Ok(MongoWishlistDao {
            client: get_mongo_client()?,
        })
    }
}

impl WishlistDao for MongoWishlistDao {
    fn get_last_wishlist(&self) -> Result<Wishlist> {
        let coll = self.client.database("wishlist").collection("wishlist");
        let options = FindOneOptions::builder()
            .sort(doc! {"timestamp": -1})
            .projection(doc! {"_id": false})
            .build();
        coll.find_one(None, Some(options))
            .map_err(Error::from)
            .and_then(|r| r.ok_or(Error::EmptyResult))
            .map(|r| Wishlist::from(&r))
    }
}
