#[macro_use]
extern crate serde_json;

use serde_json::json;

use std::time::Duration;
use std::env;
use kafka::producer::{Producer, Record, RequiredAcks};

use actix_web::{web, App, HttpRequest, HttpServer, Responder};

async fn greet(req: HttpRequest) -> impl Responder {
    let name = req.match_info().get("name").unwrap_or("World");

    let mut producer =
        Producer::from_hosts(vec!(env::var("KAFKA_SERVICE").unwrap().to_owned()))
        .with_ack_timeout(Duration::from_secs(1))
        .with_required_acks(RequiredAcks::One)
        .create()
        .unwrap();

    let payload = json!(r#"
      {
        "product": "greetings",
        "event": "hey_access"
      }
    "#);

    producer.send(
        &Record::from_value(
            env::var("KAFKA_TOPIC_PRODUCER").unwrap().as_str(),
            payload.to_string().as_bytes()
        )
    ).unwrap();

    web::Json(format!("Hello {}!", &name))
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    HttpServer::new(|| {
        App::new()
            .route("/api/v1/hey", web::get().to(greet))
            .route("/api/v1/hey/{name}", web::get().to(greet))
    })
    .bind(("0.0.0.0", 8080))?
    .run()
    .await
}
