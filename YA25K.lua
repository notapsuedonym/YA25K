-- Yet Another 2D Prog Lang (YAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA...) (...or just "YA25K")
-- (now with portals)

--[[

        cmds;

    ~ basic movement
    >       :  Change direction to 2-Dimensional "right"
    <       :  Change direction to 2-Dimensional "left"
    ^       :  Change direction to 2-Dimensional "up"
    v       :  Change direction to 2-Dimensional "down"
    ~ I/O
    .       :  Push next character to stack
    !       :  Print all stack values in reverse order
    ?       :  Pop from stack and print value
    i       :  Take input and push to stack
    ~ logic
    %       :  This one is hard to explain, but it basically behaves like a switch and a T-Intersection.
            :   The instruction flow reaches it, if the accumulator is 0 then progression flow turns positive, otherwise it turns negative
            :   To explain this simply, imagine a T-Intersection.
            :   A car is going to it, and it's only allowed to turn right if this special "go" sign is on.
            :   If the sign is on, it turns right, otherwise it turns left.
    +       :  Increment accumulator
    -       :  Decrement accumulator
    &       :  Makes a jump pointer. Everything after it up until "," is considered the name. So '&jump_label,' is the correct syntax.
    :       :  Jump to a jump pointer. Has the same syntax as '&' besides starter symbol. So ':jump_label,' is the correct syntax.
    c       :  Pop 2 values from stack, compare them, set acc to 0 if equal otherwise set to 1.

]]

-- example programs
--[[

    1. "Hello, world!" [
    
        .H.e.l.l.o.,. .w.o.r.l.d.!!
    
    ]:out("Hello, world!")

    2. "Hello.. world?" [

        >             v
             v    e.H.<
        v l. <         
        > .l.o.,. v    
        vl.r.o.w. <    
        > .d.! !  

    ]:out("Hello, world!")

    3. "12345" [

        v       v -?$.<
                      ^
        >+++++  >     %
                      v
                      > .l.o.o.p. .d.o.n.e.! !

    ]:out("12345 loop done!")

    4. "cat" (small/buggy) [

        >i?<

    ]

    5. "cat" (proper) [

        >i?v
        ^  <

    ]

    6. "Truth Machine" [

        v        > .1? v
                 ^     <
        > .0 ic  %
                 v
                 >.$?

    ]

]]

--[[

    how the code is converted to something usable;

        each line is turned into a list of every character in the line
        these lists are stored in one large list, making them rows

        (infinitely prints "Hello, world!")

        > ?p Hello, world! !p v
        ^                     <

        > .H.e.l.l.o.,. .w.o.r.l.d.! v
        ^             !              <

]]

u = require("util") -- module imported for;
                    --      iters()       : allows a string to be iterated over
                    --      iter()        : allows a table to be iterated over
                    --      switch()      : behaves like a switch/match statement
                    -- (quality-of-life and not necessarily required)

stack = {}
acc = 0

map = {}            -- map cord workings reminder;
                    --
                    -- x: inner row, so ++ is further right, and -- is further left
                    -- y: row,       so ++ is further down, and -- is further up
cords = {}
cords.x = 1         -- row entry
cords.y = 1         -- row
cords.mov = {}
cords.mov.xy = "x"
cords.mov.pn = "+"

game = {}
game.db = false     -- do bool
game.dh = ""

registers = {
    ["r1"] = 0,
    ["r2"] = 0,
    ["r3"] = 0,
    ["r4"] = 0,
    ["r5"] = 0
}

var = {}
var_table = {}
varConstr = ""

init = function(s)
    local t = {}
    for x in u.iters(s) do
        if x == '\n' then
            table.insert(map, t)
            t = {}
        else
            table.insert(t, x)
        end
    end
end

logic = function()
    local instr = map[cords.y][cords.x]
    if instr == nil then
        print("\n\n ~! program finished or you tried to exit the bounds")
        return 98
    end
    if game.db == true then
        u.switch(game.dh, {
            ["pnt"] = function()
                if instr ~= "$" then
                    table.insert(stack, instr)
                else
                    table.insert(stack, acc)
                end
                game.db = false
            end,
            ["var"] = function()
                if instr == "," then
                    var_table[varConstr] = {registers.r1, registers.r2}
                    varConstr = ""
                    game.db = false
                else
                    varConstr = varConstr .. instr
                end
            end,
            ["jmp"] = function()
                if instr == "," then
                    if var_table[varConstr] then
                        cords.y = var_table[varConstr][1]
                        cords.x = var_table[varConstr][2]
                    end
                    varConstr = ""
                    game.db = false
                else
                    varConstr = varConstr .. instr
                end
            end,
            ["def"] = function() game.db = false return end
        })
        return
    end
    u.switch(instr, {
        [">"] = function()
            cords.mov.xy = "x"
            cords.mov.pn = "+"
        end,
        ["<"] = function()
            cords.mov.xy = "x"
            cords.mov.pn = "-"
        end,
        ["^"] = function()
            cords.mov.xy = "y"
            cords.mov.pn = "-"
        end,
        ["v"] = function()
            cords.mov.xy = "y"
            cords.mov.pn = "+"
        end,
        ["."] = function()
            game.db = true
            game.dh = "pnt"
        end,
        ["!"] = function()
            for x in u.iter(stack) do
                io.write(x)
            end
            for i = 1, #stack do
                table.remove(stack)
            end
        end,
        ["?"] = function()
            print(table.remove(stack))
        end,
        ["i"] = function()
            io.write(" ~> ")
            table.insert(stack, io.read())
        end,
        ["+"] = function()
            acc = acc + 1
        end,
        ["-"] = function()
            acc = acc - 1
        end,
        ["%"] = function()
            -- goes horizontially left-or-right based off the accumulator
            -- example;
            --[[
                        ^
                >       %
                        v
            ]]
            -- if acc = 0, ++; else, --;
            if acc == 0 then
                cords.mov.pn = "+"
            else
                cords.mov.pn = "-"
            end
            if cords.mov.xy == "x" then
                cords.mov.xy = "y"
            else
                cords.mov.xy = "x"
            end
        end,
        ["&"] = function()
            -- &jump_id,
            game.db = true
            game.dh = "var"
            registers.r1 = cords.y
            registers.r2 = cords.x
        end,
        [":"] = function()
            -- :jump_id,
            game.db = true
            game.dh = "jmp"
        end,
        ["c"] = function()
            local v2 = table.remove(stack)
            local v1 = table.remove(stack)
            if v1 == v2 then
                acc = 0
            else
                acc = 1
            end
        end,
        ["def"] = function() return end
    })
end

--[[

x: 1 // y: 1 // instr: >
x: 2 // y: 1 // instr: v
x: 1 // y: 1 // instr: >
x: 1 // y: 2 // instr: ^
x: 2 // y: 2 // instr: <

]]

exec = function()
    while true do
        if logic() == 98 then break end
        -- instr move tick
        local xy = cords.mov.xy
        local pn = cords.mov.pn
        if xy == "x" then
            if pn == "+" then
                cords.x = cords.x + 1
            else
                cords.x = cords.x - 1
            end
        else
            if pn == "+" then
                cords.y = cords.y + 1
            else
                cords.y = cords.y - 1
            end
        end
    end
end

while true do
    local f = u.get(" ~$ ")
    if f == "!q" then
        break
    end
    local ff = u.getfile(f)
    init(ff)
    exec()
    map = {}
end

-- ADD PORTALS!!
