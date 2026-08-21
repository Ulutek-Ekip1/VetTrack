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
  bool _showDisclaimer = true;

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

  Future<void> _confirmAndDeleteConversation(
      BuildContext context, String conversationId) async {
    final messenger = ScaffoldMessenger.of(context);
    final cubit = context.read<AiChatCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.redAccent),
              SizedBox(width: 8),
              Text('Sohbeti Sil'),
            ],
          ),
          content: const Text(
            'Bu sohbet oturumunu ve tüm mesajlarını silmek istediğinize emin misiniz? Bu işlem geri alınamaz (KVKK).',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Vazgeç'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sohbeti Sil'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final success = await cubit.deleteConversation(conversationId);
      if (success) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Sohbet oturumu başarıyla silindi.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              cubit.state.errorMessage ??
                  'Sohbet silinirken bir hata oluştu.',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  Future<void> _confirmAndDeleteAllHistory(
      BuildContext context, BuildContext bottomSheetContext) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(bottomSheetContext);
    final cubit = context.read<AiChatCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
              SizedBox(width: 8),
              Text('Tüm Geçmişi Sil'),
            ],
          ),
          content: const Text(
            'Tüm AI sohbet geçmişinizi kalıcı olarak silmek istediğinize emin misiniz? Tüm konuşmalarınız temizlenecek ve bu işlem geri alınamayacaktır (KVKK Unutulma Hakkı).',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Vazgeç'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade800,
                foregroundColor: Colors.white,
              ),
              child: const Text('Tüm Geçmişi Kalıcı Olarak Sil'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final success = await cubit.deleteAllHistory();
      if (success) {
        if (navigator.canPop()) {
          navigator.pop();
        }
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Tüm AI sohbet geçmişiniz kalıcı olarak silindi.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              cubit.state.errorMessage ??
                  'Geçmiş silinirken bir hata oluştu.',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  void _showHistoryBottomSheet(BuildContext parentContext) {
    final theme = Theme.of(parentContext);
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
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
                            Row(
                              children: [
                                Icon(Icons.history,
                                    color: theme.colorScheme.primary, size: 22),
                                const SizedBox(width: 8),
                                Text(
                                  'Sohbet Geçmişiniz',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
                              onPressed: () => Navigator.pop(bottomSheetContext),
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 1, color: theme.colorScheme.outlineVariant),

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
    final theme = Theme.of(context);
    if (state.isLoadingHistory) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text('Sohbet geçmişi yükleniyor...',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
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
                style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => context.read<AiChatCubit>().fetchHistory(),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Tekrar Deneyin'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state.conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_toggle_off, size: 54, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              'Henüz kaydedilmiş sohbet geçmişiniz bulunmuyor.',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount:
                state.conversations.length + (state.hasMoreHistory ? 1 : 0),
            separatorBuilder: (_, __) =>
                Divider(height: 1, indent: 16, endIndent: 16, color: theme.colorScheme.outlineVariant),
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
                              foregroundColor: theme.colorScheme.primary,
                              side: BorderSide(color: theme.colorScheme.primary),
                            ),
                          ),
                  ),
                );
              }

              final conv = state.conversations[index];
              final isSelected =
                  state.activeConversationId == conv.conversationId;

              return ListTile(
                selected: isSelected,
                selectedTileColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                leading: CircleAvatar(
                  backgroundColor: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainerHighest,
                  child: Icon(
                    conv.petId != null
                        ? Icons.pets
                        : Icons.chat_bubble_outline,
                    color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
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
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                subtitle: Row(
                  children: [
                    Text(
                      _formatTime(conv.lastMessageTime.toIso8601String()),
                      style:
                          TextStyle(color: Colors.grey.shade500, fontSize: 11),
                    ),
                    if (conv.petId != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
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
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          size: 20, color: Colors.redAccent),
                      tooltip: 'Sohbeti sil',
                      onPressed: () {
                        _confirmAndDeleteConversation(
                            context, conv.conversationId);
                      },
                    ),
                    const Icon(Icons.chevron_right,
                        size: 18, color: Colors.grey),
                  ],
                ),
                onTap: () {
                  context.read<AiChatCubit>().selectConversation(conv);
                  Navigator.pop(bottomSheetContext);
                },
              );
            },
          ),
        ),

        // Tüm Geçmişi Sil Butonu (KVKK Unutulma Hakkı)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            color: Color(0xFFFFF1F2),
            border: Border(top: BorderSide(color: Color(0xFFFECDD3))),
          ),
          child: TextButton.icon(
            onPressed: () =>
                _confirmAndDeleteAllHistory(context, bottomSheetContext),
            icon: const Icon(Icons.delete_forever,
                color: Color(0xFFE11D48), size: 20),
            label: const Text(
              'Tüm AI Sohbet Geçmişini Sil (KVKK)',
              style: TextStyle(
                color: Color(0xFFBE123C),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryBlue = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.add_comment_outlined, color: theme.colorScheme.primary),
            tooltip: 'Yeni Sohbet',
            onPressed: () {
              context.read<AiChatCubit>().startNewConversation();
            },
          ),
          IconButton(
            icon: Icon(Icons.history, color: theme.colorScheme.onSurface),
            tooltip: 'Sohbet Geçmişi',
            onPressed: () => _showHistoryBottomSheet(context),
          ),
        ],
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_awesome, color: theme.colorScheme.onSecondaryContainer, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Sağlık Asistanı',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'VetTrack AI • Çevrimiçi',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11,
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
          if (state.isAuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Oturum süreniz doldu. Lütfen yeniden giriş yapınız.',
                ),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state.isPetAccessError) {
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
          final rateLimitRemaining = state.rateLimitRemainingSeconds;
          final canSend = _inputText.trim().isNotEmpty &&
              !isSending &&
              rateLimitRemaining == 0;

          return Column(
            children: [
              // Aktif Pet Bağlamı Kartı
              if (_activePetId != null)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        backgroundImage: _activePet?.photoUrl != null &&
                                _activePet!.photoUrl!.isNotEmpty
                            ? NetworkImage(_activePet!.photoUrl!)
                            : null,
                        child: _activePet?.photoUrl == null ||
                                _activePet!.photoUrl!.isEmpty
                            ? Icon(Icons.pets, size: 18, color: primaryBlue)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Aktif Bağlam: ${_activePet?.name ?? 'Evcil Hayvan'}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              'Sorular ${_activePet?.name ?? 'bu pet'} özelinde yanıtlanır',
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.primary,
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
                              color: theme.colorScheme.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: theme.colorScheme.outlineVariant),
                            ),
                            child: Icon(Icons.close,
                                size: 16, color: theme.colorScheme.onSurface),
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
                          backgroundColor: theme.colorScheme.surface,
                          labelStyle: TextStyle(
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
              if (_showDisclaimer)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade400.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'YASAL UYARI: ',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                              ),
                              TextSpan(
                                text: 'Yapay zeka yanıtları yalnızca genel bilgilendirme amaçlıdır. Teşhis veya reçeteli tedavi yerine geçmez.',
                                style: TextStyle(color: Color(0xFF434655), fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showDisclaimer = false;
                          });
                        },
                        child: const Icon(Icons.close, color: Colors.black38, size: 18),
                      ),
                    ],
                  ),
                ),

              // Mesaj Giriş Alanı
              if (rateLimitRemaining > 0)
                Container(
                  width: double.infinity,
                  color: const Color(0xFFFFF7ED),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Çok fazla istek gönderildi. $rateLimitRemaining sn sonra tekrar deneyebilirsiniz.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF9A3412),
                      fontSize: 12,
                    ),
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLowest,
                  border: Border(
                    top: BorderSide(color: theme.colorScheme.outlineVariant, width: 1.5),
                  ),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          enabled: !isSending && rateLimitRemaining == 0,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) {
                            if (canSend) _onSendPressed();
                          },
                          style: TextStyle(color: theme.colorScheme.onSurface),
                          decoration: InputDecoration(
                            hintText: isSending
                                ? 'Yanıt bekleniyor...'
                                : 'Mesajınızı yazın...',
                            hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            fillColor: theme.colorScheme.surfaceContainerHigh,
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
                            color: canSend
                                ? primaryBlue
                                : theme.colorScheme.surfaceContainerHighest,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.send,
                            color: canSend
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurfaceVariant,
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
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLowest,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
          border: Border.all(color: theme.colorScheme.outlineVariant, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          'Merhaba! Ben VetTrack Yapay Zeka Sağlık Asistanıyım. Evcil hayvanınızın sağlığı, beslenmesi veya aşıları hakkında bana her şeyi sorabilirsiniz. 🐾',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
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
      final isFailed = msg.sendStatus == MessageSendStatus.error;

      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12.0),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.80,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: isFailed ? const Color(0xFFDC2626) : primaryBlue,
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
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white70),
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

              // Hata Kutusu ve Retry Aksiyonu
              if (isFailed) ...[
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 14, color: Color(0xFFDC2626)),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              msg.errorMessage ??
                                  'Mesaj gönderilemedi. Lütfen tekrar deneyiniz.',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF991B1B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (msg.errorType == 'IDEMPOTENCY_KEY_REUSED')
                        InkWell(
                          onTap: () {
                            context
                                .read<AiChatCubit>()
                                .retryWithNewClientMessageId(msg);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDC2626),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.refresh,
                                    size: 12, color: Colors.white),
                                SizedBox(width: 4),
                                Text(
                                  'Yeni ID ile Tekrar Gönder',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        InkWell(
                          onTap: () {
                            context.read<AiChatCubit>().retryMessage(msg);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDC2626),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.refresh,
                                    size: 12, color: Colors.white),
                                SizedBox(width: 4),
                                Text(
                                  'Tekrar Dene',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
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
                msg.displayContent,
                style: const TextStyle(
                  color: Color(0xFF7F1D1D),
                  fontSize: 14.0,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (msg.quickReplies.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: msg.quickReplies.map((reply) {
                    return ActionChip(
                      label: Text(reply),
                      onPressed: () => _sendMessage(text: reply),
                      backgroundColor: Colors.white.withValues(alpha: 0.9),
                      labelStyle: const TextStyle(color: Color(0xFFB91C1C), fontSize: 12, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0xFFFCA5A5)),
                      ),
                    );
                  }).toList(),
                ),
              ],
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
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        padding: const EdgeInsets.all(14.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLowest,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
          border: Border.all(color: theme.colorScheme.outlineVariant, width: 1.0),
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
              msg.displayContent,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 14.0,
                height: 1.4,
              ),
            ),
            if (msg.quickReplies.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: msg.quickReplies.map((reply) {
                  return ActionChip(
                    label: Text(reply),
                    onPressed: () => _sendMessage(text: reply),
                    backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                    labelStyle: TextStyle(color: theme.colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                _formatTime(msg.createdAt),
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
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
