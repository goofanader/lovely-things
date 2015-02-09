isRunning = true

while isRunning do
   love.thread.getChannel("lock"):supply(-1)
   if love.thread.getChannel("killThreads"):peek() then
      break
   end
   love.thread.getChannel("lock"):demand()
   if love.thread.getChannel("killThreads"):peek() then
      isRunning = not isRunning
   end
end