use serde::Deserialize;

#[derive(Deserialize)]
pub struct PaginationQuery {
    #[serde(default = "default_page")]
    page: u64,
    #[serde(default = "default_page_size")]
    per_page: u64,
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

fn default_page() -> u64 {
    1
}

fn default_page_size() -> u64 {
    10
}
