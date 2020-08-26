function isElementInPhotograph(ele)
	local nx, ny, nz = getPedWeaponMuzzlePosition(localPlayer)
	if (ele ~= localPlayer) and (isElementOnScreen(ele)) then -- Determine whether the element is even on the screen and not the client
		local px, py, pz = getElementPosition(ele)
		local _, _, _, _, hit = processLineOfSight(nx, ny, nz, px, py, pz) -- Check if there is a collision between the "camera viewpoint" and the element
		if (hit == ele) then -- If it collides with the element return true
			return true
		end
	end
	return false
end



function isElementInRange(ele, x, y, z, range)
   if isElement(ele) and type(x) == "number" and type(y) == "number" and type(z) == "number" and type(range) == "number" then
      return getDistanceBetweenPoints3D(x, y, z, getElementPosition(ele)) <= range -- returns true if it the range of the element to the main point is smaller than (or as big as) the maximum range.
   end
   return false
end

function findRotation(x1,y1,x2,y2)
	local t = -math.deg(math.atan2(x2-x1,y2-y1))
	if t < 0 then t = t + 360 end;
	return t;
end

local controlTable = { "fire", "next_weapon", "previous_weapon", "forwards", "backwards", "left", "right", "zoom_in", "zoom_out",
 "change_camera", "jump", "sprint", "look_behind", "crouch", "action", "walk", "aim_weapon", "conversation_yes", "conversation_no",
 "group_control_forwards", "group_control_back", "enter_exit", "vehicle_fire", "vehicle_secondary_fire", "vehicle_left", "vehicle_right",
 "steer_forward", "steer_back", "accelerate", "brake_reverse", "radio_next", "radio_previous", "radio_user_track_skip", "horn", "sub_mission",
 "handbrake", "vehicle_look_left", "vehicle_look_right", "vehicle_look_behind", "vehicle_mouse_look", "special_control_left", "special_control_right",
 "special_control_down", "special_control_up" }

function getBoundControls (key)
    local controls = {}
    for _,control in ipairs(controlTable) do
        for k in pairs(getBoundKeys(control)) do
            if (k == key) then
                controls[control] = true
            end
        end
    end
    return controls
end


function getElementSpeed(element,unit)
	if (unit == nil) then unit = 0 end
	if (isElement(element)) then
		local x,y,z = getElementVelocity(element)
		if (unit=="mph" or unit==1 or unit =='1') then
			return (x^2 + y^2 + z^2) ^ 0.5 * 100
		else
			return (x^2 + y^2 + z^2) ^ 0.5 * 1.8 * 100
		end
	else
		outputDebugString("Not an element. Can't get speed")
		return false
	end
end


function getElementsWithinMarker(marker)
	if (not isElement(marker) or getElementType(marker) ~= "marker") then
		return false
	end
	return getElementsWithinColShape(getElementColShape(marker))
end
