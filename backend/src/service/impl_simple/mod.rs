mod service;
mod simple_product_service;
mod simple_wishlist_service;

use self::simple_product_service::SimpleProductService;
use self::simple_wishlist_service::SimpleWishlistService;

pub use self::service::{get_product_service, get_wishlist_service};
