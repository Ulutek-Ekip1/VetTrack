import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/di/injection_container.dart';
import '../../../pet/domain/entities/pet_entity.dart';
import 'package:vettrack_frontend/features/ai/presentation/cubit/ai_chat_cubit.dart';
import 'package:vettrack_frontend/features/ai/presentation/cubit/ai_chat_state.dart';
import 'package:vettrack_frontend/features/ai/presentation/cubit/ui_chat_message.dart';

class AIChatbotScreen extends StatelessWidget {
  final String? petId;
  final PetEntity? pet;

  const AIChatbotScreen({
    super.key,
    this.petId,
    this.pet,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AiChatCubit>(
      create: (context) => sl<AiChatCubit>()..setPetContext(petId),
      child: AIChatbotView(petId: petId, pet: pet),
    );
  }
}

class AIChatbotView extends StatefulWidget {
  final String? petId;
  final PetEntity? pet;

  const AIChatbotView({
    super.key,
    this.petId,
    this.pet,
  });

  @override
  State<AIChatbotView> createState() => _AIChatbotViewState();
}

class _AIChatbotViewState extends State<AIChatbotView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _inputText = '';

  String? _activePetId;
  PetEntity? _activePet;

  @override
  void initState() {
    super.initState();
    _activePetId = widget.petId;
    _activePet = widget.pet;

    _messageController.addListener(() {
      if (mounted) {
        setState(() {
          _inputText = _messageController.text;
        });
      }
    });

    // Ekran açıldığında genel sohbet geçmişini yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AiChatCubit>().fetchHistory();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSendPressed() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final cubit = context.read<AiChatCubit>();
    if (cubit.state.isSending) return;

    _messageController.clear();
    setState(() {
      _inputText = '';
    });

    cubit.sendMessage(text);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(String rawDate) {
    if (rawDate.isEmpty) return 'Şimdi';
    try {
      final dt = DateTime.parse(rawDate).toLocal();
      final now = DateTime.now();
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return 'Şimdi';
    }
  }

  void _showHistoryBottomSheet(BuildContext parentContext) {
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return BlocProvider.value(
          value: parentContext.read<AiChatCubit>(),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.7,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder: (sheetContext, scrollController) {
              return BlocBuilder<AiChatCubit, AiChatState>(
                builder: (context, state) {
                  return Column(
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.history,
                                    color: Color(0xFF004AC6), size: 22),
                                SizedBox(width: 8),
                                Text(
                                  'Sohbet Geçmişiniz',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF131B2E),
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(bottomSheetContext),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),

                      // Body - Yükleme / Hata / Liste Durumları
                      Expanded(
                        child: _buildHistoryContent(
                          context,
                          state,
                          scrollController,
                          bottomSheetContext,
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHistoryContent(
    BuildContext context,
    AiChatState state,
    ScrollController scrollController,
    BuildContext bottomSheetContext,
  ) {
    if (state.isLoadingHistory) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Sohbet geçmişi yükleniyor...',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (state.isHistoryError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text(
                state.historyErrorMessage ?? 'Geçmiş yüklenirken bir hata oluştu.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF131B2E), fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => context.read<AiChatCubit>().fetchHistory(),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Tekrar Deneyin'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004AC6),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state.conversations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_toggle_off, size: 54, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Henüz kaydedilmiş sohbet geçmişiniz bulunmuyor.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: state.conversations.length + (state.hasMoreHistory ? 1 : 0),
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
      itemBuilder: (context, index) {
        if (index == state.conversations.length) {
          // Daha fazla yükle butonu
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: state.isLoadingMoreHistory
                  ? const CircularProgressIndicator()
                  : OutlinedButton.icon(
                      onPressed: () {
                        context
                            .read<AiChatCubit>()
                            .fetchHistory(isLoadMore: true);
                      },
                      icon: const Icon(Icons.expand_more),
                      label: const Text('Daha Fazla Geçmiş Yükle'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF004AC6),
                        side: const BorderSide(color: Color(0xFF004AC6)),
                      ),
                    ),
            ),
          );
        }

        final conv = state.conversations[index];
        final isSelected = state.activeConversationId == conv.conversationId;

        return ListTile(
          selected: isSelected,
          selectedTileColor: const Color(0xFFEFF6FF),
          leading: CircleAvatar(
            backgroundColor: isSelected
                ? const Color(0xFF004AC6)
                : Colors.grey.shade100,
            child: Icon(
              conv.petId != null ? Icons.pets : Icons.chat_bubble_outline,
              color: isSelected ? Colors.white : const Color(0xFF004AC6),
              size: 20,
            ),
          ),
          title: Text(
            conv.lastMessagePreview,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              fontSize: 14,
              color: const Color(0xFF131B2E),
            ),
          ),
          subtitle: Row(
            children: [
              Text(
                _formatTime(conv.lastMessageTime.toIso8601String()),
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
              ),
              if (conv.petId != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Pet Bağlamı',
                    style: TextStyle(
                      color: Color(0xFF1E3A8A),
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
          onTap: () {
            context.read<AiChatCubit>().selectConversation(conv);
            Navigator.pop(bottomSheetContext);
          },
        );
      },
    );
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
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_outlined, color: primaryBlue),
            tooltip: 'Yeni Sohbet',
            onPressed: () {
              context.read<AiChatCubit>().startNewConversation();
            },
          ),
          IconButton(
            icon: const Icon(Icons.history, color: Color(0xFF131B2E)),
            tooltip: 'Sohbet Geçmişi',
            onPressed: () => _showHistoryBottomSheet(context),
          ),
        ],
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
      body: BlocConsumer<AiChatCubit, AiChatState>(
        listener: (context, state) {
          if (state.isPetAccessError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.historyErrorMessage ??
                      'Seçilen evcil hayvana ait sohbet geçmişine erişilemedi. Pet silinmiş veya erişim yetkiniz bulunmuyor.',
                ),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 4),
              ),
            );
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          } else if (state.messages.isNotEmpty) {
            _scrollToBottom();
          }
        },
        builder: (context, state) {
          final messages = state.messages;
          final isSending = state.isSending;
          final canSend = _inputText.trim().isNotEmpty && !isSending;

          return Column(
            children: [
              // Aktif Pet Bağlamı Kartı
              if (_activePetId != null)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFFDBEAFE),
                        backgroundImage: _activePet?.photoUrl != null &&
                                _activePet!.photoUrl!.isNotEmpty
                            ? NetworkImage(_activePet!.photoUrl!)
                            : null,
                        child: _activePet?.photoUrl == null ||
                                _activePet!.photoUrl!.isEmpty
                            ? const Icon(Icons.pets, size: 18, color: primaryBlue)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Aktif Bağlam: ${_activePet?.name ?? 'Evcil Hayvan'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                            Text(
                              'Sorular ${_activePet?.name ?? 'bu pet'} özelinde yanıtlanır',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF3B82F6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Tooltip(
                        message: 'Genel sohbete dön',
                        child: InkWell(
                          onTap: () {
                            context.read<AiChatCubit>().clearPetContext();
                            setState(() {
                              _activePetId = null;
                              _activePet = null;
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF93C5FD)),
                            ),
                            child: const Icon(Icons.close,
                                size: 16, color: Color(0xFF1E3A8A)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Sohbet Mesajları Listesi
              Expanded(
                child: messages.isEmpty
                    ? SingleChildScrollView(
                        padding: const EdgeInsets.all(AppDimensions.containerMargin),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            _buildWelcomeBubble(primaryBlue),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(AppDimensions.containerMargin),
                        physics: const BouncingScrollPhysics(),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          return _buildMessageBubble(msg, primaryBlue);
                        },
                      ),
              ),

              // Yanıt Beklerken Loading Durumu
              if (isSending)
                Padding(
                  padding: const EdgeInsets.only(
                      left: AppDimensions.containerMargin, bottom: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'AI Asistan yanıt hazırlıyor',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 6),
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.8,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.teal.shade600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Öneri Soru Şablonları (Sadece mesaj yoksa gösterilir)
              if (messages.isEmpty)
                Container(
                  height: 45,
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.containerMargin),
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
                          onPressed: isSending
                              ? null
                              : () {
                                  _messageController.text = tag;
                                  _onSendPressed();
                                },
                          backgroundColor: Colors.white,
                          labelStyle: const TextStyle(
                              color: primaryBlue,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                          side: BorderSide(
                              color: primaryBlue.withValues(alpha: 0.2)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                      );
                    }).toList(),
                  ),
                ),

              // Sabit Yasal Bilgilendirme (Disclaimer) Banner'ı
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFFBEB),
                  border: Border(
                    top: BorderSide(color: Color(0xFFFDE68A), width: 1),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 15, color: Color(0xFFB45309)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'YASAL UYARI: Yapay zeka yanıtları yalnızca genel bilgilendirme amaçlıdır. Teşhis veya reçeteli tedavi yerine geçmez.',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: Color(0xFF92400E),
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Mesaj Giriş Alanı
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
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
                          enabled: !isSending, // İstek sürerken devre dışı
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) {
                            if (canSend) _onSendPressed();
                          },
                          decoration: InputDecoration(
                            hintText: isSending
                                ? 'Yanıt bekleniyor...'
                                : 'Mesajınızı yazın...',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            fillColor: Colors.grey.shade50,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: canSend ? _onSendPressed : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: canSend ? primaryBlue : Colors.grey.shade300,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.send,
                            color: canSend ? Colors.white : Colors.grey.shade500,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWelcomeBubble(Color primaryBlue) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Text(
          'Merhaba! Ben VetTrack Yapay Zeka Sağlık Asistanıyım. Evcil hayvanınızın sağlığı, beslenmesi veya aşıları hakkında bana her şeyi sorabilirsiniz. 🐾',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 14.0,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(UiChatMessage msg, Color primaryBlue) {
    final isUser = msg.role == 'user';
    final isEmergency = msg.emergency;

    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12.0),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          decoration: BoxDecoration(
            color: primaryBlue,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                msg.content,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14.0,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (msg.sendStatus == MessageSendStatus.sending)
                    const Padding(
                      padding: EdgeInsets.only(right: 4.0),
                      child: SizedBox(
                        width: 10,
                        height: 10,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                        ),
                      ),
                    ),
                  Text(
                    _formatTime(msg.createdAt),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // AI (Model) Yanıtı - Acil Durum Özel Kartı (emergency == true)
    if (isEmergency) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14.0),
          padding: const EdgeInsets.all(16.0),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.88,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFDC2626), width: 2.0),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEF4444).withValues(alpha: 0.18),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Acil Durum Başlığı
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Colors.white, size: 18),
                    SizedBox(width: 6),
                    Text(
                      '🚨 ACİL DURUM UYARISI',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Veteriner Yönlendirme Vurgusu
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.local_hospital,
                        color: Color(0xFFB91C1C), size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Vakit kaybetmeden en yakın veteriner kliniğine başvurunuz!',
                        style: TextStyle(
                          color: Color(0xFF991B1B),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Backend Reply Metni (Aynen gösterilir)
              SelectableText(
                msg.content,
                style: const TextStyle(
                  color: Color(0xFF7F1D1D),
                  fontSize: 14.0,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  _formatTime(msg.createdAt),
                  style: const TextStyle(
                    color: Color(0xFFB91C1C),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // AI (Model) Yanıtı - Normal Standart Balon
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        padding: const EdgeInsets.all(14.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
          border: Border.all(color: Colors.grey.shade200, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              msg.content,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 14.0,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                _formatTime(msg.createdAt),
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
