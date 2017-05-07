local lottery = {
	channel = false,
	
	entrants = {},
	jackpot = 0,
	date = math.floor(os.time()/60/60/24)
}

local client,send = false,false
function lottery:init(p,d,c,s)
	client,send = c,s
	lottery_reset()
	lottery_load()
end

function lottery:update()
	if self.date ~= math.floor(os.time()/60/60/24) then
		lottery_reset()
	end
end

function lottery:command(args,message)
	if message.channel == self.channel then
		if args[1] == "enter" then
			if not args[2] or tonumber(args[2]) and tonumber(args[2]) > 10 then
				local amount = (tonumber(args[2]) or 10)
				if not self.entrants[message.author] then 
					local balance = send("bank","balance",message.author.id)
					if balance then
						if balance >= (tonumber(args[2]) or 10) then
							if send("bank","take",message.author.id,amount) then
								self.entrants[message.author] = table.count(self.entrants)+1
								self.jackpot = self.jackpot + amount
								message:reply("**Daily Lottery:** <@"..message.author.id.."> entered with `"..amount.."P`\nThe jackpot is now `"..math.floor(self.jackpot).."P`")
							else
								message:reply("**Daily Lottery:** !")
							end
						else
							message:reply("**Daily Lottery:** You don't have enough points!")
						end
					else
						message:reply("**Daily Lottery:** You need a bank account!")
					end
				else
					message:reply("**Daily Lottery:** You're already entered!")
				end
			else
				message:reply("**Daily Lottery:** Invalid number! The minimum is 10P")
			end
		end
	end
		
	--Mod commands
	if args[1] == "here" then
		if message.member then
			for role in message.member.roles do
				if role.name == "Bot Manager" then
					self.channel = message.channel
					lottery_save()
					message:reply("**Daily Lottery** is now set up in "..self.channel.mentionString.."!")
					break
				end
			end
		end
	elseif args[1] == "reset" then
		if message.member then
			for role in message.member.roles do
				if role.name == "Bot Manager" then
					lottery_reset()
					break
				end
			end
		end
	end
	
	if args[1] == "help" then
		message:reply("**Daily Lottery** enter daily lotterys using `!lottery enter (optional amount)`!")
	end
end

function lottery_reset()
	local random = math.random(1,table.count(lottery.entrants))
	for user,count in pairs(lottery.entrants) do
		if random == count then
			send("bank","give",user.id,lottery.jackpot)
			lottery.channel:sendMessage("**Daily Lottery:** <@"..user.id.."> won the Jackpot! `+"..lottery.jackpot.."P` given.")
		end
	end
	if lottery.channel then
		lottery.channel:sendMessage("**Daily Lottery:** A new daily lottery is now running, feel free to enter!")
	end
	
	date = math.floor(os.time()/60/60/24)
	lottery.entrants = {}
	lottery.jackpot = 0
end

function lottery_save()
	local file = io.open("data/lotterylocation", "w")
	file:write(lottery.channel.id)
	file:close()
end

function lottery_load()
	local file = io.open("data/lotterylocation", "r")
	if file then
		lottery.channel = client:getChannel(file:read())
		file:close()
	end
end

return lottery