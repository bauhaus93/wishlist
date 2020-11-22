use mongodb::bson::oid::ObjectId;
use std::collections::{btree_map::Entry, BTreeMap};
use std::sync::Arc;

use crate::model::{Product, Source, Wishlist};
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
        let mut products = self.product_dao.get_products_for_wishlist(&wishlist)?;

        let mut sources = BTreeMap::new();
        for product in products.iter_mut() {
            let source_id = product
                .get_source_id()
                .map(|sid| sid.clone())
                .ok_or(Error::FieldNotLoaded("product", "source_id"))?;
            match sources.entry(source_id.clone()) {
                Entry::Vacant(e) => {
                    let source = e.insert(self.source_dao.get_source_by_id(&source_id)?);
                    product.set_source(source.clone());
                }
                Entry::Occupied(e) => {
                    let source = e.get().clone();
                    product.set_source(source);
                }
            }
        }

        wishlist.set_products(products);

        Ok(wishlist)
    }
}
