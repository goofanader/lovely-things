--require 'philosopher'
require 'constants'

totalTime = 0
wantsPrint = false

philosophers = {}

lockThread = love.thread.newThread("lock.lua")
lock = love.thread.getChannel("lock")
forkThread = love.thread.newThread("forkThread.lua")
forkChannel = love.thread.getChannel("forks")
forkLock = love.thread.getChannel("forkLock")
forkThread:start()
lockThread:start()

function love.load()
   -- need to communicate between the threads 
   -- wait a second. ...Is this even a concurrent thing? Wait yeah it is, cuz I need to randomly pick who eats and who doesnt... irght??????
   
   -- Alanna?
   
   for i = 1, NUM_PHILOSOPHERS do
      philosophers[i] = {}
      philosophers[i]["thread"] = love.thread.newThread("philosopherThread.lua")
      --philosophers[i]["philosopher"] = Philosopher:new(i, 'A' + i, STATES[2])
      philosophers[i]["thread"]:start(i, string.char(string.byte('A') + i - 1), STATES[2])
      philosophers[i]["channel"] = love.thread.getChannel("philosopher" .. i)
   end
   
   i = {}
   forkStatus = forkChannel:peek()
end

function love.draw()
   local yPos = 10
   local xPos = 10
   
   if forkStatus then
      for num, v in ipairs(forkStatus) do
         love.graphics.print("fork " .. num .. ": " .. tostring(v), xPos, yPos)
         --table.remove(i, num)
         yPos = yPos + 10
      end
   end
   
   xPos = 125
   for i = 1, NUM_PHILOSOPHERS do
      yPos = 10
      local currPhilosopher = philosophers[i]["channel"]:peek()
      
      if currPhilosopher then
         love.graphics.print("Philosopher " .. currPhilosopher[2], xPos, yPos)
         
         for num, value in ipairs(currPhilosopher) do
            yPos = yPos + 10
            love.graphics.print(tostring(value), xPos, yPos)
         end
         
         xPos = 125 + xPos
      end
   end
end

function love.update(dt)
   totalTime = totalTime + dt
   
   --print(tostring(thread:isRunning()))
   --print(thread:getError())
   
   if totalTime >= MAX_FRAME_RATE then
      totalTime = 0
      
      -- update the graphics, update philosopher decisions
      --isForkAvailable[1] = not isForkAvailable[1]
      --forkChannel:push(isForkAvailable[1])
   --love.thread.getChannel("killThreads"):push("kill")
   
      
   end
   
   --[[while channel:peek() do
      v = channel:pop()
      if v then
         table.insert(i, v)
         --print("yo")
      end
   end]]
   forkStatus = forkChannel:peek()
end

function love.threaderror(thread, errorstr)
   print("=====\nThread error!\n" .. errorstr .. "\n=====")
end

function love.keypressed(key, isrepeat)
   if key == 'q' or key == 'escape' then
      print("exiting")
      love.thread.getChannel("killThreads"):push("kill")
      love.event.quit()
   end
end

function love.quit()
   for i = 1, NUM_PHILOSOPHERS do
      if philosophers[i]["thread"]:isRunning() then
         forkLock:push({-1})
         lock:push(1)
         lock:pop()
         --philosophers[i]["thread"]:wait()
      end
   end
   
   if forkThread:isRunning() then
      forkLock:push({-1})
   end
   
   if lockThread:isRunning() then
      lock:push(1)
      lock:pop()
   end
   
   print("we're done, goodbye!")
   return false
end