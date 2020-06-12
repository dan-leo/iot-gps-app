# ca882440-ac37-11ea-a0ad-19f7b95d9654
# FBprmkoajCHYwRNmSsSv
# -X POST

export ACCESS_TOKEN=FBprmkoajCHYwRNmSsSv

curl -v -d telemetry-data-as-object.json http://demo.thingsboard.io:80/api/v1/$ACCESS_TOKEN/telemetry --header "Content-Type:application/json"
# curl -v -d "{\"temperature\": 25}" https://demo.thingsboard.io/api/v1/$ACCESS_TOKEN/telemetry --header "Content-Type:application/json"
# curl -v -d "{\"lat\": 37.2807406, \"long\": -122.14869}" https://demo.thingsboard.io/api/v1/$ACCESS_TOKEN/telemetry --header "Content-Type:application/json"