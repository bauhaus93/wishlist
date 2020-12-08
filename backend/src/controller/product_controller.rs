use super::Result;
use crate::model::Product;

pub trait ProductController: Send + Sync {
    fn get_newest_products(&self) -> Result<Vec<Product>>;
    fn get_archived_products(&self, page: usize, per_page: usize) -> Result<Vec<Product>>;
}
