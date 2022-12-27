local M = {}

M.VANTAGE_W       = hash("VANTAGE_W")
M.VANTAGE_S       = hash("VANTAGE_S")
M.VANTAGE_A       = hash("VANTAGE_A")
M.VANTAGE_D       = hash("VANTAGE_D")
M.VANTAGE_Q       = hash("VANTAGE_Q")
M.VANTAGE_E       = hash("VANTAGE_E")
M.VANTAGE_MOUSE_1 = hash("VANTAGE_MOUSE_1")
M.VANTAGE_MOUSE_2 = hash("VANTAGE_MOUSE_2")
M.VANTAGE_MOUSE_3 = hash("VANTAGE_MOUSE_3")

M.VANTAGE_TYPE_WASD    = 0
M.VANTAGE_TYPE_ORBITAL = 1

local function move_forward(camera)
	camera.forward = camera.forward - camera.movement_speed
end

local function move_backward(camera)
	camera.forward = camera.forward + camera.movement_speed
end

local function move_up(camera)
	camera.up = camera.up + camera.movement_speed
end

local function move_down(camera)
	camera.up = camera.up - camera.movement_speed
end

local function strafe_left(camera)
	camera.sidestep = camera.sidestep - camera.movement_speed
end

local function strafe_right(camera)
	camera.sidestep = camera.sidestep + camera.movement_speed
end

local function rotate(camera, yaw, pitch)
	camera.yaw   = camera.yaw - yaw * camera.rotation_speed
	camera.pitch = camera.pitch + pitch * camera.rotation_speed
end

M.wasd = {
	on_update = function(self, dt)
		local main_camera_position = go.get_world_position(self.id)
		local forward_vec 		   = vmath.vector3(0,0,1)
		local side_vec             = vmath.vector3(1, 0, 0)

		local camera_yaw           = vmath.quat_rotation_y(math.rad(self.yaw))
		local camera_pitch         = vmath.quat_rotation_x(math.rad(self.pitch))
		local camera_rot           = camera_yaw * camera_pitch

		local forward_scaled       = self.forward * dt
		local sidestep_scaled      = self.sidestep * dt
		local up_scaled            = self.up * dt

		forward_vec = vmath.rotate(camera_rot, forward_vec)
		forward_vec = forward_vec * forward_scaled

		side_vec = vmath.rotate(camera_rot, side_vec)
		side_vec = side_vec * sidestep_scaled
		local new_pos = main_camera_position + forward_vec + side_vec
		new_pos.y = new_pos.y + up_scaled

		go.set_position(new_pos, self.id)
		go.set_rotation(camera_rot, self.id)

		self.forward  = 0
		self.sidestep = 0
		self.up       = 0
	end,
	on_input = function(self, action_id, action)
		if action_id == hash(M.VANTAGE_W) then
			move_forward(self)
		elseif action_id == hash(M.VANTAGE_S) then
			move_backward(self)
		elseif action_id == hash(M.VANTAGE_A) then
			strafe_left(self)
		elseif action_id == hash(M.VANTAGE_D) then
			strafe_right(self)
		elseif action_id == hash(M.VANTAGE_Q) then
			move_down(self)
		elseif action_id == hash(M.VANTAGE_E) then
			move_up(self)
		elseif action_id == hash(M.VANTAGE_MOUSE_1) then
			rotate(self, action.dx, action.dy)
		end
	end
}
M.orbital = {
	on_update = function(self, dt)
		local camera_yaw           = vmath.quat_rotation_y(math.rad(self.yaw))
		local camera_pitch         = vmath.quat_rotation_x(math.rad(self.pitch))
		local camera_rot           = camera_yaw * camera_pitch
		local camera_position      = vmath.rotate(camera_rot, vmath.vector3(0, 0, self.zoom + self.zoom_offset))
		go.set_position(camera_position, main_camera)
		go.set_rotation(camera_rot, self.id)
	end,
	on_input = function(self, action_id, action)
		if action_id == hash(M.VANTAGE_MOUSE_1) then
			rotate(self, action.dx, action.dy)
		elseif action_id == hash(M.VANTAGE_MOUSE_2) then
			self.zoom_offset = self.zoom_offset + action.dy * self.movement_speed
		end
	end
}

return M