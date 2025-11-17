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
                    bottom: index == _repos.length - 1 ? 32 : 12,
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
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1E),
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
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$selectedCount Selected',
              style: const TextStyle(color: Color(0xFF9E9EAA), fontSize: 13),
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
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF15151A),
        borderRadius: BorderRadius.circular(26),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/search_icon.svg',
            width: 18,
            height: 18,
            colorFilter: const ColorFilter.mode(
              Color(0xFF8E8E96),
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Search repositories …….',
            style: TextStyle(color: Color(0xFF6C6C78), fontSize: 14),
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
          color: const Color(0xFF07120D),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? const Color(0xFF6A5CFF) : const Color(0xFF25252E),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            _RepoSelectionIndicator(
              selected: selected,
              onChanged: (value) => onChanged(value),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    repo.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
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
                          color: Color(0xFF9E9EAA),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: Color(0xFF9E9EAA),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        repo.stars,
                        style: const TextStyle(
                          color: Color(0xFF9E9EAA),
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
          color: selected
              ? const Color(0xFF8C5CFF) // selected purple background
              : const Color(0xFF0F1516), // empty background
          border: Border.all(
            color: selected
                ? Colors.transparent
                : const Color(0xFF505059), // border for unselected
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
  static const Color background = Color(0xFF0A0A0D);
}
