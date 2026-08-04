import 'package:flutter/material.dart';
import '../../../../core/constants/app_dimensions.dart';

class AIChatbotScreen extends StatefulWidget {
  const AIChatbotScreen({super.key});

  @override
  State<AIChatbotScreen> createState() => _AIChatbotScreenState();
}

class _AIChatbotScreenState extends State<AIChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [
    {
      'isUser': false,
      'text': 'Merhaba! Ben VetTrack Yapay Zeka Sağlık Asistanıyım. Evcil hayvanınızın sağlığı, beslenmesi veya aşıları hakkında bana her şeyi sorabilirsiniz. 🐾',
      'time': 'Şimdi',
    }
  ];
  bool _isTyping = false;

  final Map<String, String> _mockReplies = {
    'merhaba': 'Merhaba! Evcil dostunuz hakkında size nasıl yardımcı olabilirim?',
    'aşı': 'Evcil hayvanların aşı takvimi yaş ve türüne göre değişiklik gösterir. Genellikle yavrular için 6-8. haftalarda iç-dış parazit ve karma aşılarla başlanır. Güncel aşı takviminizi "Tedaviler & Aşı Takvimi" sekmesinden takip edebilirsiniz.',
    'mama': 'Dostunuzun yaşına, kilosuna ve kısırlaştırma durumuna uygun mamalar seçmelisiniz. Örneğin, yetişkin kısırlaştırılmış kediler için düşük tahıllı veya tahılsız kısırlaştırılmış kedi mamaları önerilir. Günlük porsiyona dikkat etmeniz obeziteyi engelleyecektir.',
    'kusma': 'Evcil hayvanlarda kusma; basit bir tüy yumağından, gıda zehirlenmesine veya ciddi enfeksiyonlara kadar pek çok nedenden kaynaklanabilir. Kusma sıklığı fazlaysa ve halsizlik eşlik ediyorsa acilen veteriner hekiminize başvurmanızı öneririm.',
    'tüy': 'Mevsim geçişlerinde tüy dökülmesi oldukça normaldir. Düzenli olarak haftada 2-3 kez tüy taraması yapmak dökülmeyi büyük oranda azaltır. Ayrıca somon yağlı mamalar da deri sağlığını destekler.',
    'nasılsın': 'Harikayım! VetTrack sisteminde dostlarınızın sağlığını takip etmek için her zaman buradayım. Siz nasılsınız?',
  };

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    setState(() {
      _messages.add({
        'isUser': true,
        'text': text,
        'time': 'Şimdi',
      });
      _isTyping = true;
    });

    _scrollToBottom();

    // AI Cevap Simülasyonu (1.5 saniye sonra)
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;

      String reply = 'Anlıyorum. Evcil dostunuzun sağlığı bizim için çok önemli. Ancak bu spesifik soru için doğrudan veteriner hekiminize danışmanız veya muayene kaydı oluşturmanız en doğrusu olacaktır. 🩺';
      final lowerText = text.toLowerCase();

      for (var key in _mockReplies.keys) {
        if (lowerText.contains(key)) {
          reply = _mockReplies[key]!;
          break;
        }
      }

      setState(() {
        _isTyping = false;
        _messages.add({
          'isUser': false,
          'text': reply,
          'time': 'Şimdi',
        });
      });

      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const primaryBlue = Color(0xFF004AC6);
    const peachBg = Color(0xFFFFECE5);
    const peachText = Color(0xFFD9531E);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceDim,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: peachBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, color: peachText, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Sağlık Asistanı',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF131B2E),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Çevrimiçi',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Sohbet Geçmişi
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppDimensions.containerMargin),
              physics: const BouncingScrollPhysics(),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['isUser'] as bool;

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? primaryBlue : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isUser ? 16 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      msg['text'] as String,
                      style: TextStyle(
                        color: isUser ? Colors.white : const Color(0xFF1E293B),
                        fontSize: 14.0,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Yazıyor İndikatörü
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.only(left: AppDimensions.containerMargin, bottom: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Text(
                      'AI Asistan yazıyor',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade500),
                    ),
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade400),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Öneri Soru Şablonları (Sadece sohbet boşken veya kolaylık için altta gösterilir)
          if (_messages.length == 1)
            Container(
              height: 45,
              margin: const EdgeInsets.only(bottom: 8.0),
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.containerMargin),
                children: [
                  'Kedi aşı takvimi',
                  'Mama seçimi nasıl olmalı?',
                  'Kusma neden olur?',
                  'Tüy dökülmesi normal mi?',
                ].map((tag) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ActionChip(
                      label: Text(tag),
                      onPressed: () {
                        _messageController.text = tag;
                        _sendMessage();
                      },
                      backgroundColor: Colors.white,
                      labelStyle: const TextStyle(color: primaryBlue, fontSize: 12, fontWeight: FontWeight.bold),
                      side: BorderSide(color: primaryBlue.withValues(alpha: 0.2)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  );
                }).toList(),
              ),
            ),

          // Mesaj Giriş Alanı
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFF1F5F9), width: 1.5),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Mesajınızı yazın...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: primaryBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
