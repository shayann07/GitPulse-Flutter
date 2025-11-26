import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'models/github_repo.dart';
import 'providers/app_providers.dart';
import 'services/firestore_service.dart';

class RepositoriesScreen extends ConsumerStatefulWidget {
  const RepositoriesScreen({super.key});

  @override
  ConsumerState<RepositoriesScreen> createState() =>
      _RepositoriesScreenState();
}

class _RepositoriesScreenState extends ConsumerState<RepositoriesScreen> {
  // local override of selections for snappy UI
  final Map<String, bool> _localSelections = {};

  @override
  Widget build(BuildContext context) {
    final reposAsync = ref.watch(reposProvider);
    final settingsAsync = ref.watch(userSettingsProvider);
    final sessionAsync = ref.watch(sessionProvider);

    return Scaffold(
      backgroundColor: _RColors.background,
      body: SafeArea(
        child: reposAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (err, stack) => Center(
            child: Text(
              'Failed to load repositories\n$err',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          data: (repos) {
            if (repos.isEmpty) {
              return const Center(
                child: Text(
                  'No eligible repositories found.',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            final settings = settingsAsync.asData?.value;
            final includePrivateFlag = settings?.includePrivate ?? true;

            final repoSelections = <String, bool>{};

            for (final repo in repos) {
              final key = repo.fullName;

              if (_localSelections.containsKey(key)) {
                // session-local override (tapping in this screen)
                repoSelections[key] = _localSelections[key]!;
              } else if (settings != null &&
                  settings.repoSelections.containsKey(key)) {
                // stored selection in Firestore
                repoSelections[key] = settings.repoSelections[key]!;
              } else {
                // DEFAULT SELECTION:
                // - includePrivate == true  -> all repos preselected
                // - includePrivate == false -> only public repos preselected
                final defaultSelected =
                includePrivateFlag ? true : !repo.isPrivate;
                repoSelections[key] = defaultSelected;
              }
            }

            final selectedCount =
                repoSelections.values.where((v) => v).length;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ReposHeader(selectedCount: selectedCount),
                  const SizedBox(height: 24),
                  const _SearchField(),
                  const SizedBox(height: 22),
                  ...repos.asMap().entries.map((entry) {
                    final index = entry.key;
                    final repo = entry.value;
                    final key = repo.fullName;
                    final selected = repoSelections[key] ?? true;

                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == repos.length - 1 ? 40 : 12,
                      ),
                      child: _RepoCard(
                        repo: _RepoItem(
                          name: repo.name,
                          language: repo.language ?? 'Unknown',
                          languageColor:
                          _languageColor(repo.language ?? 'Unknown'),
                          stars: repo.stars.toString(),
                          selected: selected,
                        ),
                        onChanged: (value) async {
                          setState(() {
                            _localSelections[key] = value;
                          });

                          final session = sessionAsync.value;
                          final uid = session?.uid;
                          if (uid != null) {
                            await FirestoreService.instance
                                .updateRepoSelection(
                              uid: uid,
                              repoKey: key,
                              selected: value,
                            );
                          }
                        },
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ===================== MODEL =====================

class _RepoItem {
  final String name;
  final String language;
  final Color languageColor;
  final String stars;
  bool selected;

  _RepoItem({
    required this.name,
    required this.language,
    required this.languageColor,
    required this.stars,
    required this.selected,
  });
}

Color _languageColor(String language) {
  switch (language.toLowerCase()) {
    case 'kotlin':
      return const Color(0xFFB278FF);
    case 'shell':
      return const Color(0xFF4CD964);
    case 'typescript':
      return const Color(0xFF5AC8FA);
    case 'python':
      return const Color(0xFFB278FF);
    case 'java':
      return const Color(0xFFFFCC00);
    case 'go':
      return const Color(0xFF5AC8FA);
    case 'dart':
      return const Color(0xFF52CEFF);
    default:
      return const Color(0xFF9FA3A1);
  }
}

// ===================== HEADER =====================

class _ReposHeader extends StatelessWidget {
  final int selectedCount;

  const _ReposHeader({required this.selectedCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _RColors.backButtonBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              'assets/arrow_left.svg',
              width: 16,
              height: 16,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Repositories',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$selectedCount Selected',
              style: const TextStyle(
                color: _RColors.subtitle,
                fontSize: 13,
                height: 1.2,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: _RColors.searchBackground,
        borderRadius: BorderRadius.circular(26),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/search_icon.svg',
            width: 18,
            height: 18,
            colorFilter: const ColorFilter.mode(
              _RColors.searchIcon,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Search repositories .......',
            style: TextStyle(
              color: _RColors.searchHint,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _RepoCard extends StatelessWidget {
  final _RepoItem repo;
  final ValueChanged<bool> onChanged;

  const _RepoCard({required this.repo, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final bool selected = repo.selected;

    return GestureDetector(
      onTap: () => onChanged(!selected),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: _RColors.cardBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? _RColors.cardBorderSelected
                : _RColors.cardBorder,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            _RepoSelectionIndicator(
              selected: selected,
              onChanged: onChanged,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    repo.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: repo.languageColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        repo.language,
                        style: const TextStyle(
                          color: _RColors.subtitle,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: _RColors.subtitle,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        repo.stars,
                        style: const TextStyle(
                          color: _RColors.subtitle,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RepoSelectionIndicator extends StatelessWidget {
  final bool selected;
  final ValueChanged<bool> onChanged;

  const _RepoSelectionIndicator({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!selected),
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: selected ? _RColors.checkboxSelected : _RColors.checkboxEmpty,
          border: Border.all(
            color: selected ? Colors.transparent : _RColors.checkboxBorder,
            width: 1.3,
          ),
        ),
        alignment: Alignment.center,
        child: selected
            ? SvgPicture.asset(
          'assets/checkbox_icon.svg',
          width: 10,
          height: 10,
        )
            : null,
      ),
    );
  }
}

class _RColors {
  static const Color background = Color(0xFF000000);
  static const Color searchBackground = Color(0xFF151518);
  static const Color searchHint = Color(0xFF8A8A8C);
  static const Color searchIcon = Color(0xFF8E8E96);

  static const Color subtitle = Color(0xFF9FA3A1);

  static const Color cardBackground = Color(0xFF010906);
  static const Color cardBorder = Color(0xFF171F1C);
  static const Color cardBorderSelected = Color(0xFF7F56D9);

  static const Color backButtonBackground = Color(0xFF1A1A1A);

  static const Color checkboxSelected = Color(0xFF7F56D9);
  static const Color checkboxEmpty = Color(0xFF010906);
  static const Color checkboxBorder = Color(0xFF493561);
}
