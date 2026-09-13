import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class UploadMemoryScreen extends StatefulWidget {
  const UploadMemoryScreen({super.key});

  @override
  State<UploadMemoryScreen> createState() => _UploadMemoryScreenState();
}

class _UploadMemoryScreenState extends State<UploadMemoryScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Picker Error'),
            content: Text(e.toString()),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      backgroundColor: const Color(0xFF000000),
      background: Stack(
        fit: StackFit.expand,
        children: const [
          // Top-Left Ambient Glow (Blue)
          Positioned(
            top: -100,
            left: -100,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x26007AFF), // activeBlue with 0.15 alpha
              ),
              child: SizedBox(width: 400, height: 400),
            ),
          ),
          // Bottom-Right Ambient Glow (Teal)
          Positioned(
            bottom: -50,
            right: -50,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x1A64FFDA), // teal with 0.1 alpha
              ),
              child: SizedBox(width: 350, height: 350),
            ),
          ),
        ],
      ),
      appBar: GlassAppBar(
        backgroundColor: const Color(0x00000000),
        leading: GlassButton(
          settings: const LiquidGlassSettings(chromaticAberration: 0.5),
          icon: const Icon(CupertinoIcons.chevron_back, color: CupertinoColors.white),
          onTap: () => Navigator.pop(context),
          width: 44,
          height: 44,
          style: GlassButtonStyle.transparent,
        ),
        title: const Text(
          'Memory Lab',
          style: TextStyle(
            color: CupertinoColors.white,
            fontWeight: FontWeight.w300,
            letterSpacing: 2,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'CAPTURE',
                  style: TextStyle(
                    color: Color(0x80FFFFFF),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 8,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'The Moment',
                  style: TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w200,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Main Frame
                GestureDetector(
                  onTap: _pickImage,
                  behavior: HitTestBehavior.opaque,
                  child: AdaptiveGlass(
                    quality: GlassQuality.premium,
                    shape: const LiquidRoundedSuperellipse(borderRadius: 40),
                    settings: const LiquidGlassSettings(
                      chromaticAberration: 1.2,
                      blur: 40,
                    ),
                    child: Container(
                      width: double.infinity,
                      height: 420,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0x1AFFFFFF),
                          width: 1,
                        ),
                        image: _image != null
                            ? DecorationImage(
                                image: FileImage(_image!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _image == null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    CupertinoIcons.camera,
                                    size: 80,
                                    color: Color(0x40FFFFFF),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'TAP TO SELECT',
                                    style: const TextStyle(
                                      color: Color(0x99FFFFFF),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(
                              alignment: Alignment.bottomRight,
                              padding: const EdgeInsets.all(16),
                              child: const Icon(
                                CupertinoIcons.checkmark_seal_fill,
                                color: CupertinoColors.activeBlue,
                                size: 32,
                              ),
                            ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Dynamic Actions
                if (_image != null)
                  Row(
                    children: [
                      GlassButton(
                        onTap: _pickImage,
                        width: 64,
                        height: 64,
                        icon: const Icon(CupertinoIcons.repeat, color: CupertinoColors.white),
                        settings: const LiquidGlassSettings(chromaticAberration: 0.5),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GlassButton.custom(
                          onTap: () => Navigator.pop(context, _image!.path),
                          height: 64,
                          quality: GlassQuality.premium,
                          shape: const LiquidRoundedSuperellipse(borderRadius: 100),
                          settings: const LiquidGlassSettings(
                            chromaticAberration: 1.0,
                          ),
                          child: const Center(
                            child: Text(
                              'PRESERVE MEMORY',
                              style: TextStyle(
                                color: CupertinoColors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GlassButton.custom(
                      onTap: _pickImage,
                      width: double.infinity,
                      height: 64,
                      quality: GlassQuality.premium,
                      shape: const LiquidRoundedSuperellipse(borderRadius: 100), // Pill shape katulad ng menu bar
                      settings: const LiquidGlassSettings(
                        chromaticAberration: 1.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(CupertinoIcons.photo_on_rectangle,
                              color: CupertinoColors.white, size: 22),
                          SizedBox(width: 12),
                          Text(
                            'OPEN GALLERY',
                            style: TextStyle(
                              color: CupertinoColors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                const SizedBox(height: 20),
                const Text(
                  'Images are securely uploaded to your private gallery.',
                  style: TextStyle(
                    color: Color(0x4DFFFFFF),
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
