use super::Result;
use crate::model::Datapoint;

pub trait TimelineController: Send + Sync {
    fn get_timeline(&self, from_timestamp: i32, count: i32) -> Result<Vec<Datapoint>>;
}
