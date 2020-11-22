use std;
use thiserror::Error;
use warp;

use crate::model::ErrorMessage;
use crate::reject::get_internal_error_message;
use crate::service::Error as ServiceError;

pub type Result<T> = std::result::Result<T, Error>;

#[derive(Error, Debug)]
pub enum Error {
    #[error("{source}")]
    Service {
        #[from]
        source: ServiceError,
    },

    #[error("Service could not be initialized: {0}")]
    ServiceUninitialized(String),
    #[error("Poisoned mutex @ {0}")]
    PoisonedMutex(String),
}

impl warp::reject::Reject for Error {}

impl Into<ErrorMessage> for &Error {
    fn into(self) -> ErrorMessage {
        match self {
            Error::Service { source, .. } => source.into(),
            _ => get_internal_error_message(),
        }
    }
}
