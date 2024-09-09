pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- tamagotchi stats
egg_stats={
	spri=32,
	sx=0,
	sprw=2,
	sprh=2,
	
	anim={32},
	evol_anim={32,34,32,34,32,34,32,34,36},
	anispd=0.2,
	
	weight=0,
	
	stage="egg",
	evoltime=5
}

baby_stats={
	spri=6,
	sx=1,
	sprw=1,
	sprh=1,
	
	anim={6,7},
	evol_anim={},
	anispd=0.1,
	
	weight=1,
	
	frpoo=20,
	frhungry=15,
	frhappy=30,
	frsick=45,
	
	stage="baby",
	evoltime=65
}

adult_stats={
	spri=0,
	sx=1,
	sprw=2,
	sprh=2,
	
	anim={0,2,4},
	evol_anim={},
	anispd=0.2,
	
	weight=8,
	
	frpoo=60,
	frhungry=360,
	frhappy=240,
	frsick=1440,
	
	stage="adult",
	evoltime=7200
}


function _init()
	cls()
	
	dbg=true
	mode="start"
end

function _update()
	
	if mode=="start" then
		update_start()
	elseif mode=="game" then
		update_game()
	elseif mode=="over" then
		update_over()
	end
	
end

poo_anim={80,80,80,80,81,81,81,81} 

function _draw()
	cls()
	
	if mode=="start" then
		draw_start()
	elseif mode=="game" then
		draw_game()
	elseif mode=="over" then
		draw_over()
	end
end

function inittmg()
	local tama={}
	-- pos stuff
	tama.x=60
	tama.y=60
	tama.aniframe=1
	tama.evol=1
	tama.anispd=0.2
	
	tama.evolanimfin=true
	tama.evolving=false
	tama.evolaniframe=1
	
	-- stats
	tama.happy=4
	tama.hunger=4
	tama.discipline=10
	tama.attention=false
	tama.age=0
	tama.weight=3
	tama.sick=false
	tama.mistakes=0
	tama.careneeded=false
	tama.dead=false
	-- in minutes
	tama.starvingtime=0
	
	tama.maxmistakes=8
	tama.maxstarvetime=720
	if debug then
		tama.maxstarvetime=60
	end
	
	return tama
end

function draw_animate()
	if #tmg.anim==0 then
		return
	end
	
	tmg.aniframe+=tmg.anispd
	
	if flr(tmg.aniframe) > #tmg.anim then
		tmg.aniframe=1	
	end
	
	tmg.spr=tmg.anim[flr(tmg.aniframe)]
end

function draw_evolution()
	if #tmg.evol_anim==0 then
		tmg.evolanimfin=true
		return
	end
	
	tmg.evolaniframe+=0.2
	
	if flr(tmg.evolaniframe) > #tmg.evol_anim then
		tmg.evolaniframe=1	
		tmg.evolanimfin=true
	end
	
	tmg.spr=tmg.evol_anim[flr(tmg.evolaniframe)]
end

function get_evolution()

	if tmg.stage=="egg" then
		return baby_stats
	end
	
	if tmg.stage=="baby" then
		return adult_stats
	end
	
	return tmg.stage=="dead"

end

function evolve_tmg(stats)

	tmg.spr=stats.spri
	tmg.sx=stats.sx
	tmg.sprw=stats.sprw
	tmg.sprh=stats.sprh
	tmg.anim=stats.anim
	tmg.evol_anim=stats.evol_anim
	
	tmg.weight=stats.weight
	
	tmg.frpoo=stats.frpoo
	tmg.frhungry=stats.frhungry
	tmg.frhappy=stats.frhappy
	tmg.frsick=stats.frsick
	
	tmg.stage=stats.stage
	-- given in minutes
	tmg.evoltime=stats.evoltime
	
	tmg.evolving=false
	
	printh("evolve to: "..stats.stage)

end

function increment_mistakes()
	tmg.mistakes+=1
	
	if tms.mistakes >= tmg.maxmistakes then
		kill_tamagotchi()
	end	
end

function kill_tamagotchi()
	mode="over"
end

