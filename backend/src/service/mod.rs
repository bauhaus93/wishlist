mod error;
mod impl_simple;
mod product_service;
mod source_service;
mod wishlist_service;

pub use self::error::{Error, Result};
pub use self::product_service::ProductService;
pub use self::source_service::SourceService;
pub use self::wishlist_service::WishlistService;

pub use self::impl_simple::{get_product_service, get_wishlist_service};
