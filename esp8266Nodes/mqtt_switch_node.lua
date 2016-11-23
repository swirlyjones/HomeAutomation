mqtt_address = "192.168.1.223"
switchTopic  = "home/switch1/switch"
statusTopic  = "home/switch1/status"
status       = "0"
ledPin       = 4

gpio.mode(ledPin, gpio.OUTPUT)

-- Set up named client with 60 sec keepalive, 
-- no username/password, 
-- and a clean session each time
m = mqtt.Client("switch1", 60, "", "", 1) 
m:on("offline", function() print("mqtt offline");  end)

-- subscribe as soon as connected
m:on("connect", function() print("mqtt connected") subscribeTopics(m) end )

function subscribeTopics(client)
    client:subscribe(switchTopic,   0, subscribed(switchTopic))
    client:subscribe(statusTopic, 0, subscribed(statusTopic))
end

function subscribed(topic)
    print("subscribed to " .. topic)
end

m:on("message", function(client, topic, data) handleMessage(client, topic, data) end)

function handleMessage(client, topic, data)
    print(topic .. ": " .. data)
    if topic == switchTopic then
        status = data
        showStatus()
    end
end

function showStatus()
    if status == "1" then
        print("I am on")
        gpio.write(ledPin, gpio.LOW)
    elseif status == "0" then
        print("I am off")
        gpio.write(ledPin, gpio.HIGH)
    else
        print("I am not sure what I am!")
    end
end 

m:connect(mqtt_address, 1883, 0, 1) 