use std;
use thiserror::Error;

use crate::model::ErrorMessage;
use crate::persistence::Error as PersistenceError;
use crate::reject::get_internal_error_message;

pub type Result<T> = std::result::Result<T, Error>;

#[derive(Error, Debug)]
pub enum Error {
    #[error("{source}")]
    Persistence {
        #[from]
        source: PersistenceError,
    },
    #[error("DAO could not be initialized: {0}")]
    DaoUninitialized(String),
    #[error("Service: Field not loaded: '{0}' is missing '{1}'")]
    FieldNotLoaded(&'static str, &'static str),
}

impl Into<ErrorMessage> for &Error {
    fn into(self) -> ErrorMessage {
        match self {
            Error::Persistence { source, .. } => source.into(),
            _ => get_internal_error_message(),
        }
    }
}
