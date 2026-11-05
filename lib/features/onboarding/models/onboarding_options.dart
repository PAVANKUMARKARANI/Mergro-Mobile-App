/// Countries Mergro operates in; drives time zones, lead sources, calling
/// windows and compliance copy.
enum Country {
  /// India (TRAI DND rules).
  india('India', 'en-IN'),

  /// United States (TCPA rules).
  unitedStates('United States', 'en-US');

  /// Creates a country with its display name and speech accent.
  const Country(this.label, this.speechLocale);

  /// Display name.
  final String label;

  /// Text-to-speech locale for voice previews.
  final String speechLocale;
}

/// Calendar integrations available for viewings.
enum CalendarProvider {
  /// Google Calendar.
  google('Google Calendar', 'Sync viewings with Google Workspace calendars.'),

  /// Microsoft Outlook.
  outlook('Microsoft Outlook', 'Sync viewings with Outlook / Microsoft 365.');

  /// Creates a provider with its card copy.
  const CalendarProvider(this.label, this.description);

  /// Card title.
  final String label;

  /// Card description.
  final String description;
}

/// Telephony providers for the AI calling line.
enum TelephonyProvider {
  /// Twilio — global coverage.
  twilio('Twilio', 'Global coverage, US and Indian numbers'),

  /// Exotel — India-first, DND-aware.
  exotel('Exotel', 'Indian numbers, DND-aware routing');

  /// Creates a provider with its card copy.
  const TelephonyProvider(this.label, this.description);

  /// Card title.
  final String label;

  /// Card subtitle.
  final String description;
}

/// Where the calling number comes from.
enum NumberSource {
  /// Buy a new number through the provider.
  newNumber('Get a new number'),

  /// Port / verify a number the brokerage already owns.
  existing('Use my existing number');

  /// Creates a source with its label.
  const NumberSource(this.label);

  /// Option label.
  final String label;
}

/// AI agent voices. Previews use device text-to-speech for now.
enum AgentVoice {
  /// Warm female voice.
  warmFemale('Warm female', 'Friendly and reassuring', 1.1, 0.48),

  /// Calm male voice.
  calmMale('Calm male', 'Measured and confident', 0.75, 0.44),

  /// Bright female voice.
  brightFemale('Bright female', 'Upbeat and energetic', 1.35, 0.55);

  /// Creates a voice with its card copy and preview tuning.
  const AgentVoice(this.label, this.description, this.pitch, this.speechRate);

  /// Card title.
  final String label;

  /// Card subtitle.
  final String description;

  /// Text-to-speech pitch (1.0 = device default) that approximates the
  /// voice until real AI voice samples exist.
  final double pitch;

  /// Text-to-speech rate (0.5 = normal on flutter_tts).
  final double speechRate;
}
