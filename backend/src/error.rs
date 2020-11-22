use std;
use thiserror::Error;

use crate::controller::Error as ControllerError;
use crate::model::ErrorMessage;

pub type Result<T> = std::result::Result<T, Error>;

#[derive(Error, Debug)]
pub enum Error {
    #[error("controller: {source}")]
    Controller {
        #[from]
        source: ControllerError,
    },
}

impl Into<ErrorMessage> for &Error {
    fn into(self) -> ErrorMessage {
        match self {
            Error::Controller { source, .. } => source.into(),
        }
    }
}
