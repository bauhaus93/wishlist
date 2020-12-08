use std;
use std::sync::Arc;
use warp;
use warp::Filter;

use super::Result;
use crate::controller::{
    ProductController, SimpleProductController, SimpleWishlistController, WishlistController,
};
use crate::reject::handle_rejection;

macro_rules! reply_future {
    ($controller:ident, $method:ident) => {{
        |controller: Arc<dyn $controller>| async move {
            match controller.$method() {
                Ok(output) => Ok(warp::reply::json(&output)),
                Err(e) => Err(warp::reject::custom(e)),
            }
        }
    }};
}

pub async fn create_routes() -> Result<impl warp::Filter<Extract = impl warp::Reply> + Clone> {
    let wishlist_controller: Arc<dyn WishlistController> =
        Arc::new(SimpleWishlistController::new()?);
    let product_controller: Arc<dyn ProductController> = Arc::new(SimpleProductController::new()?);

    let wishlist_controller_filter = warp::any().map(move || wishlist_controller.clone());
    let product_controller_filter = warp::any().map(move || product_controller.clone());

    let log_filter = warp::log("api");

    let route_get_last_wishlist = warp::get()
        .and(warp::path("api"))
        .and(warp::path("wishlist"))
        .and(warp::path("last"))
        .and(warp::path::end())
        .and(wishlist_controller_filter.clone())
        .and_then(reply_future!(WishlistController, get_last_wishlist));

    let route_get_newest_products = warp::get()
        .and(warp::path("api"))
        .and(warp::path("product"))
        .and(warp::path("newest"))
        .and(product_controller_filter.clone())
        .and_then(reply_future!(ProductController, get_newest_products));

    let routes = route_get_last_wishlist
        .or(route_get_newest_products)
        .recover(handle_rejection)
        .with(log_filter);

    Ok(routes)
}
