extern crate chrono;
extern crate env_logger;
#[macro_use]
extern crate log;
extern crate dotenv;

extern crate wishlist;

use env_logger::{fmt::Formatter, Builder};
use log::Record;
use std::env;
use std::io::Write;
use std::net::SocketAddr;

#[tokio::main]
async fn main() {
    init_logger();

    match dotenv::dotenv() {
        Ok(_) => {
            info!("Loaded dotenv!");
        }
        Err(e) => {
            warn!("Could not load dotenv: {}", e);
        }
    }

    let server_addr = match env::var("BACKEND_ADDRESS") {
        Ok(server_addr) => server_addr,
        Err(_) => {
            info!("No BACKEND_ADDRESS supplied, using default");
            String::from("0.0.0.0:8080")
        }
    };

    let socket_addr: SocketAddr = match server_addr.parse() {
        Ok(a) => a,
        Err(e) => {
            error!("Could not parse server addr '{}': {}", server_addr, e);
            return;
        }
    };

    info!("Server address: {}", server_addr);

    let routes = match wishlist::create_routes().await {
        Ok(r) => r,
        Err(e) => {
            error!("Could not create routes: {}", e);
            return;
        }
    };
    info!("Created server routes");

    warp::serve(routes).run(socket_addr).await;
}

fn init_logger() {
    let format = |buf: &mut Formatter, record: &Record| {
        let time = chrono::Local::now();
        writeln!(
            buf,
            "[{} {:-5}] {}",
            time.format("%Y-%m-%d %H:%M:%S"),
            record.level(),
            record.args()
        )
    };
    Builder::from_default_env().format(format).init();
}
