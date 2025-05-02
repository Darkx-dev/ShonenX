import 'package:flutter/material.dart';
import 'dart:ui';

class ShonenxSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final Function(String) onSearch;
  final Function(String) onChanged;
  final Color backgroundColor;
  final Color textColor;
  final Color hintColor;
  final Color iconColor;
  final Color cursorColor;
  final double borderRadius;
  final bool showShadow;
  final bool showClearButton;
  final bool showAnimatedIcon;
  final Widget? leading;

  const ShonenxSearchBar({
    super.key,
    this.controller,
    required this.onSearch,
    required this.onChanged,
    this.hintText = 'Search...',
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black87,
    this.hintColor = Colors.black54,
    this.iconColor = Colors.black87,
    this.cursorColor = Colors.deepPurpleAccent,
    this.borderRadius = 24.0,
    this.showShadow = true,
    this.showClearButton = true,
    this.showAnimatedIcon = true,
    this.leading,
  });

  @override
  _ShonenxSearchBarState createState() => _ShonenxSearchBarState();
}

class _ShonenxSearchBarState extends State<ShonenxSearchBar> {
  late FocusNode _focusNode;
  late TextEditingController _searchController;
  bool _isFocused = false;
  bool _isEmpty = true;
  bool _internalController = false;

  @override
  void initState() {
    super.initState();

    _searchController = widget.controller ?? TextEditingController();
    _internalController = widget.controller == null;

    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (mounted) {
        setState(() {
          _isFocused = _focusNode.hasFocus;
        });
      }
    });

    _searchController.addListener(() {
      if (mounted) {
        setState(() {
          _isEmpty = _searchController.text.isEmpty;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    if (_internalController) {
      _searchController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: widget.showShadow
            ? [
                BoxShadow(
                  color: _isFocused
                      ? Colors.deepPurpleAccent.withOpacity(0.2)
                      : Colors.black12,
                  blurRadius: _isFocused ? 6 : 4,
                  spreadRadius: _isFocused ? 2 : 1,
                ),
              ]
            : null,
        border: Border.all(
          color: _isFocused ? Colors.deepPurpleAccent : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                if (widget.leading != null) ...[
                  widget.leading!,
                  const SizedBox(width: 12),
                ] else if (widget.showAnimatedIcon) ...[
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: _isFocused
                        ? Icon(
                            Icons.search,
                            key: const ValueKey('searchIcon'),
                            color: widget.iconColor,
                          )
                        : Icon(
                            Icons.search_outlined,
                            key: const ValueKey('searchOutlineIcon'),
                            color: widget.iconColor,
                          ),
                  ),
                  const SizedBox(width: 12),
                ] else ...[
                  Icon(Icons.search, color: widget.iconColor),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    style: TextStyle(
                      color: widget.textColor,
                      fontSize: 16,
                    ),
                    cursorColor: widget.cursorColor,
                    cursorWidth: 2,
                    cursorRadius: const Radius.circular(4),
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: TextStyle(
                        color: widget.hintColor,
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: widget.onSearch,
                    onChanged: (value) {
                      widget.onChanged(value);
                      setState(() {
                        _isEmpty = value.isEmpty;
                      });
                    },
                  ),
                ),
                if (!_isEmpty && widget.showClearButton) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      widget.onChanged('');
                      setState(() {
                        _isEmpty = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black12,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: widget.iconColor,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SearchBarExample extends StatefulWidget {
  const SearchBarExample({super.key});

  @override
  _SearchBarExampleState createState() => _SearchBarExampleState();
}

class _SearchBarExampleState extends State<SearchBarExample> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<String> _filteredItems = [];
  final List<String> _exampleItems = [
    'Flutter Development',
    'Dart Programming',
    'UI Design',
    'Animation',
    'State Management',
    'Widgets',
    'Material Design',
    'Cupertino Design',
    'Firebase Integration',
    'REST API',
    'GraphQL',
  ];

  @override
  void initState() {
    super.initState();
    _filteredItems = _exampleItems;
  }

  void _filterItems(String query) {
    setState(() {
      _searchQuery = query;
      _filteredItems = query.isEmpty
          ? _exampleItems
          : _exampleItems
              .where((item) => item.toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F7),
        appBar: AppBar(
          title: const Text('Search Bar'),
          backgroundColor: Colors.deepPurple,
          elevation: 0,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Custom Controller'),
              Tab(text: 'Built-in Controller'),
            ],
            indicatorColor: Colors.white,
            labelColor: Colors.white,
          ),
        ),
        body: TabBarView(
          children: [
            _buildSearchBarWithController(),
            _buildSearchBarWithoutController(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBarWithController() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          decoration: const BoxDecoration(
            color: Colors.deepPurple,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: ShonenxSearchBar(
            controller: _searchController,
            hintText: 'Search with custom controller...',
            onSearch: _filterItems,
            onChanged: _filterItems,
            backgroundColor: Colors.white.withOpacity(0.9),
            textColor: Colors.black87,
            hintColor: Colors.black54,
            iconColor: Colors.deepPurple,
            cursorColor: Colors.deepPurpleAccent,
            borderRadius: 20,
            showShadow: true,
            showClearButton: true,
            showAnimatedIcon: true,
          ),
        ),
        Expanded(
          child: _filteredItems.isEmpty
              ? const Center(child: Text('No results found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredItems.length,
                  itemBuilder: (context, index) {
                    return _buildResultItem(_filteredItems[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSearchBarWithoutController() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          decoration: const BoxDecoration(
            color: Colors.deepPurple,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: ShonenxSearchBar(
            hintText: 'Search with built-in controller...',
            onSearch: _filterItems,
            onChanged: _filterItems,
            backgroundColor: Colors.white.withOpacity(0.9),
            textColor: Colors.black87,
            hintColor: Colors.black54,
            iconColor: Colors.deepPurple,
            cursorColor: Colors.deepPurpleAccent,
            borderRadius: 20,
            showShadow: true,
            showClearButton: true,
            showAnimatedIcon: true,
          ),
        ),
        Expanded(
          child: _filteredItems.isEmpty
              ? const Center(child: Text('No results found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredItems.length,
                  itemBuilder: (context, index) {
                    return _buildResultItem(_filteredItems[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildResultItem(String item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple.withOpacity(0.2),
          child: const Icon(Icons.topic, color: Colors.deepPurple),
        ),
        title: Text(
          item,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Tap to view details about $item',
          style: const TextStyle(color: Colors.black54, fontSize: 12),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.deepPurple.withOpacity(0.5),
          size: 16,
        ),
        onTap: () {
          // TODO: Handle item tap
        },
      ),
    );
  }
}
