require 'philosopher'

maxFrameRate = 12 --12 frames per second
totalFrames = 0
wantsPrint = false

NUM_PHILOSOPHERS = 5
NUM_FORKS = NUM_PHILOSOPHERS

function love.load()
end

function love.draw()
   if wantsPrint then
      -- print the status of the threads
   end
end

function love.update(dt)
   totalFrames = totalFrames + dt
   
   if totalFrames >= maxFrameRate then
      totalFrames = 0
      
      -- update the graphics, update philosopher decisions
   end
end