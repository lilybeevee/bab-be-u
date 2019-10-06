local overlay = {}

local default_color = {0.25, 0.5, 1, 0.9}

overlay.open = false

overlay.confirm_boxes = {}
overlay.has_confirm_box = {}
function overlay.confirm(args)
  local confirm_id = args.id or args.text or "Confirm"
  if overlay.has_confirm_box[confirm_id] then return end
  local confirm = {}
  confirm.box = ui.component.new()
    :setColor(0.25, 0.5, 1, 0.9)
    :setFill(true)
    :setText(args.text or "Confirm")
    :setFont(ui.fonts.world_name)
    :setTextColor(1, 1, 1)
    :setWrap(true)
    :setMarginX(15)
  confirm.button_box = ui.component.new()
    :setColor(0.25, 0.5, 1, 0.9)
    :setFill(true)
  confirm.box:addChild(confirm.button_box)
  confirm.ok = ui.component.new()
    :setText(args.okText or "Ok")
    :setFont(ui.fonts.world_name)
    :setTextColor(1, 1, 1)
    :setWrap(true)
    :setMarginX(10)
    :setColor(0.275, 0.55, 1, 0.9)
    :setHoverColor(0.3, 0.6, 1, 1)
    :setActiveColor(0.225, 0.45, 1, 1)
    :setFill(true)
    :onReleased(function()
      overlay.has_confirm_box[confirm_id] = nil
      removeFromTable(overlay.confirm_boxes, confirm)
      if args.ok then args.ok() end
    end)
  confirm.button_box:addChild(confirm.ok)
  if args.cancelText or args.cancel then
    confirm.cancel = ui.component.new()
      :setText(args.cancelText or "Cancel")
      :setFont(ui.fonts.world_name)
      :setTextColor(1, 1, 1)
      :setWrap(true)
      :setMarginX(10)
      :setColor(0.275, 0.55, 1, 0.9)
      :setHoverColor(0.3, 0.6, 1, 1)
      :setActiveColor(0.225, 0.45, 1, 1)
      :setFill(true)
      :onReleased(function()
        overlay.has_confirm_box[confirm_id] = nil
        removeFromTable(overlay.confirm_boxes, confirm)
        if args.cancel then args.cancel() end
      end)
    confirm.button_box:addChild(confirm.cancel)
  end
  overlay.resizeConfirm(confirm)
  overlay.has_confirm_box[confirm_id] = true
  table.insert(overlay.confirm_boxes, confirm)
end

function overlay.rebuild()
  overlay.darken = ui.component.new()
    :setColor(0, 0, 0, 0.5)
    :setFill(true)
    :setSize(love.graphics.getWidth(), love.graphics.getHeight())
  for _,confirm in ipairs(overlay.confirm_boxes) do
    overlay.resizeConfirm(confirm)
  end
end

function overlay.resizeConfirm(confirm)
  local confirm_width = 800 * 0.5
  local confirm_height = 600 * (1/3)

  local confirm_btn_height = confirm_height * (1/3)
  local confirm_btn_width = confirm_width / 2

  local confirm_x = love.graphics.getWidth() / 2 - confirm_width / 2
  local confirm_y = love.graphics.getHeight() / 2 - confirm_height / 2 - confirm_btn_height / 2

  confirm.box:setPos(confirm_x, confirm_y):setSize(confirm_width, confirm_height)
  confirm.button_box:setPos(0, confirm_height):setSize(confirm_width, confirm_btn_height + 4)

  if confirm.cancel then
    confirm.cancel:setX(4):setSize(confirm_btn_width - 4, confirm_btn_height)
    confirm.ok:setX(confirm_btn_width + 4):setSize(confirm_btn_width - 4, confirm_btn_height)
  else
    confirm.ok:setX(confirm_x + 4):setSize(confirm_width - 4, confirm_btn_height)
  end
end

function overlay.draw()
  overlay.open = #overlay.confirm_boxes > 0
  if overlay.open then
    overlay.darken:draw()
    if not ui.selecting then
      ui.selecting = true
      local confirm = overlay.confirm_boxes[#overlay.confirm_boxes]
      if confirm then
        ui.select(confirm.ok)
      end
    end
  end
  local confirm = overlay.confirm_boxes[#overlay.confirm_boxes]
  if confirm then
    confirm.box:draw()
  end
end

function overlay.close(yes)
  local confirm
  for _,v in pairs(overlay.confirm_boxes) do
    confirm = v
  end
  if confirm then
    if confirm.cancel and not yes then
      confirm.cancel:call(confirm.cancel.on_released, 1)
    else
      confirm.ok:call(confirm.ok.on_released, 1)
    end
  end
end

return overlay