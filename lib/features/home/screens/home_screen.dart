import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_metric_band.dart';
import '../../../core/widgets/app_section_header.dart';
import '../../../core/widgets/app_secondary_button.dart';
import '../../../core/widgets/app_study_set_row.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../flashcards/providers/flashcard_provider.dart';
import '../../stats/screens/stats_screen.dart';
import '../providers/home_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _refresh(BuildContext context) async {
    await Future.wait([
      context.read<HomeProvider>().loadHomeData(),
      context.read<FlashcardProvider>().loadFlashcards(),
      context.read<FlashcardProvider>().loadDueFlashcards(),
    ]);
  }

  Future<void> _openAddNote(BuildContext context) async {
    await Navigator.pushNamed(context, RouteNames.addEditNote);
    if (context.mounted) {
      await _refresh(context);
    }
  }

  Future<void> _openReviewDueCards(
    BuildContext context,
    FlashcardProvider flashcardProvider,
  ) async {
    if (flashcardProvider.dueFlashcards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hiện chưa có thẻ nào đến lượt ôn tập.')),
      );
      return;
    }

    await Navigator.pushNamed(
      context,
      RouteNames.review,
      arguments: {
        'cards': flashcardProvider.dueFlashcards,
        'title': 'Ôn thẻ đến hạn',
      },
    );
    if (context.mounted) {
      await _refresh(context);
    }
  }

  Future<void> _openQuiz(
    BuildContext context,
    FlashcardProvider flashcardProvider,
  ) async {
    if (flashcardProvider.flashcards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn cần có ít nhất một thẻ ghi nhớ để bắt đầu quiz.'),
        ),
      );
      return;
    }

    await Navigator.pushNamed(
      context,
      RouteNames.quiz,
      arguments: {'cards': flashcardProvider.flashcards},
    );
    if (context.mounted) {
      await _refresh(context);
    }
  }

  void _openAiStudySets(BuildContext context) {
    Navigator.pushNamed(context, RouteNames.aiStudySets);
  }

  void _openStats(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StatsScreen(standalone: true)),
    );
  }

  void _openStudyPlan(BuildContext context) {
    Navigator.pushNamed(context, RouteNames.studyPlan);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeProvider, FlashcardProvider>(
      builder: (context, homeProvider, flashcardProvider, _) {
        if (homeProvider.isLoading && homeProvider.progress == null) {
          return const LoadingView();
        }

        if (homeProvider.errorMessage != null &&
            homeProvider.progress == null) {
          return ErrorView(
            message: homeProvider.errorMessage!,
            onRetry: () => _refresh(context),
          );
        }

        final progress = homeProvider.progress;
        final streak = progress?.streak ?? 0;
        final dueCount = homeProvider.dueTodayCount;
        final today = DateFormat('dd/MM/yyyy').format(DateTime.now());
        final firstDeck = homeProvider.sampleDecks.isEmpty
            ? null
            : homeProvider.sampleDecks.first;
        final recentDecks = homeProvider.sampleDecks.take(3).toList();
        final tomorrowReviewCount = dueCount == 0
            ? 0
            : math.min(
                math.max(homeProvider.flashcardsCount - dueCount, 0),
                math.max(1, dueCount ~/ 2),
              );

        return RefreshIndicator(
          onRefresh: () => _refresh(context),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontalCompact,
              AppSpacing.lg,
              AppSpacing.screenHorizontalCompact,
              AppSpacing.xxl,
            ),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greetingLabel(),
                          style: Theme.of(context).textTheme.bodySecondary,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Thanh',
                          style: Theme.of(context).textTheme.pageTitle,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          today,
                          style: Theme.of(context).textTheme.metadata,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      dueCount == 0 ? 'Nhịp học ổn' : '$dueCount thẻ đến hạn',
                      style: Theme.of(context).textTheme.label,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              AppSectionHeader(
                title: 'Nhịp học hôm nay',
                subtitle:
                    'Quay lại đúng phần cần học, không mở thêm lớp giao diện phụ.',
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.container),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      firstDeck?['title']?.toString() ??
                          'Tiếp tục buổi học hiện tại',
                      style: Theme.of(context).textTheme.heroTitle,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      firstDeck == null
                          ? 'Chưa có bộ học AI đang hoạt động. Bạn vẫn có thể ôn bằng flashcard và ghi chú hiện có.'
                          : 'Bộ học gần nhất đã sẵn sàng để bạn quay lại ngay trong một bước.',
                      style: Theme.of(context).textTheme.bodySecondary,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        _InlinePill(
                          label: dueCount == 0
                              ? 'Không có thẻ đến hạn'
                              : '$dueCount thẻ đến hạn',
                        ),
                        _InlinePill(
                          label:
                              '${homeProvider.flashcardsCount} flashcard hiện có',
                        ),
                        _InlinePill(
                          label: firstDeck == null
                              ? 'Chưa có bộ học AI'
                              : 'Có thể xem chi tiết bộ học',
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: 'Tiếp tục',
                            icon: Icons.play_arrow_outlined,
                            onPressed: dueCount == 0
                                ? () => _openQuiz(context, flashcardProvider)
                                : () => _openReviewDueCards(
                                    context,
                                    flashcardProvider,
                                  ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: AppSecondaryButton(
                            label: 'Xem bộ học',
                            leadingIcon: Icons.auto_stories_outlined,
                            onPressed: () => _openAiStudySets(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppMetricBand(
                items: [
                  AppMetricBandItem(label: 'Chuỗi học', value: '$streak ngày'),
                  AppMetricBandItem(
                    label: 'Độ chính xác',
                    value:
                        '${homeProvider.averageAccuracy.toStringAsFixed(0)}%',
                  ),
                  AppMetricBandItem(label: 'Cần ôn', value: '$dueCount thẻ'),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              AppSectionHeader(
                title: 'Bộ học gần đây',
                subtitle: 'Các bộ học gần nhất để quay lại hoặc xem chi tiết.',
                trailing: TextButton(
                  onPressed: () => _openAiStudySets(context),
                  child: const Text('Mở danh sách'),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (recentDecks.isEmpty)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(AppRadius.container),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    'Chưa có bộ học gợi ý. Bạn có thể tạo bộ học AI mới hoặc bắt đầu từ ghi chú hiện có.',
                    style: Theme.of(context).textTheme.bodySecondary,
                  ),
                )
              else
                ...recentDecks.asMap().entries.map((entry) {
                  final deck = entry.value;
                  final title = deck['title']?.toString() ?? 'Bộ học';
                  final cards = deck['cards']?.toString() ?? '0';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: AppStudySetRow(
                      title: title,
                      subtitle: 'PRM393',
                      meta:
                          '$cards câu · ${entry.key == 0 ? 'Mới cập nhật' : 'Sẵn sàng học'}',
                      progressLabel: entry.key == 0
                          ? 'Đang học dở'
                          : 'Có thể bắt đầu ngay',
                      isHighlighted: entry.key == 0,
                      onTap: () => _openAiStudySets(context),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  );
                }),
              const SizedBox(height: AppSpacing.xl),
              AppSectionHeader(
                title: 'Lịch ôn tập',
                subtitle: 'Hai mốc gần nhất để chủ động phân bổ thời gian ôn.',
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(AppRadius.container),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: _ReviewScheduleRow(
                        label: 'Hôm nay',
                        value: '$dueCount flashcard cần ôn',
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: _ReviewScheduleRow(
                        label: 'Ngày mai',
                        value: '$tomorrowReviewCount flashcard cần ôn',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppSectionHeader(
                title: 'Lối tắt',
                subtitle: 'Các đường vào phụ cho ghi chú và tiến độ học.',
              ),
              const SizedBox(height: AppSpacing.sm),
              _QuickLinkRow(
                label: 'Tạo ghi chú',
                description: 'Mở nhanh màn hình ghi chú mới.',
                onTap: () => _openAddNote(context),
              ),
              const Divider(height: 1),
              _QuickLinkRow(
                label: 'Xem tiến độ',
                description: 'Đi tới thống kê học tập hiện tại.',
                onTap: () => _openStats(context),
              ),
              const Divider(height: 1),
              _QuickLinkRow(
                label: 'Kế hoạch học tập',
                description: 'Mở nhịp học ngày hôm nay và danh sách nhiệm vụ.',
                onTap: () => _openStudyPlan(context),
              ),
              if (homeProvider.dailyQuote != null) ...[
                const SizedBox(height: AppSpacing.xl),
                Text(
                  homeProvider.dailyQuote!.text,
                  style: Theme.of(context).textTheme.bodySecondary,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  homeProvider.dailyQuote!.author,
                  style: Theme.of(context).textTheme.metadata,
                ),
              ],
              if (homeProvider.errorMessage != null) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  homeProvider.errorMessage!,
                  style: Theme.of(context).textTheme.metadata,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _greetingLabel() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Chào buổi sáng,';
    }
    if (hour < 18) {
      return 'Chào buổi chiều,';
    }
    return 'Chào buổi tối,';
  }
}

class _InlinePill extends StatelessWidget {
  const _InlinePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(label, style: Theme.of(context).textTheme.metadata),
    );
  }
}

class _QuickLinkRow extends StatelessWidget {
  const _QuickLinkRow({
    required this.label,
    required this.description,
    required this.onTap,
  });

  final String label;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.container),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.itemTitle),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySecondary,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewScheduleRow extends StatelessWidget {
  const _ReviewScheduleRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.itemTitle),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(value, style: Theme.of(context).textTheme.bodySecondary),
      ],
    );
  }
}
