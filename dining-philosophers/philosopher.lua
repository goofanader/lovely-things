require 'middleclass'
require 'middleclass-commons'
require 'constants'
require 'additionalFunctions'

Philosopher = class('Philosopher')

function Philosopher:initialize(id, name, state)
   self.id = id
   self.name = name
   self.state = state
   
   self.leftFork = false
   self.rightFork = false
   
   if self.state == STATES[3] then
      self.leftFork = true
      self.rightFork = true
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

function Philosopher:__tostring()
   return "Philosopher " .. self.name .. " is " .. self.state
end