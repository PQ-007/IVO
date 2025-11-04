import 'package:flutter/material.dart';

class MySearchbar extends StatefulWidget {
  final TextEditingController? controller;
  final void Function(String)? onSearch;
  final String hintText;
  const MySearchbar({
    super.key,
    this.controller,
    this.onSearch,
    required this.hintText,
  });

  @override
  State<MySearchbar> createState() => _MySearchbarState();
}

class _MySearchbarState extends State<MySearchbar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _controller.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
   
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(32),
        color: Theme.of(context).cardColor,
        child: TextField(
          controller: _controller,
          onChanged: (_) => setState(() {}),
          onSubmitted: widget.onSearch,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
            hintText: widget.hintText,
            hintStyle: TextStyle(color: Colors.grey[500]),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Icon(
                Icons.search,
                color: Theme.of(context).iconTheme.color,
              ),
            ),
            suffixIcon:
                _controller.text.isNotEmpty
                    ? Padding(
                      padding: const EdgeInsets.all(
                        5.0,
                      ), // Add padding around the suffix icon
                      child: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      ),
                    )
                    : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32.0),
              borderSide: BorderSide.none,
            ),
            filled: true,
          ),
        ),
      ),
    );
  }
}
