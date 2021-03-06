-- Handy script to delete last model used
require 'functions'

if file_exists(LAST_MODEL_FILE) then
   f = io.open(LAST_MODEL_FILE,'r')
   path = f:read()
   modelString = f:read()
   print('MODEL USED : '..modelString)
   f:close()
else
   error(LAST_MODEL_FILE.." should exist")
end

if file_exists(path) then
   os.execute("rm -r "..path)
else
   error(path.." should exist")
end

--os.execute("rm -r "..path)
print("Deleted last model successfully ("..path..")")
