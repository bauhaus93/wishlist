use std::sync::Arc;

use crate::model::Wishlist;
use crate::persistence::{
    get_product_dao, get_source_dao, get_wishlist_dao, ProductDao, SourceDao, WishlistDao,
};
use crate::service::{Error, Result, WishlistService};

#[derive(Clone)]
pub struct SimpleWishlistService {
    wishlist_dao: Arc<dyn WishlistDao>,
    product_dao: Arc<dyn ProductDao>,
    source_dao: Arc<dyn SourceDao>,
}

impl SimpleWishlistService {
    pub fn new() -> Result<SimpleWishlistService> {
        Ok(Self {
            wishlist_dao: get_wishlist_dao()
                .ok_or(Error::DaoUninitialized("wishlist_dao".to_string()))?,
            product_dao: get_product_dao()
                .ok_or(Error::DaoUninitialized("product_dao".to_string()))?,
            source_dao: get_source_dao()
                .ok_or(Error::DaoUninitialized("source_dao".to_string()))?,
        })
    }
}

impl WishlistService for SimpleWishlistService {
    fn get_last_wishlist(&self) -> Result<Wishlist> {
        let mut wishlist = self.wishlist_dao.get_last_wishlist()?;
        let products = self
            .product_dao
            .get_products_for_wishlist(&wishlist)
            .and_then(|prods| self.source_dao.load_source_for_products(prods))?;
        wishlist.set_products(products);

        Ok(wishlist)
    }
}