function update_start()

	if btnp(0) or btnp(1) 
	or btnp(2) or btnp(3)
	or btnp(4) or btnp(5)
	then
		start_game()
	end

end

function draw_start()

txt="matagotchi"
print(txt,64-#txt*2,20)

spr(192,48,48,4,4)

txt="press any key to begin"
print(txt,64-#txt*2,100)

end

function start_game()
	--initiate a new session
	mode="game"

	t=0
	tmg=inittmg()
	evolve_tmg(egg_stats)
	selfn=0
	
	poos={}
	
	--allow a settable clock
	clock={d=0,h=0,m=0,s=0,tick=0}
end

function update_game()
	t+=1
	
	updateclock()
	updatestats()
	
	if tmg.evolving then
		if tmg.evolanimfin then
			next_stage=get_evolution()
			evolve_tmg(next_stage)
		end
	end
	
	if tmg.mistakes >= tmg.maxmistakes then
		--kill the poor little guy
		tmg.dead=true
		return
	end
	
	if btnp(0) then
		selfn -= 1
	elseif btnp(1) then
		selfn += 1
	end
	
	selfn %= 7
	
	if btnp(4) then
		dofunction()
	end
	
	if(t%20==0) then
			-- randomly change dir
			if rnd() < 0.1 then
				tmg.sx*=-1
			end
	end
	
	if(t%5==0) then		
		tmg.x+=tmg.sx
		
		if tmg.x > 111 
		or tmg.x < 16 then
			tmg.sx*=-1
		end
	end
	
end

function draw_game()
	drawstats()
	drawfunctions()
	
	if tmg.evolving then
		if not tmg.evolanimfin then
			draw_evolution()
		end
	else
		draw_animate()
	end 
	
	
	spr(tmg.spr, 
					tmg.x, tmg.y, 
					tmg.sprw, tmg.sprh,
					tmg.sx>0)
	for x in all(poos) do
		spr(poo_anim[t%8+1], x, tmg.y+8,1,1)
	end
	
	if tmg.sick then
		spr(82, 
						tmg.x+8*tmg.sprw,
						tmg.y-8)
	end
					
	--draw clock
	print("day:"..clock.d.." h: "..clock.h.. " m: "..clock.m.. " s: "..clock.s,8,110)
end

function update_over()
	if btnp(0) or btnp(1) 
	or btnp(2) or btnp(3)
	or btnp(4) or btnp(5)
	then
		start_game()
	end
end

function draw_over()
	txt="it died..."
	print(txt,64-#txt*2,20)

	spr(196,48,48,4,4)
	
	stats="age: "..tmg.age.." yrs, weight: "..tmg.weight.." kg"
	print(stats,64-#stats*2,90)
	
	txt="press any key to restart"
	print(txt,64-#txt*2,100)
end

function drawstats()
	
	print("hpy:",8,8)
	for i=0,3 do
		spridx=64
		if tmg.happy < (i+1) then
			spridx=65
		end
		spr(spridx,24+i*8,8,1,1)
	end
	
	print("hgr:",64,8)
	for i=0,3 do
		spridx=64
		if tmg.hunger < (i+1) then
			spridx=65
		end
		
		spr(spridx,80+i*8,8,1,1)
	end
	
	print("dis:",8,120)
	x0=24
	for i=0,tmg.discipline-1 do
		x0+=2
		line(x0,120,x0,124)
	end
	
	print("age:"..tmg.age.." yrs",48,120)
	print("wgt:"..tmg.weight.." kg",72,120)	
end

function drawfunctions()
	rectfill(0, 20, 128, 30,14)
	
	j=0
	for i=66,73 do
		x0=8+j*12
		spr(i,x0,21,1,1)
		
		if j==selfn then
			rect(x0-2,19,x0+9,30,7)
		end
		
		j+=1
	end
	
	--handle the care icon separately
	idx=74
	if tmg.careneeded==true then
		idx=73
	end
	
	spr(idx,8+7*12,21,1,1)
end

function dofunction()

	if selfn == 0 then
		--food
		tmg.hunger=min(4,tmg.hunger+1)
		tmg.starvingtime=0
	elseif selfn == 1 then
	--light
	
	elseif selfn == 2 then
		--game
		tmg.happy=min(4,tmg.happy+1)
		-- reduce weight
	
	elseif selfn == 3 then
	--health
		cure = rnd() < 0.75
		if cure then
			tmg.sick=false
		end
	
	elseif selfn == 4 then
		--bathroom
		poos = {}
	
	elseif selfn == 5 then 
	--stats
	
	elseif selfn == 6 then
	--discipline
	
	end

end

function updatestats()
	-- deplete hearts, happiness etc
	
	-- convert the days time into minutes
	minute=clock.h*60+clock.m
	
	if tmg.stage=="egg" then
		if minute%5==0
		and clock.s%60==0 then
			printh("egg hatches!")
			tmg.evolving=true
			tmg.evolanimfin=false
		end
		
		return
	end
	
	if minute%tmg.evoltime==0
	and clock.s%60==0 then
		tmg.evolving=true
		tmg.evolanimfin=false
		return
	end
	
	if minute%tmg.frpoo==0 
				and clock.s%60==0  
	then
		-- do a poo
		r=rnd()
		dir=1
		if r<0.5 then
			dir*=-1
		end
	
		add(poos,tmg.x*dir)
	end
	
	if minute%tmg.frhungry==0 
	and clock.s%60==0
	then
		tmg.hunger=max(0,tmg.hunger-1)
	end
	
	if tmg.hunger==0 then
		if clock.s%60==0 then
		tmg.starvingtime+=1
		end
		
		-- kill tmg after 12 hours
		-- of starvation
		if tmg.starvingtime>tmg.maxstarvetime then
			kill_tamagotchi()
		end
	end
	
	if minute%tmg.frhappy==0 
	and clock.s%60==0
	then
		tmg.happy=max(0,tmg.happy-1)
	end	
	
	if minute%tmg.frsick==0 
	and clock.s%60==0
	then
		tmg.sick=true
	end

end

function updateclock()
	clock.tick+=1
	timescale=29
	
	if dbg then
		timescale=1
	end
	
	if clock.tick<timescale then
		clock.tick+=1
	else
		-- a second has elapsed
		clock.tick=0
		clock.s+=1
		
		if clock.s==59 then
			clock.m+=1 
			clock.s=0
			
			-- check every minute for an event
			updatestats() 
		end
			
		if clock.m==59 then
			clock.h+=1
			clock.m=0
		end
				
		if clock.h==23 then
			clock.d+=1
			clock.h=0
		end
	end
end
__gfx__
000000eeeee00000000000eeeee00000000000eeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000e00000e000000000e00000e000000000e00000e000000eeee00000000000000000000000000000000000000000000000000000000000000000000000000
00eee0000000e00000eee0000000e00000eee0000000e0000eeeeee0000000000000000000000000000000000000000000000000000000000000000000000000
0e0000e00e00e0000e0000e00e00e0000e0000e00e00e000ee0ee0ee00eeee000000000000000000000000000000000000000000000000000000000000000000
00eee0000000e00000eee0000000e0000e0000000000e000eeeeeeee0eeeeee00000000000000000000000000000000000000000000000000000000000000000
0000e0000000e0000e0000000000e00000eee0000000e000eeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
00eee0000000e00000eee0000000e0000000e0000000e0000ee00ee0ee0ee0ee0000000000000000000000000000000000000000000000000000000000000000
0e0000000000e0000000e0000000e0000000e0000000e00000eeee00eeeeeeee0000000000000000000000000000000000000000000000000000000000000000
00eee0000000e0000000e0000000e0000000e0000000e00000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000e00000e000000000e00000e000000000e00000e000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000eeeee00000000000eeeee00000000000eeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000e000000000000000e000000000000000e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000ee00000000000000ee00000000000000ee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000e000000000000000e0000e0000000000e000ee00000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000eeeee00000000000eeeee00000000000eeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000e0000000000000e00000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000ee000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000e0e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000e0000000e000e00000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000e0000000000e0000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000eeee00000000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000e0000e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000e0e00e0e0000000000eeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000ee00000e000000000e0000e00000000000eee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000e000000e00000000e0e00e0e000000000eeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000e000000e00000000ee00000e000000e0ee0e0e0e000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000e0000e0e00000000e000000e0000000eeeeeee0e000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000e0000e0000000000e0000e00000000e0ee00ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000eeee000000000000eeee00000000000eeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
077077000770770000000000090000900700000000000000000000000000000000aaa00000000000000000000000000000000000000000000000000000000000
788788707007007060606066000aa0007770004000033000000000a0606660600a0aaa0000000000000000000000000000000000000000000000000000000000
78888870700000706060606690a00a09070004400030030000a00aa060666060aaa000060aaa0aa0066606600000000000000000000000000000000000000000
78888870700000706666606600a99a0000004400033333308aa00aa060666060aaa00606a707a77a676767760000000000000000000000000000000000000000
078887000700070000600066000aa00000044000033833300aaaaaa066606660aaa00006a000a00a666666660000000000000000000000000000000000000000
0078700000707000006000069006600900440000038883300aaaaaa066606660aaaaaa00a777a00a677766660000000000000000000000000000000000000000
0007000000070000006000060000000004000000033833300aaaaaa0000000000aaaa0000aaa0aa0066606600000000000000000000000000000000000000000
000000000000000000000000000660004000000003333330000000000000000000aa000000000000000000000000000000000000000000000000000000000000
00900000009000000666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00090090090000096666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09000900900000906006006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00900090090009006666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09000000009000006660666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00044000000440000666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00444400004444000606060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04444440044444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000008888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000008888888880000000000000e000e00000000000000000000e000000000000000000000000000000000000000000000000000000000000000000000
00000000008888888888800000000000000e000000000000000000000e0e00000000000000000000000000000000000000000000000000000000000000000000
0000000008888888888888000000000000e0e0000000ee000000000000e000000000000000000000000000000000000000000000000000000000000000000000
00000000088888888888880000000000000e0000000eeee000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000008888888888888880000000000e000e0000eeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888888888888888000000000000000000e0e0000e0000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000888888888888888880000000000000000e000e0000e000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000888888888888888880000000000000000e00000000e000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000888888888888888880000000000000000e0e0000e0e000000e00000e00000000000000000000000000000000000000000000000000000000000000000
0000008886666666666666688000000000000000e00000000e0000000e0e0e000000000000000000000000000000000000000000000000000000000000000000
00000088866666666666666880000000000000ee0e00ee00e0ee0000000e00000000000000000000000000000000000000000000000000000000000000000000
0000008886666600666666688000000000000e0000e0000e0000e0000ee0ee000000000000000000000000000000000000000000000000000000000000000000
000000888666606606666668800000000000e000000eeeee00000e00000e00000000000000000000000000000000000000000000000000000000000000000000
000000888666600606666668800000000000e000eee00000ee000e000e0e0e000000000000000000000000000000000000000000000000000000000000000000
000000888666606606666668800000000000e00e0000000000e00e00e00000e00000000000000000000000000000000000000000000000000000000000000000
000000888666060006666668800000000000e0e0e0000000000e0e00000000000000000000000000000000000000000000000000000000000000000000000000
0000008886666000066666688000000000000e00e000000000e0e000000000000000000000000000000000000000000000000000000000000000000000000000
0000008886666066066666688000000000000000e00000000e000000000000000000000000000000000000000000000000000000000000000000000000000000
00000008888888888888888800000000000000000e0000000e000000000000000000000000000000000000000000000000000000000000000000000000000000
000000088888888888888888000000000000000000e00000ee000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000888888888888888880000000000000000000eeeee00e00000000000000000000000000000000000000000000000000000000000000000000000000000
000000008887888888788880000000000000000000000e0000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000088888887888888800000000000000000000000e0000000e0000000000000000000000000000000000000000000000000000000000000000000000000
00000000088888888888880000000000000000000000000000000e0e000000000000000000000000000000000000000000000000000000000000000000000000
000000000888888888888800000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000000000000000000
00000000008888888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000888888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000008888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
