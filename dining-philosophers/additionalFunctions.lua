function mod(a, b)
   --a % b == a - math.floor(a / b) * b
   return a - math.floor(a / b) * b
end

function sleep(n, channel)
   t0 = os.clock()
   
   while os.clock() - t0 <= n do
      if channel and channel:peek() then
         break
      end
   end
end

   