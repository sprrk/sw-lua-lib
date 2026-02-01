---@meta

---@return nil
function onTick() end

---@return nil
function onDraw() end

---@param port integer
---@param url string
---@param response_body any
---@return nil
function httpReply(port, url, response_body) end

---@table input
input = {}

---@param index number
---@return boolean
function input.getBool(index) end

---@param index number
---@return number
function input.getNumber(index) end

---@table output
output = {}

---@param index number
---@param value boolean
---@return nil
function output.setBool(index, value) end

---@param index number
---@param value number
---@return nil
function output.setNumber(index, value) end

---@table property
property = {}

---@param label string
---@return boolean
function property.getBool(label) end

---@param label string
---@return number
function property.getNumber(label) end

---@param label string
---@return string
function property.getText(label) end

---@table screen
screen = {}

---@param x number
---@param y number
---@param radius number
---@return nil
function screen.drawCircle(x, y, radius) end

---@param x number
---@param y number
---@param radius number
---@return nil
function screen.drawCircleF(x, y, radius) end

---@return nil
function screen.drawClear() end

---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@return nil
function screen.drawLine(x1, y1, x2, y2) end

---@param x number
---@param y number
---@param zoom number
---@return nil
function screen.drawMap(x, y, zoom) end

---@param x number
---@param y number
---@param width number
---@param height number
---@return nil
function screen.drawRect(x, y, width, height) end

---@param x number
---@param y number
---@param width number
---@param height number
---@return nil
function screen.drawRectF(x, y, width, height) end

---@param x number
---@param y number
---@param text string
---@return nil
function screen.drawText(x, y, text) end

---@param x number
---@param y number
---@param width number
---@param height number
---@param text string
---@param h_align number
---@param v_align number
---@return nil
function screen.drawTextBox(x, y, width, height, text, h_align, v_align) end

---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@param x3 number
---@param y3 number
---@return nil
function screen.drawTriangle(x1, y1, x2, y2, x3, y3) end

---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@param x3 number
---@param y3 number
---@return nil
function screen.drawTriangleF(x1, y1, x2, y2, x3, y3) end

---@return number
function screen.getHeight() end

---@return number
function screen.getWidth() end

---@param r number
---@param g number
---@param b number
---@param a number
---@return nil
function screen.setColor(r, g, b, a) end

---@param r number
---@param g number
---@param b number
---@param a number
---@return nil
function screen.setMapColorGrass(r, g, b, a) end

---@param r number
---@param g number
---@param b number
---@param a number
---@return nil
function screen.setMapColorGravel(r, g, b, a) end

---@param r number
---@param g number
---@param b number
---@param a number
---@return nil
function screen.setMapColorLand(r, g, b, a) end

---@param r number
---@param g number
---@param b number
---@param a number
---@return nil
function screen.setMapColorOcean(r, g, b, a) end

---@param r number
---@param g number
---@param b number
---@param a number
---@return nil
function screen.setMapColorRock(r, g, b, a) end

---@param r number
---@param g number
---@param b number
---@param a number
---@return nil
function screen.setMapColorSand(r, g, b, a) end

---@param r number
---@param g number
---@param b number
---@param a number
---@return nil
function screen.setMapColorShallows(r, g, b, a) end

---@param r number
---@param g number
---@param b number
---@param a number
---@return nil
function screen.setMapColorSnow(r, g, b, a) end

---@table async
async = {}

---@param port integer
---@param url string
---@return nil
function async.httpGet(port, url) end

---@table map
map = {}

---@param mapX number
---@param mapY number
---@param screenW number
---@param screenH number
---@param worldX number
---@param worldY number
---@return number screenX, number screenY
function map.mapToScreen(mapX, mapY, zoom, screenW, screenH, worldX, worldY) end

---@param mapX number
---@param mapY number
---@param screenW number
---@param screenH number
---@param pixelX number
---@param pixelY number
---@return number worldX, number worldY
function map.screenToMap(mapX, mapY, zoom, screenW, screenH, pixelX, pixelY) end
