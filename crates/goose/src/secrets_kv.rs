// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (c) 2026 Lucas Gallindo

use std::collections::HashMap;
use std::sync::{Arc, RwLock};

#[derive(Clone)]
pub struct SecretsKvStore {
    store: Arc<RwLock<HashMap<String, String>>>,
}

impl Default for SecretsKvStore {
    fn default() -> Self {
        Self::new()
    }
}

impl SecretsKvStore {
    pub fn new() -> Self {
        Self {
            store: Arc::new(RwLock::new(HashMap::new())),
        }
    }
    
    pub fn save_secret(&self, key: &str, value: &str) -> Result<(), &'static str> {
        let mut map = self.store.write().map_err(|_| "Failed to lock store for writing")?;
        map.insert(key.to_string(), value.to_string());
        Ok(())
    }
    
    pub fn get_secret(&self, key: &str) -> Option<String> {
        let map = self.store.read().ok()?;
        map.get(key).cloned()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_secret_save_and_retrieve() {
        let store = SecretsKvStore::new();
        // Save
        assert!(store.save_secret("TEST_KEY", "super_secret_value").is_ok());
        // Retrieve
        let val = store.get_secret("TEST_KEY").expect("Secret should exist");
        assert_eq!(val, "super_secret_value");
        
        // Missing key
        assert!(store.get_secret("MISSING_KEY").is_none());
    }
}
