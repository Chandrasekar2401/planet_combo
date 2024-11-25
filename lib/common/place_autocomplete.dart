import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planetcombo/common/web/place_autocomplete_web_interop_base.dart';

class PlaceAutocompleteWebInput extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String)? onChange;
  final Function(String?)? onValidate;
  final Color borderColor;

  const PlaceAutocompleteWebInput({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChange,
    this.onValidate,
    required this.borderColor,
  });

  @override
  _PlaceAutocompleteInputState createState() => _PlaceAutocompleteInputState();
}

class _PlaceAutocompleteInputState extends State<PlaceAutocompleteWebInput> {
  List<dynamic> _placesList = [];
  Timer? _debounce;
  final FocusNode _focusNode = FocusNode();
  bool _showOverlay = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isScriptLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadGooglePlacesScript();
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

  void _loadGooglePlacesScript() {
    if (WebInterop.checkScript('google-places-script')) {
      _isScriptLoaded = true;
      return;
    }

    WebInterop.loadScript(
      'google-places-script',
      'https://maps.googleapis.com/maps/api/js?key=AIzaSyDRX8p3QXbJtS6vVpNgelztCe2RAQBgN44&libraries=places',
          () {
        _isScriptLoaded = true;
      },
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode.dispose();
    _hideOverlay();
    super.dispose();
  }

  void _handleSelection(dynamic place) {
    print('_handleSelection called');
    final selectedValue = place['description'] ?? '';
    print('Selected value: $selectedValue');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.text = selectedValue;
      print('Controller text updated to: ${widget.controller.text}');

      if (widget.onChange != null) {
        widget.onChange!(selectedValue);
      }

      setState(() {});
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

  void _getPlaceSuggestions(String input) {
    if (!_isScriptLoaded) return;

    final autocompleteService = WebInterop.createAutocompleteService();
    if (autocompleteService == null) return;

    final request = WebInterop.createRequest(input);

    WebInterop.getPredictions(
      autocompleteService,
      request,
          (results, status) {
        if (status == 'OK') {
          setState(() {
            _placesList = List.from(results as List);
          });
          if (_showOverlay) {
            _overlayEntry?.markNeedsBuild();
          }
        } else {
          setState(() {
            _placesList = [];
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Rest of your build method remains the same
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