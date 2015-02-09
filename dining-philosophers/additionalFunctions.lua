function mod(a, b)
   --a % b == a - math.floor(a / b) * b
   return a - math.floor(a / b) * b
end

function sleep(n)
   t0 = os.clock()
   
   while os.clock() - t0 <= n do
   end
end

   