use std::sync::{Arc, Mutex};
use std::time::Duration;

use crate::controller::{Error, Result, WishlistController};
use crate::model::Wishlist;
use crate::service::{get_wishlist_service, WishlistService};

pub struct SimpleWishlistController {
    wishlist_service: Arc<dyn WishlistService>,
}

impl SimpleWishlistController {
    pub fn new() -> Result<Self> {
        Ok(Self {
            wishlist_service: get_wishlist_service()
                .ok_or(Error::ServiceUninitialized("wishlist_service".to_string()))?,
        })
    }
}

impl WishlistController for SimpleWishlistController {
    fn get_last_wishlist(&self) -> Result<Wishlist> {
        self.wishlist_service
            .get_last_wishlist()
            .map_err(Error::from)
    }
}
