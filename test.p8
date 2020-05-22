pico-8 cartridge // http://www.pico-8.com
version 27
__lua__

-- call this before you start using dtb.
-- optional parameter is the number of lines that are displayed. default is 3.
function dtb_init(numlines)
    dtb_queu={}
    dtb_queuf={}
    dtb_numlines=3
    if numlines then
        dtb_numlines=numlines
    end
    _dtb_clean()
end
-- this will add a piece of text to the queu. the queu is processed automatically.
function dtb_disp(txt,callback)
    local lines={}
    local currline=""
    local curword=""
    local curchar=""
    local upt=function()
        if #curword+#currline>29 then
            add(lines,currline)
            currline=""
        end
        currline=currline..curword
        curword=""
    end
    for i=1,#txt do
        curchar=sub(txt,i,i)
        curword=curword..curchar
        if curchar==" " then
            upt()
        elseif #curword>28 then
            curword=curword.."-"
            upt()
        end
    end
    upt()
    if currline~="" then
        add(lines,currline)
    end
    add(dtb_queu,lines)
    if callback==nil then
        callback=0
    end
    add(dtb_queuf,callback)
end
-- functions with an underscore prefix are ment for internal use, don't worry about them.
function _dtb_clean()
    dtb_dislines={}
    for i=1,dtb_numlines do
        add(dtb_dislines,"")
    end
    dtb_curline=0
    dtb_ltime=0
