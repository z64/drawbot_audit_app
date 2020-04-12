module Discord::Gateway
  struct GuildCreatePayload
    JSON.mapping(
      id: Snowflake,
      name: String,
      icon: String?,
      splash: String?,
      owner_id: Snowflake,
      region: String,
      afk_channel_id: Snowflake?,
      afk_timeout: Int32?,
      verification_level: UInt8,
      roles: Array(Role),
      emoji: {type: Array(Emoji), key: "emojis"},
      features: Array(String),
      large: Bool,
      voice_states: Array(VoiceState),
      unavailable: Bool?,
      member_count: Int32,
      members: Array(GuildMember),
      channels: Array(Channel),
      presences: Array(Presence),
      widget_channel_id: Snowflake?,
      default_message_notifications: UInt8,
      explicit_content_filter: UInt8,
      system_channel_id: Snowflake?,
      joined_at: {type: Time?, converter: MaybeTimestampConverter}
    )
  end
end
