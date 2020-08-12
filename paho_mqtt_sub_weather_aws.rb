require 'paho-mqtt'

### Create a simple client with default attributes
client = PahoMqtt::Client.new

### Register a callback on message event to display messages
message_counter = 0
client.on_message do |message|
  puts "Message recieved on topic: #{message.topic}\n>>> #{message.payload}"
  message_counter += 1
end

### Register a callback on suback to assert the subcription
waiting_suback = true
client.on_suback do
  waiting_suback = false
  puts "Subscribed"
end

### Connect to the eclipse test server on port 1883 (Unencrypted mode)
#client.connect('localhost', 1883)

### Set the encryption mode to True
client.ssl = true
### Configure the user SSL key and the certificate
#client.config_ssl_context('certs\certificate.pem.crt', 'certs\private.pem.key','certs\root-CA.crt')
client.config_ssl_context('certs\certificate.pem.crt', 'certs\private.pem.key','certs\root-CA.crt')

client.connect('a13j48742gk2po-ats.iot.us-east-2.amazonaws.com', 8883)


### Subscribe to a topic
client.subscribe(['/weather/#', 0])

### Waiting for the suback answer and excute the previously set on_suback callback
while waiting_suback do
  sleep 0.001
end

# Listen forever
while 1 do
  sleep 0.001
end

### Calling an explicit disconnect (Should never get here...)
client.disconnect