local skynet = require "skynet"
local log = require "log"

local rooms = {}

local function create(id, game)
	local conf = {id = id}
	local s = skynet.newservice(game, conf)
	skynet.call(s, "lua", "start", conf)
	return s
end

local CMD = {}

function CMD.init()
	log.log("starting hall... ")
	for i=1,50 do
		rooms[i] = {id = i, game = "chess", service = create(i, "chess")}
	end
end

function CMD.list()
	local list = {}
	for _,v in pairs(rooms) do
		table.insert(list, {id = v.id, game = v.game, service = v.service})
	end
	return list
end

skynet.start(function ()
	skynet.dispatch("lua", function (_, _, cmd, ...)
		local f = CMD[cmd]
		if f then
			skynet.ret(skynet.pack(f(...)))
		else
			skynet.ret(skynet.pack(nil, "cant find handle of "..cmd))
		end
	end)
end)
