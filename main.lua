

local math = require 'math'
require 'conf'

local score = 0
local t = 0

love.graphics.getDefaultFilter('nearest','nearest')
enemy = {}
enemies_controller = {}
enemies_controller.enemies = {}

enemies_controller.image = love.graphics.newImage('graphics/enemy.png')


function checkCollisions(enemies, bullets)
	explosion = love.audio.newSource('sound/explosion.mp3', 'stream')
	for i, e in ipairs(enemies) do
		for j, b in pairs(bullets) do
			if b.y <= e.y + e.height and b.x > e.x and b.x < e.x + e.width then
				love.audio.play(explosion)
				table.remove(enemies, i)
				table.remove(bullets, j)
				score = score + 1
				if score < 490 then	
					w = math.random(0, 700)
					enemies_controller:spawnEnemy(w , 0)
				end

				if score == 500 then
					enemies_controller.image = love.graphics.newImage('graphics/enemy_particle.png')
					for i=1,10 do
						enemies_controller:spawnEnemy(i*75,0)
						enemies_controller:spawnEnemy(i*75,35)
						enemies_controller:spawnEnemy(i*75,70)
						enemies_controller:spawnEnemy(i*75,105)
						enemies_controller:spawnEnemy(i*75,140)
					end
				end
			end
		end
	end
end

function love.load()
	local game_music = love.audio.newSource('sound/game_music.mp3', 'stream')
	game_music:setLooping(true)
	love.audio.play(game_music)
	game_over = false
	game_win = false
	backgroundImage = love.graphics.newImage('graphics/starfield.png')
	player = {}
	dragging = {}
	player.x = 0
	player.y = 550
	player.width = 110
	player.height = 110
	dragging.active = false
	dragging.x = 0
	dragging.y = 0
	player.bullets = {}
	player.cooldown = 20
	player.speed = 10	
	player.image = love.graphics.newImage('graphics/player.png')
	player.fire_sound = love.audio.newSource('sound/laser_gun.wav', 'stream')
	player.fire = function()
		if player.cooldown <= 0 then
			love.audio.play(player.fire_sound)
			player.cooldown = 10
			bullet = {}
			bullet.x = player.x + 11.5
			bullet.y = player.y
			table.insert(player.bullets, bullet)
		end
	end
	
	
	
	for i = 0, 10 do
		enemies_controller:spawnEnemy(i * 75 , 0)
	end
end

function enemies_controller:spawnEnemy(x, y)
	enemy = {}
	enemy.x = x
	enemy.y = y
	enemy.width = 40
 	enemy.height = 20  
	enemy.bullets = {}
	enemy.cooldown = 20
	enemy.speed = .5
	table.insert(self.enemies, enemy)
end

function enemy:fire()
	if self.cooldown <= 0 then
		self.cooldown = 20
		bullet = {}
		bullet.x = self.x + 35
		bullet.y = self.y
		table.insert(self.bullets, bullet)
	end
end

function love.update(dt)
	player.cooldown = player.cooldown - 1
	
	if love.keyboard.isDown('right') then
		if player.x < 760.5 then
			player.x = player.x + player.speed
		end
	end
	if love.keyboard.isDown('left') then
		if player.x > 0 then
			player.x = player.x - player.speed
		end
	end
	

	if dragging.active then
		if player.x > 0  or player.x < 760.5 then
			player.x = (love.mouse.getX() - dragging.x) - player.speed
		end
		if player.y > 0 or player.y < 550 then
			player.y = (love.mouse.getY() - dragging.y) - player.speed
		end
	end

	if game_over == false then		
    	player.fire()
    end

	if #enemies_controller.enemies == 0 then
		game_win = true
	end

	for _,e in pairs(enemies_controller.enemies) do
		if e.y >= love.graphics.getHeight()/2 + 215 then
			game_over = true
		end
		e.y = e.y + 1 * e.speed
	end

	for i,b in ipairs(player.bullets) do
		if b.y < -10 then
			table.remove(player.bullets, i)
		end
		b.y =b.y - 10
	end
	
	checkCollisions(enemies_controller.enemies, player.bullets)
end

function love.draw()
	love.graphics.draw(backgroundImage)
	
	font = love.graphics.newFont(14)
	love.graphics.setFont(font)
	love.graphics.print('Your score: ' ..score, 340, 583)

	if game_over then
		love.graphics.print('Game Over!', 340, 10)
		return
	elseif game_win then
		love.graphics.print('You Won!', 340, 10)
	end
	
	-- draw player
	love.graphics.setColor(255,255,255)
	love.graphics.draw(player.image, player.x, player.y)
	
	--draw enemies
	love.graphics.setColor(255,255,255)
	for _,e in pairs(enemies_controller.enemies) do
		love.graphics.draw(enemies_controller.image, e.x, e.y)
	end

	

	love.graphics.setColor(255,255,255)
	for _,v in pairs(player.bullets) do
		love.graphics.rectangle("fill", v.x, v.y, 10, 10)
	end
end

function love.mousepressed(x, y, button, istouch)
	if button == 1 and x > player.x and x < player.x + player.width and y < player.y + player.height 	then
		dragging.active = true
		dragging.x = x - player.x 
		dragging.y = y - player.y
	end
end

function love.mousereleased(x, y, button)
	if button == 1 then
		dragging.active = false
	end
end
