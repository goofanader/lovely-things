require 'philosopher'
require 'constants'
require 'additionalFunctions'

--require 'main'
--c = love.thread.getChannel("test")
forkChannel = love.thread.getChannel("forks")
forkLock = love.thread.getChannel("forkLock")
lock = love.thread.getChannel("lock")
isForkAvailable = {}
isRunning = true

math.randomseed(os.time())
math.random()
math.random()

--c:push("hi")
philosopher = Philosopher:new(...)
philosopherChannel = love.thread.getChannel("philosopher" .. philosopher.id)

switch = {
   -- THINKING --
   [STATES[1]] = function()
      sleep(math.random(0, MAX_SECONDS))
      
      lock:demand()
      philosopher.state = STATES[2]
      
      philosopherChannel:clear()
      philosopherChannel:push(philosopher:getData())
      
      --print(philosopher)
      lock:supply(1)
   end,
   
   -- HUNGRY --
   [STATES[2]] = function()
      lock:demand()
      
      local noUpdate = false
      local forkStatus = forkChannel:peek()
      
      if not philosopher:hasFirstFork() and not forkStatus[philosopher:getFirstFork()] then
         philosopher:setFirstFork(true)
         forkLock:supply({philosopher:getFirstFork(), philosopher:hasFirstFork()})
      elseif philosopher:hasFirstFork() and not philosopher:hasSecondFork() and not forkStatus[philosopher:getSecondFork()] then
         philosopher:setSecondFork(true)
         forkLock:supply({philosopher:getSecondFork(), philosopher:hasSecondFork()})
      elseif philosopher:hasFirstFork() and philosopher:hasSecondFork() then
         philosopher.state = STATES[3]
      else
         noUpdate = true
      end
      
      if not noUpdate then
         philosopherChannel:clear()
         philosopherChannel:push(philosopher:getData())
         --print(philosopher)
      end
      
      lock:supply(1)
   end,
   
   -- EATING --
   [STATES[3]] = function()
      sleep(math.random(0, MAX_SECONDS))
      
      lock:demand()
      philosopher.state = STATES[4]
      
      philosopherChannel:clear()
      philosopherChannel:push(philosopher:getData())
      
      --print(philosopher)
      lock:supply(1)
   end,
   
   -- FULL --
   [STATES[4]] = function()
      lock:demand()
      local noUpdate = false
      local forkStatus = forkChannel:peek()
      
      if philosopher:hasFirstFork() then
         philosopher:setFirstFork(false)
         forkLock:supply({philosopher:getFirstFork(), philosopher:hasFirstFork()})
      elseif philosopher:hasSecondFork() then
         philosopher:setSecondFork(false)
         forkLock:supply({philosopher:getSecondFork(), philosopher:hasSecondFork()})
      elseif not philosopher:hasFirstFork() and not philosopher:hasSecondFork() then
         philosopher.state = STATES[1]
      else
         noUpdate = true
      end
      
      if not noUpdate then
         philosopherChannel:clear()
         philosopherChannel:push(philosopher:getData())
         --print(philosopher)
      end
      
      lock:supply(1)
   end
}

while isRunning do
   if love.thread.getChannel("killThreads"):peek() then
      --love.thread.getChannel("killThreads"):pop()
      isRunning = not isRunning
      --print("wah")
   end
   
   switch[philosopher.state]()
end

--print("wiggity waggity")