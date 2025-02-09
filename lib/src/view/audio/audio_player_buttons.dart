// ignore_for_file: prefer_final_fields, must_be_immutable, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:telesmile/src/constants/loggers.dart';

class PlayerButtons extends StatefulWidget {
  PlayerButtons(this._audioPlayer, {Key? key}) : super(key: key);

  late AudioPlayer _audioPlayer;
  @override
  State<PlayerButtons> createState() => _PlayerButtonsState();
}

class _PlayerButtonsState extends State<PlayerButtons> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreamBuilder<bool>(
          stream: widget._audioPlayer.shuffleModeEnabledStream,
          builder: (context, snapshot) {
            return _shuffleButton(context, snapshot.data ?? false);
          },
        ),
        StreamBuilder<SequenceState?>(
          stream: widget._audioPlayer.sequenceStateStream,
          builder: (_, __) {
            return _previousButton();
          },
        ),
        StreamBuilder<PlayerState>(
          stream: widget._audioPlayer.playerStateStream,
          builder: (_, snapshot) {
            final playerState = snapshot.data!;
            return _playPauseButton(playerState);
          },
        ),
        StreamBuilder<SequenceState?>(
          stream: widget._audioPlayer.sequenceStateStream,
          builder: (_, __) {
            return _nextButton();
          },
        ),
        StreamBuilder<LoopMode>(
          stream: widget._audioPlayer.loopModeStream,
          builder: (context, snapshot) {
            return _repeatButton(context, snapshot.data ?? LoopMode.off);
          },
        ),
      ],
    );
  }

  Widget _playPauseButton(PlayerState playerState) {
    // logger.i("Play Pasue button called");
    final processingState = playerState.processingState;
    // widget._audioPlayer.playing = true;
    if (processingState == ProcessingState.loading ||
        processingState == ProcessingState.buffering) {
      return Container(
        margin: const EdgeInsets.all(8.0),
        width: 64.0,
        height: 64.0,
        child: const CircularProgressIndicator(),
      );
    } else if (processingState == ProcessingState.ready) {
      widget._audioPlayer.play();
      return IconButton(
        icon: const Icon(Icons.pause),
        iconSize: 64.0,
        onPressed: widget._audioPlayer.pause,
      );
    } else if (widget._audioPlayer.playing != true) {
      return IconButton(
        icon: const Icon(Icons.play_arrow),
        iconSize: 64.0,
        onPressed: widget._audioPlayer.play,
      );
    } else if (processingState != ProcessingState.completed) {
      return IconButton(
        icon: const Icon(Icons.pause),
        iconSize: 64.0,
        onPressed: widget._audioPlayer.pause,
      );
    } else {
      return IconButton(
        icon: const Icon(Icons.replay),
        iconSize: 64.0,
        onPressed: () => widget._audioPlayer.seek(Duration.zero,
            index: widget._audioPlayer.effectiveIndices!.first),
      );
    }
  }

  Widget _shuffleButton(BuildContext context, bool isEnabled) {
    return IconButton(
      icon: isEnabled
          ? Icon(Icons.shuffle, color: Theme.of(context).accentColor)
          : const Icon(Icons.shuffle),
      onPressed: () async {
        final enable = !isEnabled;
        if (enable) {
          await widget._audioPlayer.shuffle();
        }
        await widget._audioPlayer.setShuffleModeEnabled(enable);
      },
    );
  }

  Widget _previousButton() {
    return IconButton(
      icon: const Icon(Icons.skip_previous),
      onPressed: widget._audioPlayer.hasPrevious
          ? widget._audioPlayer.seekToPrevious
          : null,
    );
  }

  Widget _nextButton() {
    return IconButton(
      icon: const Icon(Icons.skip_next),
      onPressed:
          widget._audioPlayer.hasNext ? widget._audioPlayer.seekToNext : null,
    );
  }

  Widget _repeatButton(BuildContext context, LoopMode loopMode) {
    final icons = [
      const Icon(Icons.repeat),
      Icon(Icons.repeat, color: Theme.of(context).accentColor),
      Icon(Icons.repeat_one, color: Theme.of(context).accentColor),
    ];
    const cycleModes = [
      LoopMode.off,
      LoopMode.all,
      LoopMode.one,
    ];
    final index = cycleModes.indexOf(loopMode);
    return IconButton(
      icon: icons[index],
      onPressed: () {
        widget._audioPlayer.setLoopMode(
            cycleModes[(cycleModes.indexOf(loopMode) + 1) % cycleModes.length]);
      },
    );
  }
}
