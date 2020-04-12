require "sqlite3"
require "discordcr"

# discordcr is missing joined_at in GUILD_CREATE.
# this is just a patch that adds it.
require "./discordcr_ext"

Log.setup_from_env

AppLog = Log.for("log")

AppLog.info { "configuring database" }
sqlite = DB.open("sqlite3://data.db").tap do |db|
  db.exec("PRAGMA journal_mode = WAL")
  db.exec(<<-SQL)
  CREATE TABLE IF NOT EXISTS logs (
      id        INTEGER PRIMARY KEY NOT NULL,
      timestamp TEXT                NOT NULL,
      guild_id  TEXT,
      joined_at TEXT,
      user_id   TEXT                NOT NULL,
      command   TEXT                NOT NULL,
      arguments TEXT                NOT NULL
  )
  SQL
end

owner_id = Discord::Snowflake.new(ENV["OWNER_ID"])

client = Discord::Client.new(
  ENV["DISCORD_TOKEN"],
  intents: Discord::Gateway::Intents.flags(Guilds, GuildMessages, DirectMessages),
)

client.on_ready do |payload|
  AppLog.info { "Connected to #{payload.guilds.size} guilds" }
end

guild_join_time = Hash(Discord::Snowflake, Time?).new
client.on_guild_create do |payload|
  AppLog.info { "guild_create: #{payload.id} (#{payload.joined_at || "null"})" }
  guild_join_time[payload.id] = payload.joined_at
end

client.on_message_create do |payload|
  if payload.content.match(/^~[a-z]/)
    command, _, arguments = payload.content.partition(' ')
    AppLog.info { "#{payload.guild_id || "(dm)"} #{command}" }

    if guild_id = payload.guild_id
      joined_at = guild_join_time[guild_id]?
    end

    sqlite.exec(
      "INSERT INTO logs (timestamp, guild_id, joined_at, user_id, command, arguments) VALUES (?, ?, ?, ?, ?, ?)",
      Time.local, payload.guild_id.try(&.to_s), joined_at, payload.author.id.to_s, command, arguments
    )
  end

  if payload.author.id == owner_id && payload.content == "!stop"
    AppLog.info { "stopping" }
    client.stop
    sqlite.close
  end
end

AppLog.info { "starting discord client" }
client.run
