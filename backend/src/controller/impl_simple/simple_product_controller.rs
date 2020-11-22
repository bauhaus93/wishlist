use lru_time_cache::LruCache;
use std::sync::{Arc, Mutex};
use std::time::Duration;

use crate::controller::Result;
use crate::model::Product;
use crate::service::get_product_service;

pub struct SimpleProductController {
    product_service: Arc<dyn ProductService>,
    cache: Arc<Mutex<LruCache<String, Wishlist>>>,
}

impl SimpleProductController {
    fn new() -> Resul<Self> {
        Ok(Self {
            product_service: get_product_service()?,
        })
    }
}

impl ProductController for SimpleProductController {
    fn get_archived_products(&self, page: usize, per_page: usize) -> Result<Vec<Product>> {
        unimplemented!()
    }
}
