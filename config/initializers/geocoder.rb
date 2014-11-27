Geocoder.configure(
  # geocoding service:

  # Google quota: 2,500 requests/day wthout api key, 100,000 with Google Maps API Premier
  :lookup => :google,

  # I repeat (for myself): do NOT use a key for the free version!
  # Limits are by IP. Key is only usefull for Premier account.
  # :google => {
  #   :api_key => "",
  # },

  # geocoding service request timeout, in seconds (default 3):
  :timeout => 3,

  # set default units to kilometers:
  :units => :km,

  # caching:
  #:cache => Redis.new,
  #:cache_prefix => "geocoder-",
)

