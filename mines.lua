-- Creeper Sweeper

-- Config constants
local screen_x = 10
local screen_y = 10
local mines = 13

-- Some gameplay variables
local gameplay
local won
local uncovered

-- Generate empty field
local field = {}
local function gen_field()
  for i = 1, screen_x do
    field[i] = {}
    for j = 1, screen_y do
      field[i][j] = " "
    end
  end
end

-- Generate random mines
math.randomseed(os.time())
math.random(); math.random(); math.random()

local function gen_mines()
  local mine_x = 0
  local mine_y = 0

  for i = 1, mines do
    mine_x = math.floor((math.random() * 1000) % screen_x) + 1
    mine_y = math.floor((math.random() * 1000) % screen_y) + 1

    while field[mine_x][mine_y] == "M" do
      mine_x = math.floor((math.random() * 1000) % screen_x) + 1
      mine_y = math.floor((math.random() * 1000) % screen_y) + 1
    end

    field[mine_x][mine_y] = "M"
  end
end

-- Add adjacent mine counts to empty squares
local function gen_nums()
  local function check_mine(cx, cy)
    if field[cx][cy] == "M" then
      return 1
    else
      return 0
    end
  end

  for x = 1, screen_x do
    for y = 1, screen_y do
    
      local adj_mines = 0
    
      if field[x][y] == " " then
        if x > 1 then
          adj_mines = adj_mines + check_mine(x-1, y)
          
          if y > 1 then
            adj_mines = adj_mines + check_mine(x-1, y-1)
          end
          if y < screen_y then
            adj_mines = adj_mines + check_mine(x-1, y+1)
          end 
        end
        
        if x < screen_x then
          adj_mines = adj_mines + check_mine(x+1, y)
          
          if y > 1 then
            adj_mines = adj_mines + check_mine(x+1, y-1)
          end
          if y < screen_y then
            adj_mines = adj_mines + check_mine(x+1, y+1)
          end
        end

        if y > 1 then
          adj_mines = adj_mines + check_mine(x, y-1)
        end
        if y < screen_y then
          adj_mines = adj_mines + check_mine(x, y+1)
        end
        
        field[x][y] = tostring(adj_mines)
        if tostring(adj_mines) == "0" then
          field[x][y] = " "
        end
      end
    end
  end
end

-- Generate graphics array
local graph = {}
local function gen_graph()
  for x = 1, screen_x do
    graph[x] = {}
    for y = 1, screen_y do
      graph[x][y] = "#"
    end
  end
end

-- Render playfield
local function draw()
  shell.run("clear")
  for y = 1, screen_y do
    for x = 1, screen_x do
      -- Colors    
      local sign = graph[x][y]
      if sign == "#" then
        term.setTextColor(colors.white)
      elseif sign == "M" then
        if won then
          term.setTextColor(colors.lime)
        else
          term.setTextColor(colors.red)
        end
      elseif sign == "?" then
        term.setTextColor(colors.magenta)
      elseif sign == "1" then
        term.setTextColor(colors.blue)
      elseif sign == "2" then
        term.setTextColor(colors.green)
      elseif sign == "3" then
        term.setTextColor(colors.orange)
      elseif sign == "4" then
        term.setTextColor(colors.cyan)
      elseif sign == "5" then
        term.setTextColor(colors.brown)
      elseif sign == "6" then
        term.setTextColor(colors.purple)
      elseif sign == "7" then
        term.setTextColor(colors.lime)
      elseif sign == "8" then
        term.setTextColor(colors.yellow)
      end
      term.write(sign)
    end
    print("")
  end
  term.setTextColor(colors.white)
  print("Tiles left: ", screen_x * screen_y - mines - uncovered)
  if gameplay then
    print("Press Q to quit")
  end
end

-- Uncover all function
local function uncover_all()
  for i = 1, screen_x do
    for j = 1, screen_y do
      graph[i][j] = field[i][j]
    end
  end
  draw()
end

-- Uncover function
local function uncover(x, y)

  -- Generate mines and numbers on first click
  if uncovered == 0 then
    local generating = true
    while generating do
      gen_field()
      gen_mines()
      gen_nums()
      if field[x][y] ~= "M" then
        generating = false
      end
    end
  end

  graph[x][y] = field[x][y]
  if graph[x][y] == "M" then
    gameplay = false
  else
    uncovered = uncovered + 1
    if uncovered == screen_x * screen_y - mines then
      won = true
      gameplay = false
    elseif graph[x][y] == " " then
      -- Copy of uncover adjacent cuz idk how to do it else
      if x > 1 then
        if graph[x-1][y] == "#" then
          uncover(x-1, y)
        end
    
        if y > 1 then
          if graph[x-1][y-1] == "#" then
            uncover(x-1, y-1)
          end
        end
        if y < screen_y then
          if graph[x-1][y+1] == "#" then
            uncover(x-1, y+1)
          end
        end 
      end
      
      if x < screen_x then
        if graph[x+1][y] == "#" then
          uncover(x+1, y)
        end
        
        if y > 1 then
          if graph[x+1][y-1] == "#" then
            uncover(x+1, y-1)
          end
        end
        if y < screen_y then
          if graph[x+1][y+1] == "#" then
            uncover(x+1, y+1)
          end
        end
      end
    end
  end
end

-- Uncover adjacent function
local function uncover_adj(x, y)
  if x > 1 then
    if graph[x-1][y] == "#" then
      uncover(x-1, y)
    end
    
    if y > 1 then
      if graph[x-1][y-1] == "#" then
        uncover(x-1, y-1)
      end
    end
    if y < screen_y then
      if graph[x-1][y+1] == "#" then
        uncover(x-1, y+1)
      end
    end 
  end
      
  if x < screen_x then
    if graph[x+1][y] == "#" then
      uncover(x+1, y)
    end
        
    if y > 1 then
      if graph[x+1][y-1] == "#" then
        uncover(x+1, y-1)
      end
    end
    if y < screen_y then
      if graph[x+1][y+1] == "#" then
        uncover(x+1, y+1)
      end
    end
  end

  if y > 1 then
    if graph[x][y-1] == "#" then
      uncover(x, y-1)
    end
  end
  if y < screen_y then
    if graph[x][y+1] == "#" then
      uncover(x, y+1)
    end
  end
end  

-- Gameplay loop
while true do
  gen_graph()

  gameplay = true
  won = false
  uncovered = 0

  draw()
  while gameplay do
    -- Get mouse clicks
    local event, button, mouse_x, mouse_y = os.pullEvent()
    if event == "mouse_click" then
      if mouse_x <= screen_x and mouse_y <= screen_y then        
        -- Right click
        if button == 2 then
          if graph[mouse_x][mouse_y] == "#" then
            graph[mouse_x][mouse_y] = "?"
          elseif graph[mouse_x][mouse_y] == "?" then
            graph[mouse_x][mouse_y] = "#"
          else
         	  uncover_adj(mouse_x, mouse_y)
          end
        end      
        
        -- Left click
        if button == 1 then
          uncover(mouse_x, mouse_y)
        end
      end
    -- Get keyboard click for "q"
    elseif event == "key" and button == keys.q then
      shell.run("clear")
      return -- Exit program
    end
    
    draw()
  
  end

  -- End text
  uncover_all()
  if won then
    term.setTextColor(colors.lime)
    print("You Win!")
  else
    term.setTextColor(colors.red)
    print("Game Over")
  end

  term.setTextColor(colors.white)
  print("Press any key to play again")
  event = ""

  while not (event == "key" or event == "mouse_click") do
    event, button = os.pullEvent()
  end
end
