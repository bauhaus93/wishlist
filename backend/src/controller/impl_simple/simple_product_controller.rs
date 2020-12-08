use std::sync::Arc;

use crate::controller::{Error, ProductController, Result};
use crate::model::Product;
use crate::service::{get_product_service, ProductService};

pub struct SimpleProductController {
    product_service: Arc<dyn ProductService>,
}

impl SimpleProductController {
    pub fn new() -> Result<Self> {
        Ok(Self {
            product_service: get_product_service()
                .ok_or(Error::ServiceUninitialized("product_service".to_string()))?,
        })
    }
}

impl ProductController for SimpleProductController {
    fn get_newest_products(&self) -> Result<Vec<Product>> {
        self.product_service
            .get_newest_products()
            .map_err(Error::from)
    }

    fn get_archived_products(&self, page: usize, per_page: usize) -> Result<Vec<Product>> {
        self.product_service
            .get_archived_products(page, per_page)
            .map_err(Error::from)
    }
}
