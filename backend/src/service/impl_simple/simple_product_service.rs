use std::sync::Arc;

use crate::model::Product;
use crate::persistence::{get_product_dao, get_source_dao, ProductDao, SourceDao};
use crate::service::{Error, ProductService, Result};

#[derive(Clone)]
pub struct SimpleProductService {
    product_dao: Arc<dyn ProductDao>,
    source_dao: Arc<dyn SourceDao>,
}

impl SimpleProductService {
    pub fn new() -> Result<SimpleProductService> {
        Ok(Self {
            product_dao: get_product_dao()
                .ok_or(Error::DaoUninitialized("product_dao".to_string()))?,
            source_dao: get_source_dao()
                .ok_or(Error::DaoUninitialized("source_dao".to_string()))?,
        })
    }
}

impl ProductService for SimpleProductService {
    fn get_products_by_wishlist_id(&self, wishlist_id: &str) -> Result<Vec<Product>> {
        unimplemented!()
    }

    fn get_archived_products(&self, page: usize, per_page: usize) -> Result<Vec<Product>> {
        unimplemented!()
    }
}
