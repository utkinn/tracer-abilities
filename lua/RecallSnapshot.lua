RecallSnapshot = {}

local destinationTime

function RecallSnapshot:new()
  newObj = {sound = 'woof'}
  self.__index = self
  return setmetatable(newObj, self)
  
  destinationTime = os.time()
end

-- function Dog:makeSound()
  -- print('I say ' .. self.sound)
-- end