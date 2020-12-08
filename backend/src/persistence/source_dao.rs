use mongodb::bson::oid::ObjectId;
use std::collections::{btree_map::Entry, BTreeMap};

use super::{Error, Result};
use crate::model::{Product, Source};

pub trait SourceDao: Send + Sync {
    fn get_source_by_id(&self, id: &ObjectId) -> Result<Source>;
    fn load_source_for_products(&self, mut products: Vec<Product>) -> Result<Vec<Product>> {
        let mut sources = BTreeMap::new();
        for product in products.iter_mut() {
            let source_id = product
                .get_source_id()
                .map(|sid| sid.clone())
                .ok_or(Error::FieldNotLoaded("product", "source_id"))?;
            match sources.entry(source_id.clone()) {
                Entry::Vacant(e) => {
                    let source = e.insert(self.get_source_by_id(&source_id)?);
                    product.set_source(source.clone());
                }
                Entry::Occupied(e) => {
                    let source = e.get().clone();
                    product.set_source(source);
                }
            }
        }
        Ok(products)
    }
}
