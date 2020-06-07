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
        textCD = t()
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
        rectfill(2+camx,(125-dislineslength*8)+camy,125+camx,125+camy,1)
        if dtb_curline>0 and #dtb_dislines[#dtb_dislines]==#dtb_queu[1][dtb_curline] then
            print("\143",118+camx,120+camy,6)
        end
        for i=1,dislineslength do
            print(dtb_dislines[i],4+camx,(i*8+119-(dislineslength+offset)*8)+camy,7)
        end
    end
end
--above from:
--https://www.lexaloffle.com/bbs/?tid=28465
--https://www.lexaloffle.com/bbs/?tid=28465
--https://www.lexaloffle.com/bbs/?tid=28465
--https://www.lexaloffle.com/bbs/?tid=28465

--add sea otter strawberry 
--add seal miju
--add jellyfish erica and lena
--add gator alexa
--add maki tuna meliong


function _init()
    dtb_init(3)
    cartdata("fishgame")

    make_player()
    make_npcs()
    make_map()
    make_sfx()
    make_sprites()
    star_mapscan()

    game_over = false
    btnpress=0
    frameNum=30

    textInit=false
    textCD=0

    focus={}
    focus.x=p.x
    focus.y=p.y
    focus.dir=left

    camx=0
    camy=0
    camOffset=3
    shake=true

    --segment1
    create_npc(yellowFish)
    create_npc(dog)

    --segment2
    create_npc(namazu)
    create_npc(dilFish)

    --segment3
    create_npc(deel)
    create_npc(mumKrew)

    --puzzles
    buttonPushed=0
    create_puzzlerooms()
end

function _update()
    dtb_update()

    --frame counter goes down 1 every update loop
    --resets to 30 at 0
    if(frameNum == 0) then
        frameNum=30
    else
        frameNum-=1
    end

    player_spin()

    --half second has passed, reset text trigger
    if (btn(4)) then 
        npc_talk() interact()
    end
    if(t() - textCD > 0.5) textInit = false

    --enter key to load game 
    if(btn(6)) load_game()

    --screen1 transition
    if(dog.spoken and yellowFish.spoken) then
        map_tileClear(15,9)
        map_tileClear(16,9)    
    end   
    
    --screen2 transition
    --sound and gfx

    --screen3 right

    --puzzles buttons=4
    if(buttonPushed==4) then 
        mset(37,22,65)
        buttonPushed=0
    end

end

function _draw()
    cls()
    draw_map()

    draw_player()
    p_idle_anim()

    draw_npc(yellowFish,8,3)
    draw_npc(dog,10,5)

    draw_npc(namazu,20,6)
    draw_npc(dilFish,25,8)

    draw_npc(deel, 33,11)
    draw_npc(mumKrew,37,11)

    draw_npc(fishFish,53,8)
    draw_npc(dog,60,8)
    npc_anim()

    print(t())
    print(starx[1])
    print(stary[1])
    print(buttonPushed)

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
    push = 3
    buttonUp = 4
    buttonDown = 5
end

function make_npcs()
    --npcs + first sprite #

    dog= {}
    dog.sprite = 130 --save point dog
    dog.spawn = false
    dog.string1 = "bork bork..."
    dog.string2 = ">you pet the dog"
    dog.string3 = ">he licks your hand"
    dog.spoken = false

    yellowFish = {}
    yellowFish.sprite = 128 --generic yellow fish
    yellowFish.spawn = false
    yellowFish.string1 = "hey you going out?"
    yellowFish.string2 = "ah okay, take care out there"
    yellowFish.spoken = false

    fishFish = {}
    fishFish.sprite = 146 -- Fish fish 
    fishFish.spawn = false
    fishFish.string1 = "flashyn"

    swFish = {}
    swFish.sprite = 160 --swedish fish
    swFish.spawn = false

    mumKrew = {}
    mumKrew.sprite = 176 --mumblekrew
    mumKrew.spawn = false
    mumKrew.string1 = "owo was that a cave in just now?"
    mumKrewPog = {}
        add(mumkrewPog,"pog")
        add(mumKrewPog,"frogchamp")
        add(mumKrewPog,"tunachamp")
        add(mumKrewPog,"oh....pog?")

    deel = {}
    deel.sprite = 144 --deal eel
    deel.spawn = false
    deel.string1 = "pooog"
    deel.string2 = "did you cause that cave in?"

    dilFish = {}
    dilFish.sprite = 162 -- dilly fish
    dilFish.spawn = false

    namazu = {}
    namazu.sprite = 178 --namazu
    namazu.spawn = false
    namazu.string1 = "i went in that cave and some eels jumped out at me !!"
    namazu.string2 = "be careful if you're going in there" 
    namazu.spoken = true

