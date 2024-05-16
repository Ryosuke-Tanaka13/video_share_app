carrierWave.configure do |config|
  config.storage = :fog
  config.fog_provider = 'fog/google'
  config.fog_credentiald = 
  {
    provider: 'Google',
    google_storage_access_key_id: '',
    google_storage_secret_access_key: ''
  }
  config.fog_directory = "youre_bucket_name"
end