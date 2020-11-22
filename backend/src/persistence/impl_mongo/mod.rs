mod client;
mod dao;
mod mongo_product_dao;
mod mongo_source_dao;
mod mongo_wishlist_dao;

use self::client::get_mongo_client;
pub use self::dao::{get_product_dao, get_source_dao, get_wishlist_dao};
use self::mongo_product_dao::MongoProductDao;
use self::mongo_source_dao::MongoSourceDao;
use self::mongo_wishlist_dao::MongoWishlistDao;
