while true do
   love.thread.getChannel("lock"):supply(-1)
   love.thread.getChannel("lock"):demand()
end