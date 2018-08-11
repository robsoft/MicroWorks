pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- main

function _init()
 timer = 0
 timer_rst = 3 // how many frames between 'inputs'

 shottimer_rst = 15
 shot_dur = 105
 water_shot = 11
	debug=true
 in_game = true
 cur_map = 2
	setup_gfx()
	setup_players()
	setup_shots()
	setup_bounce()
//	setup_maps()
	map_ofs=(cur_map-1)*16
	
end


function _draw()
 cls(3)
 if in_game then
  map(map_ofs+0,0,0,0,16,16)
  draw_shots()
  draw_tank(p1)
  draw_tank(p2)
  draw_stats()
  if debug then 
   line(0,0,stat(1)*128,0,15)
  end
 else
  draw_menu()
 end  
end


function _update()
 // only check inputs if timer fires
 if timer<=0 then
  move_tank(p1,p2)
  move_tank(p2,p1)
  timer=timer_rst
 end
	timer-=1  

 // hold off 'reload'
 if p1.shottimer>0 then p1.shottimer-=1 end
 if p2.shottimer>0 then p2.shottimer-=1	end
 
	move_shots()
 check_hits()
end

-->8
-- menu

function draw_menu()
 cls()
 print("menu",1,1)
end


-->8
-- game draw

function draw_shots()
 local dline=0
 for shot in all(shots) do
  if shot.dur>0 then
//   if debug==true then
//    print (
//     shot.x..","..shot.y.."-"..shot.dirt.."!"..shot.dur,
//     0,dline,15)
//    dline=dline+6
//   end
   pset(shot.x,shot.y,0)
  end
 end
end
 
function draw_stats()
 rectfill(0,0,128,7,0)
 for x=1,min(p1.lives,5) do
  spr(1,(x-1)*8,0)
 end
 for x=1,min(p2.lives,5) do
  spr(4,120-((x-1)*8),0)
 end

 // cheat for score
 p1s=10000+p1.score
 p2s=10000+p2.score
 print(sub(p1s,2,5).." : "..sub(p2s,2,5),44,1,9)
 end

function draw_tank(player)
 local sprline = tankspr[player.dirt]
 local sprt = sprline[1] + ((player.id-1)*3)+1

 spr(sprt, player.x, player.y, 1, 1, 
     sprline[2], sprline[3])
end
  
-->8
-- player update

function get_x(player)
 if player.dirt==2 or
    player.dirt==3 or
    player.dirt==4 then 
     return player.x + 1
 end
 if player.dirt==8 or
    player.dirt==7 or
    player.dirt==6 then 
     return player.x - 1
 end
 return player.x
end

function get_y(player)
 if player.dirt==8 or
    player.dirt==1 or
    player.dirt==2 then 
     return player.y - 1
 end
 if player.dirt==4 or
    player.dirt==5 or
    player.dirt==6 then 
     return player.y + 1
 end
 return player.y
end


function start_shot(player)
 player.shottimer=shottimer_rst
 // add a shot
 shtln=shotfs[player.dirt]
 newshot = {
   id=player.id, 
   dirt=player.dirt,
   x=player.x+shtln.x,
   y=player.y+shtln.y, 
   dur=shot_dur}
 add(shots, newshot)
 sfx(1)
end      

function move_tank(player,other)
 plr=player.id-1 // shortcut
 if btn(2,plr) then
  old_x = player.x
  old_y = player.y
  new_x = get_x(player)
  new_y = get_y(player)
  // test if we need to clip
  player.x = mid(0,new_x,120)
  player.y = mid(7,new_y,120)

  o=other.x
  p=other.y
  x=player.x
  y=player.y
  if (((x+6>=o) and (x+6<=o+6))
      or
     ((x>=o) and (x<o+6)))
     and
     (((y+6>=p) and (y+6<=p+6))
      or
     ((y>=p) and (y<p+6))) then
//    sfx(5)
    player.x=old_x
    player.y=old_y
   end
  // map?
  mx=flr(0.5 + (player.x/8))
  my=flr(0.5 + (player.y/8))
  newmap=mget(map_ofs+mx, my)
  if fget(newmap,0) then
    player.x=old_x
    player.y=old_y
  end    
  // did we clip?
  if (player.x==old_x) and (player.y==old_y) then
   sfx(0)
  end
 end
 
 if btn(5,plr) and (player.shottimer==0) then
  start_shot(player)
 end
 
 if btn(0,plr) then player.dirt-=1 end
 if btn(1,plr) then player.dirt+=1 end
 if player.dirt<1 then player.dirt=8 end
 if player.dirt>8 then player.dirt=1 end
end
-->8
-- setup

