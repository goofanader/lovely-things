require 'constants'

isForkInUse = {}
   
for i = 1, NUM_FORKS do
   table.insert(isForkInUse, false)
end

forkChannel = love.thread.getChannel("forks")
forkLock = love.thread.getChannel("forkLock")
isRunning = true
forkChannel:push(isForkInUse)

while isRunning do
   local forkStatus = forkLock:demand()

   --[[for num, value in ipairs(forkStatus) do
      print(value)
   end]]
   --parse the forkStatus, set a fork to an updated state
   -- I'm getting an index for the fork a philosopher wants, and then whether they want it or not. ...Do we really need the last one, though
   isForkInUse[forkStatus[1]] = forkStatus[2]--not isForkInUse[forkStatus[1]]
   forkChannel:clear()
   forkChannel:push(isForkInUse)
end