use mongodb::sync::Client;
use std::env;

use crate::persistence::{Error, Result};

pub fn get_mongo_client() -> Result<Client> {
    let mongo_url = match env::var("DATABASE_URL") {
        Ok(url) => url,
        Err(_) => {
            return Err(Error::DatabaseURLNotSet);
        }
    };

    Ok(Client::with_uri_str(&mongo_url)?)
}