end

function make_sfx()
    sound = {}
    sound.textLine = 2
    sound.textAdv = 1
    sound.bump = 0
    sound.doorOpen = 3
    sound.switchPressed = 4
end

function make_sprites()
    sprite = {}
    sprite.rock = 64
    sprite.rockPush = 65
    sprite.button = 80
    sprite.buttonDown = 81
end

function draw_map()
    --camx=((p.x/16)*16)*8
    --camy=((p.y/16)*16)*8
   --camera(mapx*8,mapy*8) 

    camera(camx,camy)

    map(0,0,0,0,128,128)
    --animate stars

    star_anim()

    --screen1 right
    if(p.x==15) camx+=128 p.x=17 
    if(p.x==16) camx-=128 p.x=14
    --screen2 right
    if(p.x==31) camx+=128 p.x=33
    if(p.x==32) camx-=128 p.x=30
    --cave1 down
    if(p.y==15) camy+=128 p.y=17
    if(p.y==16) camy-=128 p.y=14
    --cave1 right
    if(p.x==47) camx+=128 p.x=49
    if(p.x==48) camx-=128 p.x=46
    --cavepuzzles
    if(p.x==63) camx+=128 p.x=65
    if(p.x==64) camx-=128 p.x=62

    if(p.x==79) camx+=128 p.x=81
    if(p.x==80) camx-=128 p.x=78

    if(p.x==95) camx+=128 p.x=97
    if(p.x==96) camx-=128 p.x=94

    if(p.x==111) camx+=128 p.x=113
    if(p.x==112) camx-=128 p.x=110
    --cave2 down
    if(p.y==31 and p.x<42) camy+=128 p.y=33
    if(p.y==32 and p.x<42) camy-=128 p.y=30
    --cavedark1 right
    if(p.x==47 and p.y>38) camx+=128 p.x=49
    if(p.x==48 and p.y>38) camx-=128 p.x=46
    --cavedark2 up teleport to starfield
    if(p.x>53 and p.y==32) then
        camx=0 
        camy=128

        p.x=4
        p.y=29
    end
end

function star_mapscan()
    starx={}
    stary={}
    --add star coords to array
    for x=0,16 do
        for y=15,30 do
            if(mget(x,y)==68) then
                add(starx,x)
                add(stary,y)
            end
        end
    end
end

function create_puzzlerooms()
    for x=64,127 do
        for y=0,15 do
            --rnd int every for loop
            val=flr(rnd(3))
            --if sprite is 0 then overwrite according to rnd int
            if(mget(x,y) == 0) then
                if(val == 0) mset(x,y,74)
                if(val == 1) mset(x,y,75)
                if(val == 2) mset(x,y,76)
            end
        end
    end

end

