require 'net/http'
require 'yaml'
require 'json'

config = YAML.load_file("config.yml")

cf_url = URI(
    "https://api.cloudflare.com/client/v4/zones/"\
    "#{config['body']['zone_id']}"\
    "/dns_records/"\
    "#{config['body']['id']}")

# loop in given interval
while sleep config['interval'] do

    # get own ip address
    new_ip = Net::HTTP.get("icanhazip.com", "/")
    # remove unwanted chars
    new_ip.gsub!("\r", "")
    new_ip.gsub!("\n", "")

    # update ip address in request body
    config['body']['content'] = new_ip

    # update data
    res = Net::HTTP.start(cf_url.host, cf_url.port, use_ssl: true) do | http |
        req = Net::HTTP::Put.new(cf_url)
        req["X-Auth-Email"] = config['email']
        req["X-Auth-Key"] = config['api_key']
        req['Content-Type'] = 'application/json'

        req.body = config['body'].to_json

        http.request(req)
    end

    puts "Cloudflare IP address update response: " + res.code.to_s
end
