# frozen_string_literal: true

require 'bundler/setup'

require 'sinatra'
require 'sinatra/reloader' if development?
require 'kafka'

$events = []

def initialize_kafka
  $consumer = Kafka.new(seed_brokers: [ENV['KAFKA_SERVICE']], logger: Logger.new($stdout))

  start_consumer
end

get '/api/v1/events' do
  $events.to_json
end

get '/api/v1/consumption' do
  $events
    .group_by { |item| item[:product] }
    .transform_values { |v| v.group_by { |item| item[:event] } }
    .each_with_object({}) do |(k, v), h|
    h[k] = v.transform_values { |value| value.count }
  end.to_json
end

def start_consumer
  Thread.new do
    $consumer.each_message(topic: ENV['KAFKA_TOPIC_CONSUMER']) do |message|
      parsed_message = JSON.parse(message.value)

      puts '.' * 90
      puts message.value.inspect
      puts '.' * 90
      $events << {
        product: parsed_message['product'],
        event: parsed_message['event'],
        received_at: Time.now.iso8601
      }
    end
  rescue Exception => e
    puts 'CONSUMER ERROR'
    puts "#{e}\n#{e.backtrace.join("\n")}"
    exit(1)
  end
end
