function love.load()
    moveTime = 0.15
    cellSize = 20
    gridXCount = 40
    gridYCount = 30
    debugMode = false

    function moveFood()
        local possibleFoodPositions = {}
        
        -- Loops over all valid grid cells
        for foodX = 1, gridXCount do
            for foodY = 1, gridYCount do
                local possible = true

                -- Loops over all of the snake segments
                for segmentIndex, segment in ipairs(snakeSegments) do
                    if foodX == segment.x and foodY == segment.y then
                        possible = false
                    end
                end

                -- Only free cells are added to the possibleFoodPositions table
                if possible then
                    table.insert(possibleFoodPositions, {x = foodX, y = foodY})
                end
            end
        end

        -- A random food position is picked from the table of possibleFoodPositions
        foodPosition = possibleFoodPositions[love.math.random(#possibleFoodPositions)]
    end

    function reset()
        snakeSegments = {
            {x = 3, y = 1},
            {x = 2, y = 1},
            {x = 1, y = 1},
        }
        directionQueue = {'right'}
        snakeAlive = true
        timer = 0
        moveFood()
    end

    reset()

end

function love.update(dt)
    -- dt is the time that has elapsed between each frame.
    timer = timer + dt
    if snakeAlive then
        if timer >= moveTime then
            timer = 0
    
            if #directionQueue > 1 then
                table.remove(directionQueue, 1)
            end
    
            -- Grabs copy of original head
            local nextXPosition = snakeSegments[1].x
            local nextYPosition = snakeSegments[1].y
    
            -- Move snake (handle moving through grid)
            if directionQueue[1] == 'right' then
                nextXPosition = nextXPosition + 1
                if nextXPosition > gridXCount then
                    nextXPosition = 1
                end
            elseif directionQueue[1] == 'left' then
                nextXPosition = nextXPosition - 1
                if nextXPosition < 1 then
                    nextXPosition = gridXCount
                end
            elseif directionQueue[1] == 'down' then
                nextYPosition = nextYPosition + 1
                if nextYPosition > gridYCount then
                    nextYPosition = 1
                end
            else
                nextYPosition = nextYPosition - 1
                if nextYPosition < 1 then
                    nextYPosition = gridYCount
                end
            end
    
            local canMove = true
            
            -- Loop through snake segments to see if snake is crashing (except tail)
            for segmentIndex, segment in ipairs(snakeSegments) do
                if segmentIndex ~= snakeSegments 
                and nextXPosition == segment.x 
                and nextYPosition == segment.y then
                    canMove = false
                end
            end
            
            if canMove then
                -- Inserts a new square as the new head
                table.insert(snakeSegments, 1, {
                    x = nextXPosition,
                    y = nextYPosition
                })
    
                if snakeSegments[1].x == foodPosition.x and snakeSegments[1].y == foodPosition.y then
                    -- If new head is eating the food, then generate new food
                    moveFood()
                else
                    -- Remove tail of the snake
                    table.remove(snakeSegments)
                end
            else
                snakeAlive = false
            end
        end
    elseif timer >= 2 then
        reset()
    end
end

function love.keypressed(key)
    -- Switch directions and prevent going backwards or adding existing direction to end of queue
    if (key == 'right' and directionQueue[#directionQueue] ~= 'left' and directionQueue[#directionQueue] ~= 'right')
    or (key == 'left' and directionQueue[#directionQueue] ~= 'right' and directionQueue[#directionQueue] ~= 'left')
    or (key == 'down' and directionQueue[#directionQueue] ~= 'up' and directionQueue[#directionQueue] ~= 'down')
    or (key == 'up' and directionQueue[#directionQueue] ~= 'down' and directionQueue[#directionQueue] ~= 'up') then
        table.insert(directionQueue, key)
    end
end

function love.draw()
    local function drawCell(x, y, colorTable)
        love.graphics.setColor(colorTable[1], colorTable[2], colorTable[3])
        love.graphics.rectangle(
            'fill',
            (x - 1) * cellSize,
            (y - 1) * cellSize,
            cellSize - 1,
            cellSize - 1
        )
    end

    -- Grid
    love.graphics.setColor(.28, .28, .28) -- Gray
    love.graphics.rectangle(
        'fill',
        0,
        0,
        gridXCount * cellSize,
        gridYCount * cellSize
    )

    -- Snake
    for segmentIndex, segment in ipairs(snakeSegments) do
        local snakeColor = {0.6, 1, 0.32} -- Green

        if not snakeAlive then
            snakeColor = {0.5, 0.5, 0.5}
        end

        drawCell(segment.x, segment.y, snakeColor)
    end

    -- Food
    drawCell(foodPosition.x, foodPosition.y, {1, 0.3, 0.3})

    if debugMode then
        -- Direction Queue
        for directionIndex, direction in ipairs(directionQueue) do
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(
                'directionQueue['..directionIndex..']: '..direction,
                15, 15 * directionIndex
            )
        end
    end
end