function setup(play,id,x,y,dirt,colour)
 play.x = x
 play.y = y
 play.id = id
 play.dirt = dirt
 play.shottimer = 0
 play.score = 0
 play.lives = 3
 play.colour = colour
end

function setup_shots()
 shots={}
 
 // this controls the offset for the bullet
 // when first fired, 
 // based on the players x,y
 shotfs={}
 local shtline={x=4,y=0}
 add(shotfs,shtline)
 local shtline={x=6,y=2}
 add(shotfs,shtline)
 local shtline={x=6,y=4}
 add(shotfs,shtline)
 local shtline={x=5,y=6}
 add(shotfs,shtline)
 local shtline={x=4,y=7}
 add(shotfs,shtline)
 local shtline={x=2,y=6}
 add(shotfs,shtline)
 local shtline={x=1,y=4}
 add(shotfs,shtline)
 local shtline={x=1,y=2}
 add(shotfs,shtline)
 
end

function setup_gfx()
 // green will be transparent
 palt(3,true)
 // setup our array of sprite numbers & h/v flips
 tankspr = {}
 local sprline = {0,false,false}
 add (tankspr,sprline)
 local sprline = {1,false,false}
 add (tankspr,sprline)
 local sprline = {2,false,false}
 add (tankspr,sprline)
 local sprline = {1,false,true}
 add (tankspr,sprline)
 local sprline = {0,false,true}
 add (tankspr,sprline)
 local sprline = {1,true,true}
 add (tankspr,sprline)
 local sprline = {2,true,true}
 add (tankspr,sprline)
 local sprline = {1,true,false}
 add (tankspr,sprline)
end

function setup_players()
 p1 = {}
 p2 = {}
 setup(p1,1,8,64,3,11)
 setup(p2,2,112,64,7,6)
end

function setup_bounce()
 bounce1={5,8,7,6,1,4,3,2}
 bounce2={1,4,3,2,5,8,7,6}
end
-->8
function move_shots()
 for shot in all(shots) do
  if shot.dur>0 then
   new_x=get_shot_x(shot)
   new_y=get_shot_y(shot)
   // clip = stop
   shot.x=mid(0,new_x,128)
   shot.y=mid(7,new_y,128)
   if (shot.x!=new_x) or (shot.y!=new_y) then
    shot.dur=0
   else
    shot.dur-=1
   end
  end
  // if we've flicked duration to zero, kill the shot
  if shot.dur<=0 then del(shots,shot) end
 end
end

function get_shot_x(shot)
 if shot.dirt==2 or
    shot.dirt==3 or
    shot.dirt==4 then 
     return shot.x + 1
 end
 if shot.dirt==8 or
    shot.dirt==7 or
    shot.dirt==6 then 
     return shot.x - 1
 end
 return shot.x
end

function get_shot_y(shot)
 if shot.dirt==8 or
    shot.dirt==1 or
    shot.dirt==2 then 
     return shot.y - 1
 end
 if shot.dirt==4 or
    shot.dirt==5 or
    shot.dirt==6 then 
     return shot.y + 1
 end
 return shot.y
end

function check_hits()
  // crude, we can check pixel colours for
  // each shot, as we draw the tanks after the shots
 for shot in all(shots) do
   colr = pget(shot.x, shot.y)
   if (colr==p1.colour) then
    handle_hit(shot,p1,p2)
   elseif (colr==p2.colour) then
    handle_hit(shot,p2,p1)  
   elseif (colr==5) then
    bounce_shot(shot)
   elseif (colr==12) or (colr==7) then
    shot.dur-=water_shot
    sfx(5)
   elseif (colr!=3) then
    shot.dur=0
   end
   if shot.dur<=0 then
    del(shots,shot)
   end
 end
end

function bounce_shot(shot)
 old=shot.dirt
 // flip the shot's direction
 shot.dirt=bounce1[shot.dirt]
 // still hit?
 new_x=get_shot_x(shot)
 new_y=get_shot_y(shot)
 if pget(new_x, new_y)==5 then
  shot.dirt=bounce2[old]
  new_x=get_shot_x(shot)
  new_y=get_shot_y(shot)
  if pget(new_x, new_y)==5 then
   if (old>4) shot.dirt=8-old else shot.dirt=4+old
  end 
 end     
 sfx(4)
end

function handle_hit(shot,struck,other)
 sfx(2)
 other.score+=1
 struck.lives-=1
 shot.dur=0
 struck.shottimer=0
 if struck.lives<0 then in_game=false end
end  
  


