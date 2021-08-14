require 'sequel'

database = ENV['postgres_database'] || 'postgres'
host = ENV['postgres_host'] || 'localhost'
port = ENV['postgres_port'] || 5432
user = ENV['postgres_user'] || 'rating_ui'
password = ENV['postgres_password'] || 'rating_ui'

DB = Sequel.postgres(database: database, host: host, port: port, user: user, password: password)