end
function _dtb_nextline()
    dtb_curline+=1
    for i=1,#dtb_dislines-1 do
        dtb_dislines[i]=dtb_dislines[i+1]
    end
    dtb_dislines[#dtb_dislines]=""
    sfx(1)
end
function _dtb_nexttext()
    if dtb_queuf[1]~=0 then
        dtb_queuf[1]()
    end
    del(dtb_queuf,dtb_queuf[1])
    del(dtb_queu,dtb_queu[1])
    _dtb_clean()
    sfx(1)
end
-- make sure that this function is called each update.
function dtb_update()
    if #dtb_queu>0 then
        if dtb_curline==0 then
            dtb_curline=1
        end
        local dislineslength=#dtb_dislines
        local curlines=dtb_queu[1]
        local curlinelength=#dtb_dislines[dislineslength]
        local complete=curlinelength>=#curlines[dtb_curline]
        if complete and dtb_curline>=#curlines then
            if btnp(4) then
                _dtb_nexttext()
                return
            end
        elseif dtb_curline>0 then
            dtb_ltime-=1
            if not complete then
                if dtb_ltime<=0 then
                    local curchari=curlinelength+1
                    local curchar=sub(curlines[dtb_curline],curchari,curchari)
                    dtb_ltime=1
                    if curchar~=" " then
                        sfx(2)
                    end
                    if curchar=="." then
                        dtb_ltime=6
                    end
                    dtb_dislines[dislineslength]=dtb_dislines[dislineslength]..curchar
                end
                if btnp(4) then
                    dtb_dislines[dislineslength]=curlines[dtb_curline]
                end
            else
                if btnp(4) then
                    _dtb_nextline()
                end
            end
        end
    end
end
-- make sure to call this function everytime you draw.
function dtb_draw()
    if #dtb_queu>0 then
        local dislineslength=#dtb_dislines
        local offset=0
        if dtb_curline then
            offset=dislineslength-dtb_curline
        end
        rectfill(2,125-dislineslength*8,125,125,1)
        if dtb_curline>0 and #dtb_dislines[#dtb_dislines]==#dtb_queu[1][dtb_curline] then
            print("\143",118,120,6)
        end
        for i=1,dislineslength do
            print(dtb_dislines[i],4,i*8+119-(dislineslength+offset)*8,7)
        end
    end
end
--above from:
--https://www.lexaloffle.com/bbs/?tid=28465
--https://www.lexaloffle.com/bbs/?tid=28465
--https://www.lexaloffle.com/bbs/?tid=28465
--https://www.lexaloffle.com/bbs/?tid=28465


function _init()
    dtb_init(3)

    make_player()
    make_npcs()
    make_map()
    draw_map()

    game_over = false
    btnpress=0
    tick=0
    frameNum=30

    npcSpoken=false
    textCD=0

    focus={}
    focus.x=p.x
    focus.y=p.y
    focus.dir=left
end

function _update()
    dtb_update()
    --tick increments every other second 
    if (t()%2 ==0) tick+=1
    --frame counter goes down 1 every update loop
    --resets to 30 at 0
    if(frameNum == 0) then
        frameNum=30
    else
        frameNum-=1
    end

    if(textCD==0) then
        --npc not been spoken too yet just initiate dialogue checks
        if (btnp(4)) npc_talk()
    else
        --npc has been spoken to, cooldown+1 every frame
        --end of npc dialogue sets textCD to 10, delay is actually 40 frames 
        textCD +=1
        --if delay has run out
        if(textCD > 50) then
            --check for input again 
            if (btnp(4)) npc_talk()
            --reset timer
            textCD=0
        end
    end

    player_spin()
    create_npc(yellowFish)
    create_npc(dog)
    
end

function _draw()
    draw_map()

    draw_player()
    p_idle_anim()

    draw_npc(yellowFish,8,3)
    draw_npc(dog,10,5)
    npc_anim()


    print(focus.x)
    print(focus.y)
    print(textCD)
    print(mget(focus.x,focus.y))
    print(npcSpoken)
    --draw text boxes
    dtb_draw()
end

function tile_check(x,y,flag)
    --check tile flag return tile flag bool
    return fget(mget(x,y),flag)
end

function make_player()
    p={}
    p.x=1
    p.y=1
    p.state=true
    p.sprite=1
end

function make_map()
    savePoint = 0
    wall = 1
    npc = 2
end

function make_npcs()
    --npcs + first sprite #
    dog= {}
    dog.sprite = 130 --save point dog
    dog.spawn = false

    yellowFish = {}
    yellowFish.sprite = 128 --generic yellow fish
    yellowFish.spawn = false

    fishFish = {}
    fishFish.sprite = 146 -- Fish fish 
    fishFish.spawn = false

    swFish = {}
    swFish.sprite = 160 --swedish fish
    swFish.spawn = false

    mumKrew = {}
    mumKrew.sprite = 176 --mumblekrew
    mumKrew.spawn = false

    deel = {}
    deel.sprite = 144 --deal eel
    deel.spawn = false

    dilFish = {}
    dilFish.sprite = 162 -- dilly fish
    dilFish.spawn = false

    namazu = {}
    namazu.sprite = 178 --namazu
    namazu.spawn = false

end

function draw_map()
    cls()
	mapx=flr(p.x/16)*16
	mapy=flr(p.y/16)*16
	camera(mapx*8,mapy*8)
	
	map(0,0,0,0,128,64)
end

function p_idle_anim()
    cur = t()
    -- if last time btn pressed - time game has been running is less than 2 seconds
    if (cur - btnpress > 2) then
        if(focus.dir=='left') then 
            if(frameNum < 15) then
                p.sprite=17
            else
                p.sprite=33
            end
        else
            if(frameNum < 15) then
                p.sprite=16
            else
                p.sprite=32
            end
        end
    end
end

function create_npc(curNpc)
    curNpc.spawn = true 
end

function draw_npc(npcSprite,x,y)
    if(x < p.x) then --face right 
        mset(x,y,npcSprite.sprite)
    else
        --npc sprite at a location
        mset(x,y,npcSprite.sprite)
    end
end

function npc_anim()
    if(frameNum > 15) then
        dog.sprite=130
        yellowFish.sprite=128
        fishFish.sprite=146
        swFish.sprite = 160 
        mumKrew.sprite = 176 
        deel.sprite = 144 
        dilFish.sprite = 162
        namazu.sprite = 178
    else
        dog.sprite =131
        yellowFish.sprite=129
        fishFish.sprite=147
        swFish.sprite=161
        mumKrew.sprite=177
        deel.sprite=145
        dilFish.sprite=163
        namazu.sprite=179
    end
end

function draw_player()
    spr(p.sprite,p.x*8,p.y*8)
end

function player_spin()
    --turning player sprite and store direction
    if(btn(⬅️)) then --left 
        p.sprite=2 
        focus.x = p.x-1
        focus.y = p.y 
        focus.dir = 'left'

        btnpress = t()
        move_player() 
    end 
    if(btn(➡️)) then --right
        p.sprite=3 
        focus.x = p.x+1
        focus.y = p.y  
        focus.dir = 'right'

        btnpress = t()
        move_player() 
    end
    if(btn(⬆️)) then --up
        p.sprite=4 
        focus.x = p.x
        focus.y = p.y-1 
        focus.dir = 'up'

        btnpress = t()
        move_player() 
    end
    if(btn(⬇️)) then --down
        p.sprite=5 
        focus.x = p.x
        focus.y = p.y+1
        focus.dir = 'down'

        btnpress = t() 
        move_player()
    end
end

function move_player()
    --wanted player pos = current player pos
    nx=p.x
    ny=p.y

    if(btnp(⬅️)) nx-=1
	if(btnp(➡️)) nx+=1
	if(btnp(⬆️)) ny-=1
    if(btnp(⬇️)) ny+=1

    if(tile_check(nx,ny,wall)) then
        --is wall flag
        --animate bumping sprite
        p.sprite=p.sprite+16
        --play sfx
        sfx(0)
     else   
         --player moved to desired pos
         p.x=nx    
         p.y=ny 
     end
end

function npc_talk()
    --tile checks npc sprite
    if(tile_check(focus.x,focus.y,npc)) then
        --get sprite # and pass to check name, returns text string 
        npcSprite_talk=mget(focus.x,focus.y)

        if(npcSprite_talk == yellowFish.sprite) then
            dtb_disp("hey man")
            dtb_disp("you heading out for a walk?",textDelay())
        end
        if(npcSprite_talk == dog.sprite) then
            dtb_disp("borkbork...")
            dtb_disp(">he seems to like you",textDelay())
        end
        if(npcSprite_talk == fishFish.sprite) then
            dtb_disp("flashyn",textDelay())
        end
        if(npcSprite_talk == swFish.sprite) then
        end
        if(npcSprite_talk == mumKrew.sprite) then
        end
        if(npcSprite_talk == deel.sprite) then
        end
        if(npcSprite_talk == dilFish.sprite) then
        end
        if(npcSprite_talk == namazu.sprite) then
        end

    end
end

function textDelay()
    -- above the trigger # of 0, actual delay is then 40 frames
    textCD=10
end
__gfx__
00000000000000000000000000000000000660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000006000000000000000000006066000060060000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000c6660066c00600600c660006666000006600000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700000666600606666000066660600c66c000006600000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700000606c0066666600006666660006600000c66c0000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070000666000066c00600600c660000660000066660000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000006006000066060000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000006600000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000d0000d000000000000000000000000000000060060000000000000000000000000000000000000000000000000000000000000000000000000000000000
0060000dd00006000000000000000000000660000006600000000000000000000000000000000000000000000000000000000000000000000000000000000000
0666c000000c66600066c006600c6600006066000006600000000000000000000000000000000000000000000000000000000000000000000000000000000000
006666d00d66660006066660066660600066660000c66c0000000000000000000000000000000000000000000000000000000000000000000000000000000000
00c6060000606c00066666600666666000c66c000066660000000000000000000000000000000000000000000000000000000000000000000000000000000000
00066600006660000066c006600c6600000660000066060000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000660000006600000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000006006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000d00d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00600d0000d00600066c00600600c660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0666c000000c66606666660000666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
006666d00d6666006866660000666686000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00c6060000606c00066c00600600c660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00066600006660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000066c00600600c660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000006666660000666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000006866660000666686000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000066c00600600c660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000110000000000000000000000077700000000000000000000000000000000000000000000000000000000000
00055550000000000000000000000000001000000110000000000090000000000777670000000aa0000000000000000000000000000000000000000000000000
00575555000000000000000000000000016100000000000000900000000000007777776000000aa0000000000000000000000000000000000000000000000000
00577555000000000000000000000000001000000000000000000000000110007677766000000000000000000000000000000000000000000000000000000000
0555555500000000000000000000000000000000000aa00000000000000110007777666000000000000000000000000000000000000000000000000000000000
1555555100000000000000000000000000000000000aa00000009000000000000776660000000000000000000000000000000000000000000000000000000000
01155551000000000000000000000000000000000000000000000000000000000066600000000000000000000000000000000000000000000000000000000000
00011110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000003b30000000000b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000003b300000b0003b300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000003b300003b3003b300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003b30003b3003b300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003b30003b303b3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003b30003b303b3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003b3003b3003b3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000003b30003b30003b300000000ff7fff9fff7ff7ff00000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000003b300003b3003b300000000ffff9fff9ffffff700000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000003b300003b3003b3000000007f9fff7ffff7f9ff00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003b30003b3003b300000000ffffffffffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003b3003b3003b3000000000ffffffffffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003b3003b3003b3000000000ffffffffffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000003b30003b3003b3000000000ffffffffffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000003b30003b30003b300000000ffffffffffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000
00d00000d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000ff40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d00000000d000000ff4000ffff40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0099900000000000fff4fff008ffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
009c90000d99900000fffff000fffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00999900009c90000054054000540540000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00009000009999000004004000040040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0000000000000000d00000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000a9a0a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0ddd00000000000d0bbbbb00d0a9a0a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d8ddd0000ddd0000b0bbb0a00bbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0ddddddd0d55dd000aab55000b0bbb0a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00dddddd0ddddddd000050000aab5500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000dddd00dddddd0000900000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000dddd0000000000009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00d00000d0000000d000000000d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d08800080d000000000000f00d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08e8888000880008d0eeeeff000000f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0888888008e888800e0eee0000eeeeff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00880008088888800eeef0000e0eee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000880008000000000eeef000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d00000000c6000d000d00000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c60d000066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
066000d0d0060000d05580050d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0006000000000c600505855000558005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0000c6000c606600668660505058550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00c6066000660006500a000006686605000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
006600060d00600000000000500a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002060200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020200000000000000000000
0606070700000000000000000000000006060606000000000000000000000000060606060000000000000000000000000606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4256424242004242424242424242420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0056564200004900440000004900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000565644000000000000460000000000000000000047000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4900000056004700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000440047000000005600440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4500000048000000000000005600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000049000045000000440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000445600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4400000000005600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0046004700005644000000450044000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000490056560044000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000004400000000564400004600004744000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5600000000470000005656560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000004600000000004400564456000049000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0045000044004600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242424242424242424242424242424200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00030000070300c0300d03018000180001a0000a00012000120001100014000160000640000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0004000000000130101b01026010200101f0101501000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000555004550035500f500085000000000000000000000000000000000000000000000000000000000000001e5000000000000000000000000000000000000000000000000000000000000000000000000
