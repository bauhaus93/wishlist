use mongodb::bson::oid::ObjectId;

use super::Result;
use crate::model::{Product, Source};

pub trait SourceDao: Send + Sync {
    fn get_source_by_id(&self, id: &ObjectId) -> Result<Source>;
}
