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
m:on("connect", function() print("mqtt connected") subscribeTopics(m) end)

-- Subscribe to topics and confirm in terminal
function subscribeTopics(client)
    client:subscribe(switchTopic,   0, subscribed(switchTopic))
    client:subscribe(statusTopic, 0, subscribed(statusTopic))
end

-- Function to print subscription confirmation
function subscribed(topic)
    print("subscribed to " .. topic)
end

-- Callback to handle messages
m:on("message", function(client, topic, data) handleMessage(client, topic, data) end)

-- Function to handle messages
function handleMessage(client, topic, data)
    printMessage(client, topic, data)
    if topic == switchTopic then
        setStatus(data)
        verboseStatus(getStatus())
        switchLed(getStatus())
        publishStatus(getStatus())
    end
end

-- Print messages to terminal to aid debugging
function printMessage(client1, topic1, data1)
--    print(client1)
    print(topic1 .. ": " .. data1)
end

-- status setter
function setStatus(data)
    status = data
end

-- status getter
function getStatus()
    return status
end

-- Publish status so clients can display state
function publishStatus(status3)
    if status3 == "1" then
        m:publish(statusTopic, "On", 1, 1)
    elseif status3 == "0" then
        m:publish(statusTopic, "Off", 1, 1)
    else
        m:publish(statusTopic, status3, 1, 1)
    end
end

-- Verbose status to aid debugging
function verboseStatus(status1)
    if status1 == "1" then
        print("I am on")
    elseif status1 == "0" then
        print("I am off")
    else
        print("I am not sure what I am!")
    end
end

-- Handle LED based on status
function switchLed(status2)
    if status2 == "1" then
        gpio.write(ledPin, gpio.LOW)
    elseif status2 == "0" then
        gpio.write(ledPin, gpio.HIGH)
    else
        print("An LED cannot handle this status")
    end
end

-- Connect to broker
m:connect(mqtt_address, 1883, 0, 1) 