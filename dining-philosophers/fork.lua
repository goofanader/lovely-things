require 'middleclass'
require 'middleclass-commons'

Fork = class('Fork')
Fork.static.forkImage = love.graphics.newImage("art/Forks.png")

Fork.static.forksGrid = anim8.newGrid(8, 8, Fork.static.forkImage:getWidth(), Fork.static.forkImage:getHeight())

if not Fork.static.forkPositions then
   Fork.static.forkPositions = {}
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
         Fork.static.forkPositions[forkPositionNames[i][j]] = anim8.newAnimation(forksGrid(j, i), 1)
      end
   end
end

function Fork:initialize(id)
   self.id = id
   self.x = 0
   self.y = 0
end

function Fork:draw()
end

function Fork:update(dt)
end

function Fork:__tostring()
   return "fork " .. id
end