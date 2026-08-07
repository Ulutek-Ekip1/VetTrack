
import 'dart:io';

void main() {
  final file = File('frontend/lib/core/services/top_notification.dart');
  var content = file.readAsStringSync();
  
  final regex = RegExp(r'(Padding\(\s*padding: const EdgeInsets\.all\(16\),?\s*child: )Container\(\s*padding: const EdgeInsets\.symmetric\(horizontal: 16\),(\s*decoration: BoxDecoration\()([^]*?)borderRadius: BorderRadius\.circular\(\d+\),([^]*?),\s*child: (const )?Icon\(\s*(Icons\.[a-zA-Z0-9_]+),\s*color: Colors\.white,?\s*\),?\s*\)(?=\s*\))');
  
  content = content.replaceAllMapped(regex, (match) {
    final prefix = match.group(1)!;
    final decorStart = match.group(2)!;
    final decorMid1 = match.group(3)!;
    final decorMid2 = match.group(4)!;
    final iconName = match.group(6)!;
    
    return '''\Center(
                child: Container(
                  width: 52,
                  height: 52,\\shape: BoxShape.circle,\,
                  child: Center(
                    child: Icon(
                      \,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              )''';
  });
  
  file.writeAsStringSync(content);
  print('Done!');
}

