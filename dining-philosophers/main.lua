require 'philosopher'
require 'constants'
local anim8 = require 'anim8'

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
      philosophers[i]["philosopher"] = Philosopher:new(i, string.char(string.byte('A') + i - 1), STATES[2], true)
      philosophers[i]["thread"]:start(i, string.char(string.byte('A') + i - 1), STATES[2])
      philosophers[i]["channel"] = love.thread.getChannel("philosopher" .. i)
   end
   
   -- load images
   tableImage = love.graphics.newImage("art/Table.png")
   bowlImage = love.graphics.newImage("art/Bowl.png")
   forksImage = love.graphics.newImage("art/Forks.png")
   forksGrid = anim8.newGrid(8, 8, forksImage:getWidth(), forksImage:getHeight())
   forkPositions = {}
   local forkPositionNames = {
      {
         "up",
         "up-right",
         "right",
         "down-right"
      },
      {
         "down",
         "down-left",
         "left",
         "up-left"
      }
   }   
   
   for i = 1, 2 do
      for j = 1, 4 do
         forkPositions[forkPositionNames[i][j]] = anim8.newAnimation(forksGrid(j, i), 1)
      end
   end
   
   forkStatus = forkChannel:peek()
end

function love.draw()
   --[[local yPos = 10
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
      --local currPhilosopher = philosophers[i]["channel"]:peek()
      local currPhilosopher = philosophers[i]["philosopher"]:getData()
      
      --if currPhilosopher then
         love.graphics.print("Philosopher " .. currPhilosopher[2], xPos, yPos)
         
         for num, value in ipairs(currPhilosopher) do
            yPos = yPos + 10
            love.graphics.print(tostring(value), xPos, yPos)
         end
         
         xPos = 125 + xPos
         
         philosophers[i]["philosopher"]:draw()
      --end
   end]]
   local philosophersToPrint = NUM_PHILOSOPHERS
   local forksToPrint = NUM_FORKS
   
   for i = 1, math.ceil(philosophersToPrint / 2) do
      local currPhilosopher = philosophers[i]["philosopher"]
      currPhilosopher:draw()
   end

   -- print the table
   love.graphics.draw(tableImage, PIXEL_SIZE, PIXEL_SIZE)
   
   for i = 1, math.ceil(forksToPrint / 2) do
   end

   -- print the bowl
   love.graphics.draw(bowlImage, PIXEL_SIZE, PIXEL_SIZE)
   
   forksToPrint = forksToPrint - math.ceil(forksToPrint / 2)
   philosophersToPrint = philosophersToPrint - math.ceil(philosophersToPrint / 2)
   
   for i = philosophersToPrint, NUM_PHILOSOPHERS do
      local currPhilosopher = philosophers[i]["philosopher"]
      --currPhilosopher:draw()
   end
   
   for i = forksToPrint, NUM_FORKS do
   end
end

function love.update(dt)
   forkStatus = forkChannel:peek()
   
   for i = 1, NUM_PHILOSOPHERS do
      local currPhilosopher = philosophers[i]["channel"]:peek()
      
      if currPhilosopher then
         philosophers[i]["philosopher"]:setData(currPhilosopher)
      end
      
      philosophers[i]["philosopher"]:update(dt)
   end
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