use std::collections::{btree_map::Entry, BTreeMap};

use super::{Error, Result};
use crate::model::{Product, Source};

pub trait SourceService: Send + Sync {
    fn get_source_by_id(&self, id: &str) -> Result<Source>;
}
