use mongodb::sync::Client;
use std::env;
use std::sync::Arc;

lazy_static! {
    static ref MONGO_CLIENT: Option<Arc<Client>> = {
        let mongo_url = match env::var("DATABASE_URL") {
            Ok(url) => url,
            Err(_) => {
                error!("MongoDB DATABASE_URL not set");
                return None;
            }
        };
        match Client::with_uri_str(&mongo_url) {
            Ok(c) => Some(Arc::new(c)),
            Err(e) => {
                error!("{}", e);
                None
            }
        }
    };
}

pub fn get_mongo_client() -> Option<Arc<Client>> {
    (*MONGO_CLIENT).clone()
}
