use std::sync::Arc;

use crate::model::Product;
use crate::persistence::{
    get_product_dao, get_source_dao, get_wishlist_dao, ProductDao, SourceDao, WishlistDao,
};
use crate::service::{Error, ProductService, Result};

#[derive(Clone)]
pub struct SimpleProductService {
    product_dao: Arc<dyn ProductDao>,
    wishlist_dao: Arc<dyn WishlistDao>,
    source_dao: Arc<dyn SourceDao>,
}

impl SimpleProductService {
    pub fn new() -> Result<SimpleProductService> {
        Ok(Self {
            product_dao: get_product_dao()
                .ok_or(Error::DaoUninitialized("product_dao".to_string()))?,
            wishlist_dao: get_wishlist_dao()
                .ok_or(Error::DaoUninitialized("wishlist_dao".to_string()))?,
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
        let last_wishlist = self.wishlist_dao.get_last_wishlist()?;
        self.product_dao
            .get_products_not_in_wishlist(
                &last_wishlist,
                usize::max(1, page),
                usize::min(50, per_page),
            )
            .map_err(Error::from)
    }
}
