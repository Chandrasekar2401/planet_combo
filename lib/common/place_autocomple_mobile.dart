import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PlaceAutocompleteMobileInput extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String)? onChange;
  final Function(String?)? onValidate;
  final Color borderColor;

  const PlaceAutocompleteMobileInput({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChange,
    this.onValidate,
    required this.borderColor,
  });

  @override
  _PlaceAutocompleteMobileInputState createState() => _PlaceAutocompleteMobileInputState();
}

class _PlaceAutocompleteMobileInputState extends State<PlaceAutocompleteMobileInput> {
  List<Map<String, String>> _placesList = [];
  Timer? _debounce;
  final FocusNode _focusNode = FocusNode();
  bool _showOverlay = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _showOverlay = true;
        _showSuggestions();
      } else {
        Future.delayed(const Duration(milliseconds: 200), () {
          _hideOverlay();
        });
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode.dispose();
    _hideOverlay();
    super.dispose();
  }

  void _handleSelection(Map<String, String> place) {
    print('_handleSelection called');
    final selectedValue = place['description'] ?? '';
    print('Selected value: $selectedValue');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Update the controller text
      widget.controller.text = selectedValue;
      print('Controller text updated to: ${widget.controller.text}');

      // Trigger onChange callback
      if (widget.onChange != null) {
        widget.onChange!(selectedValue);
      }

      setState(() {}); // Force rebuild

      // Hide overlay and unfocus
      _hideOverlay();
      _focusNode.unfocus();
    });
  }

  void _showSuggestions() {
    if (_overlayEntry != null) return;

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height),
          child: Material(
            elevation: 4,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              color: Colors.white,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _placesList.length,
                itemBuilder: (context, index) {
                  final place = _placesList[index];
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      print('GestureDetector onTap called');
                      _handleSelection(place);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      child: Text(
                        place['description'] ?? '',
                        style: GoogleFonts.lexend(fontSize: 14),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _showOverlay = false;
  }

  Future<void> _getPlaceSuggestions(String input) async {
    const String apiKey = 'AIzaSyDRX8p3QXbJtS6vVpNgelztCe2RAQBgN44';
    const String baseURL = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    final String url = '$baseURL?input=$input&types=(cities)&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          setState(() {
            _placesList = List<Map<String, String>>.from(
                (data['predictions'] as List).map((prediction) => {
                  'description': prediction['description'] as String,
                })
            );
          });
          if (_showOverlay) {
            _overlayEntry?.markNeedsBuild();
          }
        } else {
          setState(() {
            _placesList = [];
          });
        }
      }
    } catch (e) {
      print('Error fetching place suggestions: $e');
      setState(() {
        _placesList = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        style: GoogleFonts.lexend(
          fontSize: 14,
        ),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.fromLTRB(0, 12, 0, 7),
          hintText: widget.hintText,
          hintStyle: GoogleFonts.lexend(
            fontSize: 14,
            color: Colors.black54,
          ),
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: widget.borderColor),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: widget.borderColor),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: widget.borderColor),
          ),
        ),
        onChanged: (value) {
          print('onChanged: $value');
          if (widget.onChange != null) {
            widget.onChange!(value);
          }
          if (_debounce?.isActive ?? false) _debounce!.cancel();
          _debounce = Timer(const Duration(milliseconds: 500), () {
            if (value.isNotEmpty) {
              _getPlaceSuggestions(value);
            } else {
              setState(() {
                _placesList = [];
              });
              if (_showOverlay) {
                _overlayEntry?.markNeedsBuild();
              }
            }
          });
        },
        validator: (value) {
          if (widget.onValidate != null) {
            return widget.onValidate!(value);
          }
          return null;
        },
      ),
    );
  }
}