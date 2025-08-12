Geocoder.configure(
  lookup: :nominatim,
  use_https: true,
  timeout: 5,
  http_headers: {
    "User-Agent" => "lelocal (nicolas.goarant@hotmail.fr)"
  }
)