__gfx__
0000000033333333333b333333333333333333333336333333333333000000000000000000000000000000000000000000000000000000000000000000000000
00000000333bb33333b33bb33bbbbb33333663333363366336666633000000000000000000000000000000000000000000000000000000000000000000000000
007007003b3bb3b33bbbbbb333bbb333363663633666666333666333000000000000000000000000000000000000000000000000000000000000000000000000
000770003bbbbbb3bbbbbb3333bbbbb3366666636666663333666663000000000000000000000000000000000000000000000000000000000000000000000000
000770003bbbbbb3b3bbbb3b33bbbbb3366666636366663633666663000000000000000000000000000000000000000000000000000000000000000000000000
007007003bbbbbb3333bbbb333bbb333366666633336666333666333000000000000000000000000000000000000000000000000000000000000000000000000
000000003b3333b33333bb333bbbbb33363333633333663336666633000000000000000000000000000000000000000000000000000000000000000000000000
0000000033333333333bb33333333333333333333336633333333333000000000000000000000000000000000000000000000000000000000000000000000000
00000000333333333355555555555533555555555555555555555555553333333333335533333333333333330000000000000000000000000000000000000000
00000000333333333555555555555553555555555555555555555555533333333333333533333333333333330000000000000000000000000000000000000000
00000000333333335555555555555555555555555555555555555555333333333333333333333333333333330000000000000000000000000000000000000000
00000000333333335555555555555555555555555555555555555555333333333333333333333333333333330000000000000000000000000000000000000000
00000000333333335555555555555555555555555555555555555555333333333333333333333333333333330000000000000000000000000000000000000000
00000000333333335555555555555555555555555555555555555555333333333333333333333333333333330000000000000000000000000000000000000000
00000000333333335555555555555555555555533555555555555555333333333333333353333333333333350000000000000000000000000000000000000000
00000000333333335555555555555555555555333355555555555555333333333333333355333333333333550000000000000000000000000000000000000000
333333333333333333cccccccccccc33cccccccccccccccccccccccccc333333333333cc33333333333333330000000000000000000000000000000000000000
00000000300000033ccc77cccccc77c3cccc77cccccc77cccccc77ccc33333333333333c33333333333333330000000000000000000000000000000000000000
0000000030000003cccccccccccccccccccccccccccccccccccccccc333333333333333333333333333333330000000000000000000000000000000000000000
0000000030000003cccccccccccccccccccccccccccccccccccccccc333333333333333333333333333333330000000000000000000000000000000000000000
0000000030000003ccc77cccccc77cccccc77cccccc77cccccc77ccc333333333333333333333333333333330000000000000000000000000000000000000000
0000000030000003c77cc7ccc77cc7ccc77cc7ccc77cc7ccc77cc7cc333333333333333333333333333333330000000000000000000000000000000000000000
0000000030000003ccccccccccccccccccccccc33ccccccccccccccc3333333333333333c33333333333333c0000000000000000000000000000000000000000
3333333333333333cccccccccccccccccccccc3333cccccccccccccc3333333333333333cc333333333333cc0000000000000000000000000000000000000000
00000000000000003333333330000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000003333333308888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000003333f33308877880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000003333333308777780000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000003333333308777780000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000033f3333308877880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000333333f308888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000003333333330000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000101010101000000000000000000010101010101010000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
2120202020202020202020202020202121202020202020202020202020202021212020202020202020202020202020212111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111126262411111111111111111111181516111111111111111111111111111111111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111116111111111111161111111126242711111111111111111111111815111111111111161111161111111111111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111116161616161616161111111124271111111111111111111111111118111116161111161616161111161611111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111116161616161616161111111111111111111111111111111111111111111116111111111111111111111611111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111116161111111111111111111111111216161319111111111111111116111111161616161111111611111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111616161616131111111111111616111111111111111111111616111111101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111161111111111111111111116111111111111111617111118141111111111111111111116161616161611111111111111101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111161111111111111111111116111111111111111619111111111111111111111111111116161616161611111111111111100000100000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111161111111111111111111116111111111111111513191111111122231111111111111116161616161611111111111111101000101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111815131911111125241111111616111111111111111111111616111111101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111116161111111111111111111111111118161319111111111111111116111111161616161111111611111111101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111116161616161616161111111111111111111112161616131911111111111116111111111111111111111611111111101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
111111111616161616161616111111111111111a121614171118151319111111111116161111161616161111161611111111101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111116111111111111161111111111111112141711111111181513111111111111111111161111161111111111111111101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020102020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000001010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000001010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000001010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000001010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000001010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000300000505007050080500605008050026300001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000e65009650066500465001630016300162001620016100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000267002670056700767005670026700266001660016500265003650026500264001640016400264002640026400163001630016200162001620016200161001610016100160001600000000000000000
000200000805009050090500705005030050200301000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000033050370503c0503c0503c050340502e05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
