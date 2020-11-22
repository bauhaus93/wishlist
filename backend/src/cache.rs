use std::collections::{btree_map::Entry, BTreeMap};
use std::sync::{Arc, Mutex};
use std::time::{Duration, Instant};

use crate::controller::Error as ControllerError;

pub struct Cache<T: Clone> {
    element_map: Arc<Mutex<BTreeMap<String, Element<T>>>>,
    ttl: Duration,
}

struct Element<T: Clone> {
    resource: T,
    timestamp: Instant,
}

impl<T: Clone> Cache<T> {
    pub fn with_ttl(ttl_seconds: u64) -> Self {
        Self {
            element_map: Arc::new(Mutex::new(BTreeMap::new())),
            ttl: Duration::from_millis(ttl_seconds * 1000),
        }
    }

    pub fn get<F: FnOnce() -> Result<T, ControllerError>>(
        &self,
        key: &str,
        fallback: F,
    ) -> Result<T, ControllerError> {
        let guard = self
            .element_map
            .lock()
            .map_err(ControllerError::PoisonedMutex("Cache::get".to_string()))?;

        match (*guard).entry(key.to_string()) {
            Entry::Vacant(e) => {
                debug!("Cache miss for {}, load from fallback", key);
                let resource = fallback()?;
                e.insert(Element::new(resource.clone()));
                Ok(resource)
            }
            Entry::Occupied(mut e) => {
                debug!("Cache hit for {}", key);
                if e.get().is_stale(self.ttl) {
                    debug!("Cache entry is stale, reload from fallback");
                    let resource = fallback()?;
                    e.insert(Element::new(resource));
                }
                Ok(e.get().get_inner())
            }
        }
    }
}

impl<T: Clone> Element<T> {
    pub fn new(resource: T) -> Self {
        Self {
            resource: resource,
            timestamp: Instant::now(),
        }
    }

    pub fn get_inner(&self) -> T {
        self.resource.clone()
    }

    pub fn is_stale(&self, ttl: Duration) -> bool {
        self.timestamp.elapsed() > ttl
    }
}
