use super::{Error, Result};
use crate::model::{Product, Wishlist};
use mongodb::bson::oid::ObjectId;

pub trait ProductDao: Send + Sync {
    fn get_products_by_id(&self, ids: &[ObjectId]) -> Result<Vec<Product>>;
    fn get_archived_products(&self, page: usize, per_page: usize) -> Result<Vec<Product>>;
    fn get_products_for_wishlist(&self, wishlist: &Wishlist) -> Result<Vec<Product>> {
        wishlist
            .get_product_ids()
            .ok_or(Error::FieldNotLoaded("wishlist", "product_ids"))
            .and_then(|ids| self.get_products_by_id(ids).map_err(Error::from))
            .map_err(Error::from)
    }
}
