// Holds Logic, stats, Audio, and TTS instances
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';

// Global Instances
final FlutterTts tts = FlutterTts();
final AudioPlayer audioPlayer = AudioPlayer();
String currentLanguage = "en-US";

class PlayerStats {
  static int xp = 0;
  static int tasksCompleted = 0;
  static int level = 1;

  static void addXP(int amount) {
    xp += amount;
    tasksCompleted++;
    if (xp >= level * 100) {
      level++;
    }
  }
}

// Helpers
Future<void> speak(String text) async {
  await tts.stop();
  await tts.setLanguage(currentLanguage);
  await tts.setSpeechRate(0.4);
  await tts.speak(text);
}

void playSound(String fileName) async {
  try {
    await audioPlayer.play(AssetSource('sounds/$fileName'));
  } catch (e) {
    // Ignore error
  }
}

String getLocalizedNumber(int number) {
  if (currentLanguage == 'en-US') return number.toString();
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const devanagari = ['०', '१', '२', '३', '४', '५', '६', '७', '८', '९'];
  String num = number.toString();
  for (int i = 0; i < 10; i++) {
    num = num.replaceAll(english[i], devanagari[i]);
  }
  return num;
}