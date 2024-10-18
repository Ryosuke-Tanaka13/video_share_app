 CarrierWave.configure do |config|
  config.fog_provider = 'fog/google'
  config.fog_credentials = {
    provider: 'Google',
    google_cloud_storage_access_key_id: 'd403d797d10590b22b25c8772ad4d6143c9c5950',
    google_storage_secret_access_key: 'video-share-app-360@learned-fusion-389707.iam.gserviceaccount.com'
  }
  config.fog_directory = 'movie_app_bucket'
end