import discord
import anthropic
import os

DISCORD_BOT_TOKEN = os.getenv(“DISCORD_BOT_TOKEN”)
ANTHROPIC_API_KEY = os.getenv(“ANTHROPIC_API_KEY”)

if not DISCORD_BOT_TOKEN:
raise ValueError(“Missing DISCORD_BOT_TOKEN in secrets!”)
if not ANTHROPIC_API_KEY:
raise ValueError(“Missing ANTHROPIC_API_KEY in secrets!”)

intents = discord.Intents.default()
intents.message_content = True
intents.members = True

client = discord.Client(intents=intents)
anthropic_client = anthropic.Anthropic(api_key=ANTHROPIC_API_KEY)

def split_message(text, limit=1900):
return [text[i:i+limit] for i in range(0, len(text), limit)]

@client.event
async def on_ready():
print(“Bot is online as “ + str(client.user))

@client.event
async def on_message(message):
if message.author.bot:
return

```
if client.user not in message.mentions:
    return

prompt = message.content.replace("<@" + str(client.user.id) + ">", "").replace("<@!" + str(client.user.id) + ">", "").strip()

if not prompt:
    await message.reply("Mention me with a request! Example: @Eybrq Bot make me a fly gui")
    return

thinking_msg = await message.reply("Generating your Lua script... I will DM it to you shortly!")

try:
    response = anthropic_client.messages.create(
        model="claude-sonnet-4-20250514",
        max_tokens=2048,
        system="You are Eybrq Bot, an expert Lua scripter for Roblox. When given a request, write clean working Lua scripts for Roblox. Always include helpful comments. Format your response as: 1. A short description of what the script does. 2. The full Lua code in a code block. 3. Brief instructions on how to use it.",
        messages=[
            {"role": "user", "content": prompt}
        ]
    )

    lua_script = "\n".join(block.text for block in response.content if block.type == "text")

    try:
        dm_channel = await message.author.create_dm()
        header = "Here is your Lua script for: " + prompt + "\n\n"
        full_message = header + lua_script

        if len(full_message) <= 2000:
            await dm_channel.send(full_message)
        else:
            await dm_channel.send("Here is your Lua script for: " + prompt)
            for chunk in split_message(lua_script):
                await dm_channel.send(chunk)

        await thinking_msg.edit(content="Done " + message.author.mention + "! Your Lua script has been sent to your DMs!")

    except discord.Forbidden:
        await thinking_msg.edit(content="I could not DM you " + message.author.mention + " so here is your script:")
        for chunk in split_message(lua_script):
            await message.channel.send(chunk)

except Exception as e:
    print("Error: " + str(e))
    await thinking_msg.edit(content="Something went wrong, please try again!")
```

client.run(DISCORD_BOT_TOKEN)