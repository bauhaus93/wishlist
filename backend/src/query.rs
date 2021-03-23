use serde::Deserialize;

#[derive(Deserialize)]
pub struct PaginationQuery {
    #[serde(default = "default_page")]
    page: u64,
    #[serde(default = "default_page_size")]
    per_page: u64,
}

#[derive(Deserialize)]
pub struct CategoryQuery {
    #[serde(default = "Option::default")]
    category: Option<String>,
}

impl PaginationQuery {
    pub fn get_offset(&self) -> u64 {
        if self.page <= 1 {
            0
        } else {
            (self.page - 1) * self.per_page
        }
    }
    pub fn get_per_page(&self) -> u64 {
        self.per_page
    }
}

impl CategoryQuery {
    pub fn get_category(&self) -> Option<&str> {
        match &self.category {
            Some(s) => Some(s.as_ref()),
            None => None,
        }
    }
}

fn default_page() -> u64 {
    1
}

fn default_page_size() -> u64 {
    10
}
