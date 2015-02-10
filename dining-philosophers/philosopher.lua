require 'middleclass'
require 'middleclass-commons'
require 'constants'
require 'additionalFunctions'
local anim8 = require 'anim8'

Philosopher = class('Philosopher')

function Philosopher:initialize(id, name, state, useImage)
   self.id = id
   self.name = name
   self.state = state
   
   self.leftFork = false
   self.rightFork = false
   
   if self.state == STATES[3] then
      self.leftFork = true
      self.rightFork = true
   end
   
   self.overallTime = 0
   self.useImage = false
   
   if useImage then
      self.useImage = true
      Philosopher.static.maleCharacterImage = love.graphics.newImage("art/MalePhilosopher_Thinking.png")
      Philosopher.static.femaleCharacterImage = nil

      if mod(id, 2) == 1 then
         -- it's a boy... like, there's always gonna be more male philosophers than female........ Do I wanna be realistic or push the feminist agenda. Difficult question
         self.image = Philosopher.static.maleCharacterImage
      else
         -- it's a girl
         self.image = Philosopher.static.maleCharacterImage --female
      end
      
      self.grid = anim8.newGrid(PIXEL_SIZE, PIXEL_SIZE, self.image:getWidth(), self.image:getHeight())
      self.animations = {
         anim8.newAnimation(self.grid('1-3',1, 5,1, '1-2',1, '4-5',1), MAX_FRAME_RATE)
      }
      
      self.x = 10
      self.y = 10
   end
end

function Philosopher:getData()
   return {
      self.id,
      self.name,
      self.state,
      self.leftFork,
      self.rightFork
   }
end

function Philosopher:setData(table)
   if self.state ~= table[3] then
      self.overallTime = 0
   end
   
   self.id = table[1]
   self.name = table[2]
   self.state = table[3]
   self.leftFork = table[4]
   self.rightFork = table[5]
end

function Philosopher:hasFirstFork()
   if mod(self.id, 2) == 1 then
      return self.leftFork
   else
      return self.rightFork
   end
end

function Philosopher:setFirstFork(newState)
   if mod(self.id, 2) == 1 then
      self.leftFork = newState
   else
      self.rightFork = newState
   end
end

function Philosopher:setSecondFork(newState)
   if mod(self.id, 2) == 1 then
      self.rightFork = newState
   else
      self.leftFork = newState
   end
end

function Philosopher:hasSecondFork()
   if mod(self.id, 2) == 1 then
      return self.rightFork
   else
      return self.leftFork
   end
end

function Philosopher:getFirstFork()
   return self.id
end

function Philosopher:getSecondFork()
   return self.id + 1 > NUM_FORKS and 1 or self.id + 1
end

function Philosopher:update(dt)
   self.overallTime = self.overallTime + dt
   self.animations[1]:update(dt)
   
   if (self.overallTime >= MAX_FRAME_RATE) then
      self.overallTime = 0
      
      -- switch to the next frame of the animation
   end
end

function Philosopher:draw()
   if self.useImage then
      self.animations[1]:draw(self.image, self.x, self.y)
   end
end

function Philosopher:__tostring()
   return "Philosopher " .. self.name .. " is " .. self.state
end