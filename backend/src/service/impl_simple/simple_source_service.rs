use crate::model::{api, db};
use crate::persistence::{MongoSourceDao, SourceDao};
use crate::service::{Error, Result, SourceService};

pub struct SimpleSourceService {
    source_dao: Box<dyn SourceDao>,
}

impl SimpleSourceService {
    pub fn new() -> Result<SimpleSourceService> {
        Ok(Self {
            source_dao: Box::new(MongoSourceDao::new()?),
        })
    }
}

impl SourceService for SimpleSourceService {
    fn get_source_by_id(&self, id: &str) -> Result<api::Source> {
        self.source_dao
            .get_source_by_id(id)
            .map_err(Error::from)
            .and_then(api::Source::from)
    }
}
