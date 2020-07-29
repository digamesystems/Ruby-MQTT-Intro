require 'paho-mqtt'
require 'net/http' # +++ 
require 'json'     # +++


# New functions for current_weather
def current_weather(city)

    api_key = "b46bd6614df2b680b4c727547c86d47d"
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
  puts "Message Acknowledged by Broker"
end

### Connect to the test broker on port 1883 (Unencrypted mode)
client.connect('localhost', 1883)


### New weather publications
cities = ["San Jose","Tucson","Phoenix","Atlanta"]

cities.each do |city|
    report                = current_weather(city)
    current_temperature_k = k_to_f(report["main"]["temp"])

    waiting_puback=true
    client.publish("/weather/#{city}", "#{current_temperature_k} ", false, 1) 
    while waiting_puback do 
        sleep(0.001)
    end
    
end


### Call an explicit disconnect
client.disconnect




