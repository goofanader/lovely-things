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
         [STATES[1]] = anim8.newAnimation(self.grid('1-3',1, 5,1, '1-3',1, 5,1, '1-2',1, '4-5',1), MAX_FRAME_RATE)
      }
      
      -- determine location on oval
      local theta = (2 * math.pi / NUM_PHILOSOPHERS) * (self.id - 1)
      --print("theta:"..theta)
      local a = 0--(TABLE_WIDTH / 2) + PIXEL_SIZE
      local b = 0--(TABLE_REAL_HEIGHT / 2)-- + PIXEL_SIZE
      self.x = a + ((TABLE_WIDTH / 2 + PIXEL_SIZE / 2) * math.cos(theta))
      self.y = b + ((TABLE_HEIGHT / 2 + PIXEL_SIZE / 2) * math.sin(theta))
      --print("self.x:"..self.x..", y:"..y)
      
      --[[if y < 0 and self.y > 0 then
         self.y = self.y * -1
      elseif y > 0 and self.y < 0 then
         self.y = self.y * -1
      end]]
      
      --print("b/f:("..self.x..","..self.y..")")
      self.x = self.x + PIXEL_SIZE
      self.y = self.y + PIXEL_SIZE --(self.id <= math.ceil(NUM_PHILOSOPHERS / 2) and self.y - TABLE_HEIGHT or self.y) + PIXEL_SIZE
      --print(self.id .. ": ("..self.x..","..self.y..")\n=====")
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
   self.animations[STATES[1]]:update(dt)
   
   if (self.overallTime >= MAX_FRAME_RATE) then
      self.overallTime = 0
      
      -- switch to the next frame of the animation
   end
end

function Philosopher:draw()
   if self.useImage then
      self.animations[STATES[1]]:draw(self.image, self.x + PIXEL_SIZE / 2, self.y)
      love.graphics.print(self.name, self.x + PIXEL_SIZE / 2 - 3, self.y + PIXEL_SIZE + 2)
   end
end

function Philosopher:__tostring()
   return "Philosopher " .. self.name .. " is " .. self.state
end