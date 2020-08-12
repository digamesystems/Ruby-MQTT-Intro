require 'paho-mqtt'
require 'net/http' # +++ 
require 'json'     # +++


# New functions for current_weather
def current_weather(city)

    f = File.open('api_key.txt') # A single line file containing your API Key
                                 # -- You'll have to make your own.
    api_key = f.read
    f.close

    uri = URI("https://api.openweathermap.org/data/2.5/weather?q=#{city}&appid=#{api_key}")

    Net::HTTP.start(uri.host, uri.port,:use_ssl => uri.scheme == 'https') do |http|
      request = Net::HTTP::Get.new uri
      response = http.request request # Net::HTTPResponse object
      retval = JSON.parse(response.body)
      return retval
    end

end

# Kelvin to Farenheit conversion
def k_to_f(k_temp)
    f_temp = 32 + (k_temp.to_f - 273.15)*9/5
    return f_temp.round(2) 
end

##################################################

### Create a simple client with default attributes
client = PahoMqtt::Client.new

### Register a callback for puback event when the Broker acknowledges a publication
waiting_puback = true # A flag so we can wait for the acknowledgement
client.on_puback do
  waiting_puback = false
  puts "Message acknowledged by broker."
end

### Connect to the test broker on port 8883 (Secure mode)

# Original, Insecure Mode.
#client.connect('localhost', 1883)

### Set the encryption mode to True
client.ssl = true
### Configure the user SSL key and the certificate
client.config_ssl_context('certs\certificate.pem.crt', 'certs\private.pem.key','certs\AmazonRootCA1.pem')

# Our AWS IoT Core 'Endpoint' 
client.connect('a13j48742gk2po-ats.iot.us-east-2.amazonaws.com', 8883)


### New weather publications
cities = ["San Jose","Atlanta","Tucson","Phoenix"]

cities.each do |city|
    report                = current_weather(city)
    current_temperature_k = k_to_f(report["main"]["temp"])

    waiting_puback=true
    client.publish("/weather/#{city}", "#{current_temperature_k} ", false, 1)
    #client.publish("/weather/#{city}", "#{report} ", false, 1) 
    while waiting_puback do 
        sleep(0.001)
    end
    
end



### Call an explicit disconnect
client.disconnect




