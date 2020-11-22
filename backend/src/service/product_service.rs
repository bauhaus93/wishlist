use super::Result;
use crate::model::Product;

pub trait ProductService: Send + Sync {
    fn get_products_by_wishlist_id(&self, wishlist_id: &str) -> Result<Vec<Product>>;
    fn get_archived_products(&self, page: usize, per_page: usize) -> Result<Vec<Product>>;
}
