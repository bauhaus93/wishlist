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
    fn get_newest_products(&self) -> Result<Vec<Product>> {
        self.product_dao
            .get_newest_products()
            .and_then(|prods| self.source_dao.load_source_for_products(prods))
            .map_err(Error::from)
    }
    fn get_archived_products(&self, page: usize, per_page: usize) -> Result<Vec<Product>> {
        self.product_dao
            .get_archived_products(page, per_page)
            .map_err(Error::from)
    }
}
