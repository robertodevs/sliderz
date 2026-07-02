class ChannelState {
  const ChannelState({
    this.faderValue = 0.75,
    this.knobValue = 0.5,
    this.soloActive = false,
    this.muteActive = false,
    this.recordActive = false,
  });

  final double faderValue;
  final double knobValue;
  final bool soloActive;
  final bool muteActive;
  final bool recordActive;

  ChannelState copyWith({
    double? faderValue,
    double? knobValue,
    bool? soloActive,
    bool? muteActive,
    bool? recordActive,
  }) {
    return ChannelState(
      faderValue: faderValue ?? this.faderValue,
      knobValue: knobValue ?? this.knobValue,
      soloActive: soloActive ?? this.soloActive,
      muteActive: muteActive ?? this.muteActive,
      recordActive: recordActive ?? this.recordActive,
    );
  }
}
