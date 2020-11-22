use mongodb::{
    bson::{doc, oid::ObjectId, Bson},
    options::FindOptions,
    sync::Client,
};

use super::get_mongo_client;
use crate::model::Source;
use crate::persistence::{Error, Result, SourceDao};

#[derive(Clone)]
pub struct MongoSourceDao {
    client: Client,
}

impl MongoSourceDao {
    pub fn new() -> Result<Self> {
        info!("Creating new mongodb source dao");
        Ok(Self {
            client: get_mongo_client()?,
        })
    }
}
impl SourceDao for MongoSourceDao {
    fn get_source_by_id(&self, id: &ObjectId) -> Result<Source> {
        let coll = self.client.database("wishlist").collection("source");

        coll.find_one(Some(doc! {"_id": id}), None)
            .map_err(Error::from)
            .and_then(|r| r.ok_or(Error::EmptyResult).map(|r| Source::from(&r)))
    }
}
