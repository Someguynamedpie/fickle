local function insert_rect(node, w, h)
	if node.left and node.right then
		return insert_rect(node.left, w, h) or insert_rect(node.right, w, h)
	elseif not node.used and (node.w >= w and node.h >= h) then		
		if w == node.w and h == node.h then
			node.used = true
			return node
		end
			
		if node.w - w > node.h - h then
			node.left = {
				x = node.x, 
				y = node.y, 
				w = w, 
				h = node.h
			}
			node.right = {
				x = node.x + w, 
				y = node.y, 
				w = node.w - w, 
				h = node.h,
			}
		else
			node.left = {
				x = node.x, 
				y = node.y, 
				w = node.w, 
				h = h
			}
			node.right = {
				x = node.x, 
				y = node.y + h, 
				w = node.w, 
				h = node.h - h
			}
		end
		
		return insert_rect(node.left, w, h)
	end
end

local meta = {}
meta.__index = meta


function CreateAtlas(page_width, page_height)
	page_height = page_height or page_width
	return setmetatable({
		pages = {}, 
		textures = {}, 
		width = page_width, 
		height = page_height,
	}, meta)
end

function meta:findFreePage(w, h)
	w = w
	h = h
	
	for _, page in ipairs(self.pages) do
		local found = insert_rect(page.tree, w, h)
		if found then
			return page, found
		end
	end
	
	local tree = {x = 0, y = 0, w = self.width, h = self.height}
	local node = insert_rect(tree, w, h)
	
	if node then
		local page = { 
			textures = {}, 
			tree = tree,
		}

		table.insert(self.pages, page)
		
		return page, node
	end
end