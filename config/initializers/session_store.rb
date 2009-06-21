# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_portal_session',
  :secret      => '7338b297d0b9737cf2192e7385ac2e2da4fb35b709422d17800884734a0364b923ab903881ce297e7bc48c0a80baf982c14735ec78022e81edc1be36dbdf74e0'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
