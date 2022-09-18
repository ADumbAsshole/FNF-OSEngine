function onCreate()
	-- background shit
	makeLuaSprite('pickaxe', 'Pickaxe', -330, -150)
	addGlitchEffect('pickaxe', 2, 2)
	addLuaSprite('pickaxe', false)
	
	close(true); --For performance reasons, close this script once the stage is fully loaded, as this script won't be used anymore after loading the stage
end