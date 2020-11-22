use std::sync::Arc;

use super::{MongoProductDao, MongoSourceDao, MongoWishlistDao};
use crate::persistence::{ProductDao, SourceDao, WishlistDao};

lazy_static! {
    static ref PRODUCT_DAO: Option<Arc<MongoProductDao>> =
        MongoProductDao::new().map(Arc::new).ok();
    static ref WISHLIST_DAO: Option<Arc<MongoWishlistDao>> =
        MongoWishlistDao::new().map(Arc::new).ok();
    static ref SOURCE_DAO: Option<Arc<MongoSourceDao>> = MongoSourceDao::new().map(Arc::new).ok();
}

pub fn get_product_dao() -> Option<Arc<MongoProductDao>> {
    (*PRODUCT_DAO).clone()
}

pub fn get_wishlist_dao() -> Option<Arc<MongoWishlistDao>> {
    (*WISHLIST_DAO).clone()
}

pub fn get_source_dao() -> Option<Arc<MongoSourceDao>> {
    (*SOURCE_DAO).clone()
}
