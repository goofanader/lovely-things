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

isDebugging = false

function love.load()
   if isDebugging then
      --allow ZeroBrane Studio to debug from within the IDE
      if arg[#arg] == "-debug" then
         require("mobdebug").start()
      end
   end

   -- need to communicate between the threads 
   -- wait a second. ...Is this even a concurrent thing? Wait yeah it is, cuz I need to randomly pick who eats and who doesnt... irght??????
   
   -- Alanna?
   love.graphics.setDefaultFilter("nearest")
   
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
   --forksImage = love.graphics.newImage("art/Forks.png")
   
   
   forkStatus = forkChannel:peek()
end

function choosePivot(arr, lo, hi)
   local mid = math.floor((hi + lo) / 2)
   local pivotTable = {
      arr[lo].y,
      arr[mid].y,
      arr[hi].y
   }
   
   table.sort(pivotTable)
   
   if arr[lo].y == pivotTable[2] then
      return lo
   elseif arr[mid].y == pivotTable[2] then
      return mid
   else
      return hi
   end
end

function partition(arr, lo, hi)
   local pivotIndex = choosePivot(arr, lo, hi)
   local pivotValue = arr[pivotIndex].y
   
   --swap arr[pivotIndex] and arr[hi]
   local temp = arr[pivotIndex]
   arr[pivotIndex] = arr[hi]
   arr[hi] = temp
   
   local storeIndex = lo
   
   for i = lo, hi - 1 do
      if arr[i].y <= pivotValue then
         --swap arr[i] and arr[storeIndex]
         temp = arr[i]
         arr[i] = arr[storeIndex]
         arr[storeIndex] = temp
         
         storeIndex = storeIndex + 1
      end
   end
   
   --swap arr[storeIndex] and arr[hi]
   temp = arr[storeIndex]
   arr[storeIndex] = arr[hi]
   arr[hi] = temp
   
   return storeIndex
end

function quicksort(arr, lo, hi)
   if lo < hi then
      local p = partition(arr, lo, hi)
      quicksort(arr, lo, p - 1)
      quicksort(arr, p + 1, hi)
   end
   
   
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
   
   --organize philosophers by self.x
   local philosopherPrint = {}
   for i = 1, NUM_PHILOSOPHERS do
      philosopherPrint[i] = philosophers[i]["philosopher"]
   end
   
   quicksort(philosopherPrint, 1, NUM_PHILOSOPHERS)
   
   local philosophersToPrint = math.floor(NUM_PHILOSOPHERS / 2)
   local forksToPrint = math.floor(NUM_FORKS / 2)
   
   for i = 1, philosophersToPrint do
      local currPhilosopher = philosopherPrint[i]
      currPhilosopher:draw()
   end

   -- print the table
   love.graphics.draw(tableImage, PIXEL_SIZE, PIXEL_SIZE)
   
   for i = 1, math.floor(forksToPrint / 2) do
   end

   -- print the bowl
   love.graphics.draw(bowlImage, PIXEL_SIZE, PIXEL_SIZE)
   
   forksToPrint = NUM_FORKS - math.floor(forksToPrint / 2)
   philosophersToPrint = NUM_PHILOSOPHERS - math.floor(NUM_PHILOSOPHERS / 2)
   
   for i = philosophersToPrint, NUM_PHILOSOPHERS do
      local currPhilosopher = philosopherPrint[i]
      currPhilosopher:draw()
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