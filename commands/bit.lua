local bit = {
	category = "Chat",
	description = "Answers all your yes/no questions."
}

function bit:command(args,message)
	message:reply(math.random(1,2) == 1 and "Yes." or "No.")
end

return bit