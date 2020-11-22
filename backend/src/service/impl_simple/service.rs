use super::{SimpleProductService, SimpleWishlistService};
use std::sync::Arc;

lazy_static! {
    static ref PRODUCT_SERVICE: Option<Arc<SimpleProductService>> =
        SimpleProductService::new().map(Arc::new).ok();
    static ref WISHLIST_SERVICE: Option<Arc<SimpleWishlistService>> =
        SimpleWishlistService::new().map(Arc::new).ok();
}

pub fn get_product_service() -> Option<Arc<SimpleProductService>> {
    (*PRODUCT_SERVICE).clone()
}

pub fn get_wishlist_service() -> Option<Arc<SimpleWishlistService>> {
    (*WISHLIST_SERVICE).clone()
}
