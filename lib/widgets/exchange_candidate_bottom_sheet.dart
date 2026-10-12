import 'dart:async';
import 'package:flutter/material.dart';

import '../models/exchange_candidate_model.dart';
import '../repositories/exchange_api_repository.dart';
import 'exchange_candidate_card_widget.dart';

class ExchangeCandidateBottomSheet extends StatefulWidget {
  final List<ExchangeCandidateModel> initialCandidates;

  final void Function(
      ExchangeCandidateModel candidate,
      ) onSelected;

  const ExchangeCandidateBottomSheet({
    super.key,
    required this.initialCandidates,
    required this.onSelected,
  });

  @override
  State<ExchangeCandidateBottomSheet> createState() =>
      _ExchangeCandidateBottomSheetState();
}

class _ExchangeCandidateBottomSheetState
    extends State<ExchangeCandidateBottomSheet> {
  final ExchangeApiRepository _exchangeApiRepository =
  ExchangeApiRepository();

  late List<ExchangeCandidateModel> _candidates;
  Timer? _pollingTimer;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _candidates = List<ExchangeCandidateModel>.from(widget.initialCandidates);
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 1),
          (_) => _loadCandidates(),
    );

    Future.delayed(
      const Duration(seconds: 10),
          () {
        if (!mounted) return;
        _pollingTimer?.cancel();
        _pollingTimer = null;
      },
    );
  }

  Future<void> _loadCandidates() async {
    if (!mounted || _loading) return;

    setState(() {
      _loading = true;
    });

    try {
      final candidates = await _exchangeApiRepository.getCandidates();
      if (!mounted) return;

      setState(() {
        _candidates = candidates;
      });
    } catch (e) {
      print('EXCHANGE CANDIDATES SHEET ERROR: $e');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Оберіть людину',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Оберіть людину поруч, з якою хочете обмінятися візитками',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            if (_candidates.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Center(
                  child: Text(
                    'Поруч поки нікого немає',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            if (_candidates.isNotEmpty)
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _candidates.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final candidate = _candidates[index];

                    return ExchangeCandidateCardWidget(
                      card: candidate.card,
                      distance: candidate.distance,
                      onTap: () async {
                        try {
                          final matched =
                          await _exchangeApiRepository.selectCandidate(
                            targetUserId: candidate.userId,
                            cardId: candidate.cardId,
                          );

                          if (!mounted) return;

                          if (matched) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Вітаємо! Обмін успішно завершено! 🎉'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Запит надіслано. Очікуємо підтвердження від співрозмовника...'),
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Помилка вибору: $e'),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}