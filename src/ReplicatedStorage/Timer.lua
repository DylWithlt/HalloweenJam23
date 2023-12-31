local module = {
	timerQueue = {},
}

local RUN_SERVICE = game:GetService("RunService")

module.new = function(self, timerName, waitTime, Function, ...)
	local queue = self

	if not timerName then
		timerName = #queue + 1
	end

	if queue.timerQueue[timerName] then
		return
	end

	local timer = {
		Connection = nil,
		CallTime = os.clock(),
		WaitTime = waitTime,
		["Function"] = Function,
		Parameters = { ... },
	}

	function timer:Run()
		if self.Connection then
			return
		end

		self.CallTime = os.clock()
		self.Connection = RUN_SERVICE.Heartbeat:Connect(function()
			if os.clock() - self.CallTime < self.WaitTime then
				return
			end

			self.Connection:Disconnect()
			self.Connection = nil
			self.Function(table.unpack(self.Parameters))
		end)
	end

	function timer:Reset()
		self.CallTime = os.clock()
	end

	function timer:Delay(amount)
		self.CallTime = os.clock() - amount
	end

	function timer:Update(index, value)
		self[index] = value
	end

	function timer:UpdateFunction(value, ...)
		self["Function"] = value
		self["Parameters"] = ...
	end

	function timer:Cancel()
		if not self.Connection then
			return
		end
		self.Connection:Disconnect()
	end

	function timer:Destroy()
		if self.Connection then
			self.Connection:Disconnect()
		end

		queue.timerQueue[timerName] = nil
	end

	function timer:GetCurrentTime()
		return os.clock() - self.CallTime
	end

	queue.timerQueue[timerName] = timer
	return queue.timerQueue[timerName]
end

function module:newQueue()
	return {
		timerQueue = {},
		new = module["new"],
	}
end

function module:getStopwatch(timerName)
	return self[timerName]
end

return module
