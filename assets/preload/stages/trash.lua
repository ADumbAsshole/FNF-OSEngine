function onCreate()
	-- background shit
	makeLuaSprite('dumpster', 'dumpster', -330, -150)
	addLuaSprite('dumpster', false)
	
	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end