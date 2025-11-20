import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RepositoriesScreen extends StatefulWidget {
  const RepositoriesScreen({super.key});

  @override
  State<RepositoriesScreen> createState() => _RepositoriesScreenState();
}

class _RepositoriesScreenState extends State<RepositoriesScreen> {
  final List<_RepoItem> _repos = [
    _RepoItem(
      name: 'Gitpluse-Android',
      language: 'kotlin',
      languageColor: const Color(0xFFB278FF),
      stars: '142',
      selected: true,
    ),
    _RepoItem(
      name: 'Dot Files',
      language: 'Shell',
      languageColor: const Color(0xFF4CD964),
      stars: '23',
      selected: true,
    ),
    _RepoItem(
      name: 'Website',
      language: 'Typescript',
      languageColor: const Color(0xFF5AC8FA),
      stars: '89',
      selected: true,
    ),
    _RepoItem(
      name: 'Analytics-Dashboard',
      language: 'Python',
      languageColor: const Color(0xFFB278FF),
      stars: '201',
      selected: true,
    ),
    _RepoItem(
      name: 'Mobile-Lib',
      language: 'Java',
      languageColor: const Color(0xFFFFCC00),
      stars: '67',
      selected: false,
    ),
    _RepoItem(
      name: 'Api-Server',
      language: 'Go',
      languageColor: const Color(0xFF5AC8FA),
      stars: '134',
      selected: false,
    ),
    _RepoItem(
      name: 'Api-Server',
      language: 'Go',
      languageColor: const Color(0xFF5AC8FA),
      stars: '134',
      selected: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedCount = _repos.where((r) => r.selected).length;

    return Scaffold(
      backgroundColor: _RColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ReposHeader(selectedCount: selectedCount),
              const SizedBox(height: 24),
              const _SearchField(),
              const SizedBox(height: 22),
              ..._repos.asMap().entries.map((entry) {
                final index = entry.key;
                final repo = entry.value;
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == _repos.length - 1 ? 40 : 12,
                  ),
                  child: _RepoCard(
                    repo: repo,
                    onChanged: (value) {
                      setState(() {
                        repo.selected = value;
                      });
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

//
// ===================== MODEL =====================
//

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

//
// ===================== HEADER =====================
//

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

//
// ===================== SEARCH FIELD =====================
//

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

//
// ===================== REPO CARD =====================
//

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

//
// ===================== COLORS =====================
//

class _RColors {
  // from screenshot sampling
  static const Color background = Color(0xFF000000); // page background
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
