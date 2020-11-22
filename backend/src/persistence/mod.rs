mod error;
mod impl_mongo;
mod product_dao;
mod source_dao;
mod wishlist_dao;

pub use self::error::{Error, Result};
pub use self::product_dao::ProductDao;
pub use self::source_dao::SourceDao;
pub use self::wishlist_dao::WishlistDao;

pub use self::impl_mongo::{get_product_dao, get_source_dao, get_wishlist_dao};