function star_anim()
    --flip sprite for every star coord
    val=flr(rnd(#starx)+1)

    if(frameNum<10) then
        mset(starx[val],stary[val],68)
    else
        mset(starx[val],stary[val],67)
    end
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
    mset(x,y,npcSprite.sprite)
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

        --set pushsprite flag to wall if wall is behind it
        if(tile_check(focus.x-1,focus.y,wall)) then
            fset(65,1,true)
        else
            fset(65,1,false)
        end
        move_player() 
        tile_push()    
    end 
    if(btn(➡️)) then --right
        p.sprite=3 
        focus.x = p.x+1
        focus.y = p.y  
        focus.dir = 'right'

        btnpress = t()
        --set pushsprite flag to wall if wall is behind it
        if(tile_check(focus.x+1,focus.y,wall)) then
            fset(65,1,true)
        else
            fset(65,1,false)
        end

        move_player() 
        tile_push()    
    end
    if(btn(⬆️)) then --up
        p.sprite=4 
        focus.x = p.x
        focus.y = p.y-1 
        focus.dir = 'up'

        btnpress = t()
        --set pushsprite flag to wall if wall is behind it
        if(tile_check(focus.x,focus.y-1,wall)) then
            fset(65,1,true)
        else
            fset(65,1,false)
        end

        move_player() 
        tile_push()    
    end
    if(btn(⬇️)) then --down
        p.sprite=5 
        focus.x = p.x
        focus.y = p.y+1
        focus.dir = 'down'

        btnpress = t()   
        --set pushsprite flag to wall if wall is behind it
        if(tile_check(focus.x,focus.y+1,wall)) then
            fset(65,1,true)
        else
            fset(65,1,false)
        end

        move_player()
        tile_push()  
    end
end

function move_player()
    --wanted player pos = current player pos
    nx=p.x
    ny=p.y
    --save sprite under player for tile_push()
    oldSprite = mget(p.x,p.y)

    if(btnp(⬅️)) nx-=1
	if(btnp(➡️)) nx+=1
	if(btnp(⬆️)) ny-=1
    if(btnp(⬇️)) ny+=1

    if(tile_check(nx,ny,wall)) then
        --is wall flag
        --animate bumping sprite
        p.sprite=p.sprite+16
        --play sfx
        sfx(sound.bump)
    else   
         --player moved to desired pos
         p.x=nx    
         p.y=ny      
     end
end

function tile_push()
    --if focusxy is pushable tile and player moves into it, push tile
    if(tile_check(focus.x,focus.y,push)) then
        pushSprite = mget(focus.x,focus.y)

        if(focus.dir=='left') then
            mset(p.x-1,p.y,pushSprite) 
            mset(p.x,p.y,oldSprite) 
            button_switch()
        end
        if(focus.dir=='right') then
            mset(p.x+1,p.y,pushSprite)
            mset(p.x,p.y,oldSprite)
            button_switch()
        end
        if(focus.dir=='up') then
            mset(p.x,p.y-1,pushSprite)
            mset(p.x,p.y,oldSprite)
            button_switch()
        end
        if(focus.dir=='down') then
            mset(p.x,p.y+1,pushSprite)
            mset(p.x,p.y,oldSprite)
            button_switch()
        end
    end
end

function button_switch()
    --if rockpush is on button coords
    --puzzle1
    if(mget(76,12) == sprite.rockPush) then
        sfx(sound.switchPressed)
        buttonPushed+=1
        mset(76,12,sprite.buttonDown)
    end
    --puzzle2
    if(mget(87,5) == sprite.rockPush) then
        sfx(sound.switchPressed)
        buttonPushed+=1
        mset(87,5,sprite.buttonDown)
    end
    --puzzle3
    if(mget(104,7) == sprite.rockPush) then
        sfx(sound.switchPressed)
        buttonPushed+=1
        mset(104,7,sprite.buttonDown)
    end
    --puzzle4
    if(mget(118,14) == sprite.rockPush) then
        sfx(sound.switchPressed)
        buttonPushed+=1
        mset(118,14,sprite.buttonDown)
    end
end

function npc_talk()
    --tile checks npc sprite
    if(tile_check(focus.x,focus.y,npc)) then
        if(textInit==false) then 
            --get sprite # and pass to check name, returns text string 
            npcSprite_talk=mget(focus.x,focus.y)
            textInit = true
            textCD = t()

            if(npcSprite_talk == yellowFish.sprite) then
               dtb_disp(yellowFish.string1)
               dtb_disp(yellowFish.string2)
                yellowFish.spoken=true
            end
            if(npcSprite_talk == dog.sprite) then
                dtb_disp(dog.string1)
                dtb_disp(dog.string2)
                dtb_disp(dog.string3)
                dog.spoken=true
            end
            if(npcSprite_talk == fishFish.sprite) then
                dtb_disp("flashyn")
            end
            if(npcSprite_talk == swFish.sprite) then
            end
            if(npcSprite_talk == mumKrew.sprite) then
                dtb_disp(rnd(mumKrewPog))
                dtb_disp(mumKrew.string1)
            end
            if(npcSprite_talk == deel.sprite) then
                dtb_disp(deel.string1)
                dtb_disp(deel.string2)
            end
            if(npcSprite_talk == dilFish.sprite) then
                dtb_disp("hey")
                dilFish.spoken=true
            end
            if(npcSprite_talk == namazu.sprite) then
                dtb_disp(namazu.string1)
                dtb_disp(namazu.string2)
                namazu.spoken=true
            end

        end
    end
end

function interact()
    --if player standing in front of rock on screen2
    if(p.x==30 and p.y==14) then
        if(dilFish.spoken==true and namazu.spoken==true) map_tileClear(31,14)
    end    
end

function save_game()
    dset(0, p.x)
    dset(1, p.y)

    dtb_disp("game has been saved")
end

function load_game()
    p.x =66--dget(0)
    p.y = 11--dget(1)

    camx=64*8
    camy=0

    dtb_disp("game loaded")
end

function map_tileClear(x,y)
    mset(x,y,0)
    sfx(sound.doorOpen)
end

__gfx__
00000000000000000000000000000000000660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000006000000000000000000006566000060060000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000c6660066c00600600c660006666000006600000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700000666600656666000066665600c66c000006600000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700000606c0066666600006666660006600000c66c0000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070000666000066c00600600c660000660000066660000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000006006000066560000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
000000000000000000000000001000000000000001100000000000000000000000777000000000001111d11111111dd1111d1111777770000000000000000000
00055550000444400000000000600000001000000110000000000090000000000777670000000aa01111ddd1111111d11111d111777777000000000000000000
00575555004f44440000000016761000016100000000000000900000000000007777776000000aa0d11111dd111111dd1111d111777777700000000000000000
00577555004ff4440000000000600000001000000000000000000000000110007677766000000000dd11111dd111111d1111dd11777777700000000000000000
0555555504444444000000000010000000000000000aa000000000000001100077776660000000001d111111ddd11111d1111d11777777700000000000000000
1555555114444441000000000000000000000000000aa000000090000000000007766600000000001ddd111d111ddd11dd111dd1777777700000000000000000
0115555101144441000000000000000000000000000000000000000000000000006660000000000011dddd1111111ddd1dd11dd1777777000000000000000000
0001111000011110000000000000000000000000000000000000000000000000000000000000000011111dd1111d111111d11d11777770000000000000000000
00000000000000000000000000000000000000000000000010000000000000000000000000001166000166610001166166110000166610001661100000000000
00000000000444400000000000000000000000000000000000000001000000000000000000001166001166610001661166110000166611001166100000000000
00000000004f44440000000000000000000000000000000000000000000000000000000000001161001666110011611116110000116661001116110000000000
00000000004ff4440000000000000000000000000000000000100000000000000000000000011661001666110011611116611000116661001116110000000000
00000000044444440000000000000000000000000000000000000000000000000000000000011661001666110011611116611000116661001116110000000000
00000000144444410000000000000000000000000000000000000001000000000000000000116611001666110011661111661100116661001166110000000000
06666660011444410000000000000000000000000000000000001000000000000000000000116611001166110011661111661100116611001166110000000000
60000006666111160000000000000000000000000000000000000000000000000000000000011661000116610001166116611000166110001661100000000000
0000000000b000000000000000000000000000000000000011111166111111111111111100004455000455540004455455440000455540004554400000000000
0000000003b30000000000b000000000000000000000000061166666611111666111111600004455004455540004554455440000455544004455400000000000
0000000003b300000b0003b300000000000000000000000066666111666666666661116600004454004555440044544445440000445554004445440000000000
0000000003b300003b3003b300000000000000000000000016611111166666661666666100044554004555440044544445544000445554004445440000000000
00000000003b30003b3003b300000000000000000000000011111000116666111111111100044554004555440044544445544000445554004445440000000000
00000000003b30003b303b3000000000000000000000000001100000011111100111110000445544004555440044554444554400445554004455440000000000
00000000003b30003b303b3000000000000000000000000000000000000000000000000000445544004455440044554444554400445544004455440000000000
00000000003b3003b3003b3000000000000000000000000000000000000000000000000000044554000445540004455445544000455440004554400000000000
0000000003b30003b30003b300000000ff7fff9fff7ff7ff44444455444444444444444400000000000000000000000000000000000000000000000000000000
0000000003b300003b3003b300000000ffff9fff9ffffff754455555544444555444444500000000000000000000000000000000000000000000000000000000
0000000003b300003b3003b3000000007f9fff7ffff7f9ff55555444555555555554445504400000044444400444440001100000011111100111110000000000
00000000003b30003b3003b300000000ffffffffffffffff45544444455555554555555444444000445555444444444411111000116666111111111100000000
00000000003b3003b3003b3000000000ffffffffffffffff44444000445555444444444445544444455555554555555416611111166666661666666100000000
00000000003b3003b3003b3000000000ffffffffffffffff04400000044444400444440055555444555555555554445566666111666666666661116600000000
0000000003b30003b3003b3000000000ffffffffffffffff00000000000000000000000054455555544444555444444561166666611111666111111600000000
0000000003b30003b30003b300000000ffffffffffffffff00000000000000000000000044444455444444444444444411111166111111111111111100000000
00d00000d000000000000000000000000000000000000000000000000000000000d5000000000000000000b50000000000000000000000d500000000a5000000
0000000000000000000000000ff40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d00000000d000000ff4000ffff400000000000000000000000000000000000000c5000000000000000000a50000000000000000000000e50000000095000000
0099900000000000fff4fff008ffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
009c90000d99900000fffff000fffff0000000000000000000000000000000000004000000000000000004040000000000000000000004d50000000004040000
00999900009c90000054054000540540000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00009000009999000004004000040040000000000000000000000000000000000000d50000000000000095000000000000000000000004000000000000040000
00000000000090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000c00000000000d00000d0000000000000000000000000000000000000000000e500000000000000a5000000000000000000000004000000000000a50000
0000000000000000000a9a0a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000ddd0c00000000d0bbbbb00d0a9a0a000000000000000000000000000000000000e500000000000000b5000000047686667686668676000000000000040000
00ddd8d0000ddd000b0bbb0a00bbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ddddddd000dd55d00aab55000b0bbb0a000000000000000000000000000000000000c50000000000000000047686040000000000000000000000000000b50000
dddddd00ddddddd0000050000aab5500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddd0000dddddd000000900000005000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000950000
00000000dddd00000000000000009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00d00000d0000000d000000000d0000000000000000000000000000000000000000000d500000000000000000000000000000000000000000000002604040000
000000000000000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d08800080d000000000000f00d00000000000000000000000000000000000000000000c50000000000000000000000000000000000000000000000a504000000
08e8888000880008d0eeeeff000000f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0888888008e888800e0eee0000eeeeff00000000000000000000000000000000000000e50000000000000000000000000000000000000000000000b500000000
00880008088888800eeef0000e0eee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000880008000000000eeef000000000000000000000000000000000000000000400000000000000000000c7d7e7000000000000000000000400000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d00000000c6000d000d00000d00000000000000000000000000000000000000000000000c50000000000000000c700000004000000c7e7d7e7c7040400000000
0c60d000066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
066000d0d0060000d05580050d000000000000000000000000000000000000000000000004d7000000000000040000000004c7d7040000000000000000000000
0006000000000c600505855000558005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0000c6000c60660066866050505855000000000000000000000000000000000000000000004c7162616d7c70400000000000000000000000000000000000000
00c6066000660006500a000006686605000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
006600060d00600000000000500a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002080200000000000000000000000000100200000000000000020202020202000002020000000202020202020202020000020200020202020202020202020200
0606070700000000000000000000000006060606000000000000000000000000060606060000000000000000000000000606060600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
7677767776767776777676777677767600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6200000040000000000000000000007172787877784000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7200000000000000000000004000006172000000000040787778787878404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6200400000000000000000000000007172000000000000000000000000004040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
720000000000000000000000000000616200000000000000000000000000006a004040777678787840000000000000000000000000004078764000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
620000000040000000000000000000717200000000000000000000000000006b40400000000000004077784000000040767740000000400000007877767877764d000000000000000000000000000000000000410000005000000000000000000000000000000000000000000000000000000000000000000000000000000000
720000000000000000000000000000617200000000000000000000000000006971000000000000000000000040787778000000777678000000000000000000004d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
620000000041000000000000400000717200000000000000000000000000006b61000000000000000000000000000000000000000000000000000000000000004d000000000000000000000000000000000000000000000000000000000000000000004100000000500000000000000000000000000000000000000000000000
720000000000000000000000000000617200000000000000000000000000006a71000000000000000000000000000000000000000000000000000000000000004d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
620000000000000000000000000000000000000000000000000000000000006b61000000000000000000000000000000000000000000000000000000000000004d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
720000004000000000000000000000617200000000000000000000000000006940000000000000000000000000000000000000000000000000000000000000004d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
620000000000000000000000000000716200000000000000000000000000006b40000000000000000000000000000000000000000000000000000000000000004d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
720000000000000000004000000000617261620000000000000000000000006a71000000000000000000000000000000000000000000000000000000000000004d000000000000410000000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
620000000000000000000000000000717240720000000000000000000000006961000000000000000000000000000000616200000061620061624040616200004d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004100000000000000000000000000
720000000000000000000000000000617240406261000000000000000000000040000000000000000000000000616261404040616240404040404040404062614d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050000000000000000000
61626162616261626162616261626172724040407b797a7b7a7b797a797a7b7a40400000000000000000000000404040000040404000000000000000000040404d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0056424242004242424242424242420000000000000000000000000000000000006c00000000000000000000006a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4456564200004900440000004900000000000000000000000000000000000000006d00000000000000000000006900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000565644000000000000460000004400000000000047000000000000000000006e00000000000000000000006b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4900000056004700000000000000000000000000000000000000000000000000004040610000000000000040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000440047000000005600440000000000000000000000000000000000000000000040400000000000004040690000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
45000000480000000000000056000000000000000000000000000000000000000000006c4000404040404040690000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000490000450000004400000000000000000000000000000000000000406e40404040004000406a4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000445600000000000000000000000000000000000000000000000000004040404000000000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4400000000005600000000000000000000000000000000000000000000000000006d00000000000000000000006b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0046004700005644000000450044000000000000000000000000000000000000006c00000000000000000000626900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000490056560044000000000000000000000000000000000000000000006d00000000000000000000404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000044000000445647000046000047440000000000000000000000000000000040620000000000000000006a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
560000000047000000565656000000000000000000000000000000000000000000006c0000000000000000006b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000460000000000440056445600004900000000000000000000000000000000006d000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0045000044004600000000000000000000000000000000000000000000000000006c0000000000000000006b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242424242424242424242424242424200000000000000000000000000000000006e0000000000000000006a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00030000070300c0300d03018000180001a0000a00012000120001100014000160000640000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0004000000000130101b01026010200101f0101501000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000555004550035500f500085000000000000000000000000000000000000000000000000000000000000001e5000000000000000000000000000000000000000000000000000000000000000000000000
0003000000000095500b5500d550125501555016550135100b5500655009500000000000019500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050000076300a03013630156300f630124000b0300f630106300f40025a0024b000cb000ab0008b0005b0004b0003b0003b0003b000fb0013a000cb000bb000eb000c9001c9001990000000000000000000000
