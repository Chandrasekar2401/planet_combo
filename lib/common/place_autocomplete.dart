import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planetcombo/common/web/place_autocomplete_web_interop_base.dart';

class PlaceAutocompleteWebInput extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String)? onChange;
  final String? Function(String?)? onValidate;
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
  bool _isValidSelection = false;
  String _lastValidValue = '';
  bool _showError = false;

  @override
  void initState() {
    super.initState();
    _loadGooglePlacesScript();

    // Initialize with existing value if present
    if (widget.controller.text.isNotEmpty) {
      _lastValidValue = widget.controller.text;
      _isValidSelection = true;
    }

    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      _showOverlay = true;
      _showSuggestions();
      // If text is not empty, show suggestions immediately
      if (widget.controller.text.isNotEmpty) {
        _getPlaceSuggestions(widget.controller.text);
      }
    } else {
      // Short delay to allow selection to complete before hiding overlay
      Future.delayed(const Duration(milliseconds: 300), () {
        _hideOverlay();

        // Validate after focus lost
        if (widget.controller.text.isNotEmpty && !_isValidSelection) {
          setState(() {
            _showError = true;
            if (_lastValidValue.isNotEmpty) {
              widget.controller.text = _lastValidValue;
              _isValidSelection = true;
              if (widget.onChange != null) {
                widget.onChange!(_lastValidValue);
              }
            }
          });
        }
      });
    }
  }

  void _loadGooglePlacesScript() {
    if (WebInterop.checkScript('google-places-script')) {
      setState(() {
        _isScriptLoaded = true;
      });
      return;
    }

    WebInterop.loadScript(
      'google-places-script',
      'https://maps.googleapis.com/maps/api/js?key=AIzaSyDRX8p3QXbJtS6vVpNgelztCe2RAQBgN44&libraries=places',
          () {
        setState(() {
          _isScriptLoaded = true;
        });
      },
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _hideOverlay();
    super.dispose();
  }

  void _handleSelection(dynamic place) {
    final selectedValue = place['description'] ?? '';

    setState(() {
      widget.controller.text = selectedValue;
      _isValidSelection = true;
      _lastValidValue = selectedValue;
      _showError = false;
    });

    if (widget.onChange != null) {
      widget.onChange!(selectedValue);
    }

    // Hide overlay and unfocus after a short delay to ensure selection is registered
    Future.delayed(Duration(milliseconds: 100), () {
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
              constraints: const BoxConstraints(maxHeight: 250),
              color: Colors.white,
              child: _placesList.isEmpty
                  ? Container(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Type to search locations',
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              )
                  : ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _placesList.length,
                itemBuilder: (context, index) {
                  final place = _placesList[index];
                  return InkWell(
                    onTap: () => _handleSelection(place),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
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
        setState(() {
          if (status == 'OK' && results != null) {
            _placesList = List.from(results as List);
          } else {
            _placesList = [];
          }
        });

        if (_showOverlay && _overlayEntry != null) {
          _overlayEntry!.markNeedsBuild();
        }
      },
    );
  }

  // Custom validation function
  String? _validateInput(String? value) {
    // First run any external validation
    if (widget.onValidate != null) {
      final externalValidation = widget.onValidate!(value);
      if (externalValidation != null) {
        return externalValidation;
      }
    }

    // Then check if it's a valid selection from dropdown
    if (value == null || value.isEmpty) {
      return 'Please enter a location';
    }

    if (!_isValidSelection) {
      return 'Please select a location from the dropdown';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
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
              errorText: _showError ? 'Please select a location from the dropdown' : null,
              errorStyle: GoogleFonts.lexend(
                fontSize: 12,
                color: Colors.red,
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!_isScriptLoaded)
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(widget.borderColor),
                      ),
                    ),
                  if (widget.controller.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        widget.controller.clear();
                        _isValidSelection = false;
                        _lastValidValue = '';
                        _placesList = [];
                        _showError = false;
                        setState(() {});
                        if (widget.onChange != null) {
                          widget.onChange!('');
                        }
                      },
                    ),
                ],
              ),
            ),
            onChanged: (value) {
              // When user types, it's no longer a validated selection
              // unless it matches the last valid value
              _isValidSelection = (value == _lastValidValue);
              _showError = false;

              if (widget.onChange != null) {
                widget.onChange!(value);
              }

              if (_debounce?.isActive ?? false) _debounce!.cancel();
              _debounce = Timer(const Duration(milliseconds: 300), () {
                if (value.isNotEmpty) {
                  _getPlaceSuggestions(value);
                  if (!_showOverlay) {
                    _showOverlay = true;
                    _showSuggestions();
                  }
                } else {
                  setState(() {
                    _placesList = [];
                  });
                  if (_showOverlay && _overlayEntry != null) {
                    _overlayEntry!.markNeedsBuild();
                  }
                }
              });
            },
            validator: _validateInput,
            onTap: () {
              if (!_showOverlay) {
                _showOverlay = true;
                _showSuggestions();
                if (widget.controller.text.isNotEmpty) {
                  _getPlaceSuggestions(widget.controller.text);
                }
              }
            },
            onFieldSubmitted: (value) {
              // When user submits, check if it's a valid selection
              if (!_isValidSelection && value.isNotEmpty) {
                setState(() {
                  _showError = true;
                  // Restore last valid value if available
                  if (_lastValidValue.isNotEmpty) {
                    widget.controller.text = _lastValidValue;
                    _isValidSelection = true;
                    if (widget.onChange != null) {
                      widget.onChange!(_lastValidValue);
                    }
                  }
                });
              }
            },
          ),
          if (_isScriptLoaded == false)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Loading location service...',
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
        ],
      ),
    );
  }
}